import 'package:bookswap/models/book.dart';
import 'package:bookswap/models/swap.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'chat_service.dart';

/// Swap service handling swap operations between users
class SwapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();

  /// Create a swap offer
  Future<String> createSwap({
    required String recipientBookId,
    required String offeredBookId,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get both books
      final recipientBookDoc = await _firestore
          .collection('books')
          .doc(recipientBookId)
          .get();
      final offeredBookDoc = await _firestore
          .collection('books')
          .doc(offeredBookId)
          .get();

      if (!recipientBookDoc.exists || !offeredBookDoc.exists) {
        throw Exception('One or both books not found');
      }

      final recipientBook = Book.fromFirestore(recipientBookDoc);
      final offeredBook = Book.fromFirestore(offeredBookDoc);

      // Validate books
      if (recipientBook.status != 'available' ||
          offeredBook.status != 'available') {
        throw Exception('One or both books are not available');
      }

      if (offeredBook.ownerId != user.uid) {
        throw Exception('You can only offer your own books');
      }

      if (recipientBook.ownerId == user.uid) {
        throw Exception('Cannot swap with yourself');
      }

      final recipientId = recipientBook.ownerId;

      // Create swap document
      final swapRef = await _firestore.collection('swaps').add({
        'requesterId': user.uid,
        'requesterBookId': offeredBookId,
        'recipientId': recipientId,
        'recipientBookId': recipientBookId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Update both books to pending status
      await Future.wait([
        _firestore.collection('books').doc(recipientBookId).update({
          'status': 'pending',
        }),
        _firestore.collection('books').doc(offeredBookId).update({
          'status': 'pending',
        }),
      ]);

      // Create or get chat for these users
      await _chatService.createOrGetChat(
        participantIds: [user.uid, recipientId],
        relatedSwapId: swapRef.id,
      );

      return swapRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Accept a swap offer
  Future<void> acceptSwap(String swapId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get swap document
      final swapDoc = await _firestore.collection('swaps').doc(swapId).get();
      if (!swapDoc.exists) throw Exception('Swap not found');

      final swap = Swap.fromFirestore(swapDoc);

      // Verify user is the recipient
      if (swap.recipientId != user.uid) {
        throw Exception('Only the recipient can accept this swap');
      }

      // Verify swap is pending
      if (swap.status != 'pending') {
        throw Exception('Swap is not in pending status');
      }

      // Update swap status
      await _firestore.collection('swaps').doc(swapId).update({
        'status': 'accepted',
      });

      // Update both books to swapped status
      await Future.wait([
        _firestore.collection('books').doc(swap.recipientBookId).update({
          'status': 'swapped',
        }),
        _firestore.collection('books').doc(swap.requesterBookId).update({
          'status': 'swapped',
        }),
      ]);

      // Get books for swaping ids
      final recipientBookRef = _firestore
          .collection('books')
          .doc(swap.recipientBookId);
      final recipientBookDoc = await recipientBookRef.get();
      if (!recipientBookDoc.exists) throw Exception('Recipient book not found');
      final recipientBook = recipientBookDoc.data()!;

      final requesterBookRef = _firestore
          .collection('books')
          .doc(swap.requesterBookId);
      final requesterBookDoc = await requesterBookRef.get();
      if (!requesterBookDoc.exists) throw Exception('Requester book not found');
      final requesterBook = requesterBookDoc.data()!;

      // Swap owner IDs and names
      await Future.wait([
        recipientBookRef.update({
          'ownerId': swap.requesterId,
          'ownerName': requesterBook['ownerName'] ?? 'Unknown',
        }),
        requesterBookRef.update({
          'ownerId': swap.recipientId,
          'ownerName': recipientBook['ownerName'] ?? 'Unknown',
        }),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  /// Decline a swap offer
  Future<void> declineSwap(String swapId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get swap document
      final swapDoc = await _firestore.collection('swaps').doc(swapId).get();
      if (!swapDoc.exists) throw Exception('Swap not found');

      final swap = Swap.fromFirestore(swapDoc);

      // Verify user is the recipient
      if (swap.recipientId != user.uid) {
        throw Exception('Only the recipient can decline this swap');
      }

      // Verify swap is pending
      if (swap.status != 'pending') {
        throw Exception('Swap is not in pending status');
      }

      // Update swap status
      await _firestore.collection('swaps').doc(swapId).update({
        'status': 'declined',
      });

      // Update both books back to available status
      await Future.wait([
        _firestore.collection('books').doc(swap.recipientBookId).update({
          'status': 'available',
        }),
        _firestore.collection('books').doc(swap.requesterBookId).update({
          'status': 'available',
        }),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  /// Cancel a swap (by requester)
  Future<void> cancelSwap(String swapId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get swap document
      final swapDoc = await _firestore.collection('swaps').doc(swapId).get();
      if (!swapDoc.exists) throw Exception('Swap not found');

      final swap = Swap.fromFirestore(swapDoc);

      // Verify user is the requester
      if (swap.requesterId != user.uid) {
        throw Exception('Only the requester can cancel this swap');
      }

      // Verify swap is pending
      if (swap.status != 'pending') {
        throw Exception('Swap is not in pending status');
      }

      // Update swap status
      await _firestore.collection('swaps').doc(swapId).update({
        'status': 'cancelled',
      });

      // Update both books back to available status
      await Future.wait([
        _firestore.collection('books').doc(swap.recipientBookId).update({
          'status': 'available',
        }),
        _firestore.collection('books').doc(swap.requesterBookId).update({
          'status': 'available',
        }),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  /// Get swap by ID
  Future<Swap?> getSwap(String swapId) async {
    try {
      final doc = await _firestore.collection('swaps').doc(swapId).get();
      if (!doc.exists) return null;
      return Swap.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }
}
