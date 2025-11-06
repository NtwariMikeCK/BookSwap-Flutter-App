import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/book.dart';
import '../models/swap.dart';
import '../models/notifications.dart';
import '../models/message.dart';
import 'auth_provider.dart';

final mySwapRequestsProvider = StreamProvider<List<Swap>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('swaps')
      .where('requesterId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Swap.fromFirestore(doc)).toList(),
      );
});

final incomingSwapOffersProvider = StreamProvider<List<Swap>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('swaps')
      .where('recipientId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Swap.fromFirestore(doc)).toList(),
      );
});

final swapByIdProvider = StreamProvider.family<Swap?, String>((ref, swapId) {
  return FirebaseFirestore.instance
      .collection('swaps')
      .doc(swapId)
      .snapshots()
      .map((doc) => doc.exists ? Swap.fromFirestore(doc) : null);
});

class SwapService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> createSwap({
    required String requesterId,
    required String requesterName,
    required String requesterBookId,
    required String requesterBookTitle,
    required String recipientId,
    required String recipientName,
    required String recipientBookId,
    required String recipientBookTitle,
  }) async {
    final batch = _firestore.batch();

    // Create swap document
    final swapRef = _firestore.collection('swaps').doc();
    batch.set(swapRef, {
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterBookId': requesterBookId,
      'requesterBookTitle': requesterBookTitle,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'recipientBookId': recipientBookId,
      'recipientBookTitle': recipientBookTitle,
      'status': SwapStatus.pending.toFirestore(),
      'chatId': null,
      'createdAt': FieldValue.serverTimestamp(),
      'acceptedAt': null,
      'completedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update both books to pending status
    batch.update(_firestore.collection('books').doc(requesterBookId), {
      'status': BookStatus.pending.toFirestore(),
      'currentSwapId': swapRef.id,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection('books').doc(recipientBookId), {
      'status': BookStatus.pending.toFirestore(),
      'currentSwapId': swapRef.id,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Create a chat for this swap
    final chatRef = _firestore.collection('chats').doc();
    batch.set(chatRef, {
      'participants': [requesterId, recipientId],
      'participantNames': {
        requesterId: requesterName,
        recipientId: recipientName,
      },
      'relatedSwapId': swapRef.id,
      'lastMessage': null,
      'lastMessageSenderId': null,
      'lastMessageTime': null,
      'unreadCount': {requesterId: 0, recipientId: 0},
      'createdAt': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
    });

    // Update swap with chat ID
    batch.update(swapRef, {'chatId': chatRef.id});

    // Create notification for recipient
    final notificationRef = _firestore.collection('notifications').doc();
    batch.set(notificationRef, {
      'userId': recipientId,
      'type': NotificationType.swapOffer.toFirestore(),
      'title': 'New Swap Offer',
      'body':
          '$requesterName wants to swap "$requesterBookTitle" for your "$recipientBookTitle"',
      'isRead': false,
      'relatedSwapId': swapRef.id,
      'relatedChatId': chatRef.id,
      'relatedBookId': recipientBookId,
      'data': {
        'requesterId': requesterId,
        'requesterName': requesterName,
        'requesterBookTitle': requesterBookTitle,
      },
      'createdAt': FieldValue.serverTimestamp(),
      'readAt': null,
    });

    await batch.commit();
    return swapRef.id;
  }

  Future<void> acceptSwap(Swap swap) async {
    final batch = _firestore.batch();

    // Update swap status
    batch.update(_firestore.collection('swaps').doc(swap.id), {
      'status': SwapStatus.accepted.toFirestore(),
      'acceptedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update both books to swapped status
    batch.update(_firestore.collection('books').doc(swap.requesterBookId), {
      'status': BookStatus.swapped.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection('books').doc(swap.recipientBookId), {
      'status': BookStatus.swapped.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Send system message to chat
    if (swap.chatId != null) {
      final messageRef = _firestore
          .collection('chats')
          .doc(swap.chatId)
          .collection('messages')
          .doc();

      batch.set(messageRef, {
        'chatId': swap.chatId,
        'senderId': 'system',
        'senderName': 'System',
        'text': '🎉 Swap accepted! You can now coordinate the exchange.',
        'type': MessageType.system.toFirestore(),
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.update(_firestore.collection('chats').doc(swap.chatId), {
        'lastMessage': '🎉 Swap accepted! You can now coordinate the exchange.',
        'lastMessageSenderId': 'system',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    // Create notification for requester
    final notificationRef = _firestore.collection('notifications').doc();
    batch.set(notificationRef, {
      'userId': swap.requesterId,
      'type': NotificationType.swapAccepted.toFirestore(),
      'title': 'Swap Accepted!',
      'body':
          '${swap.recipientName} accepted your swap offer for "${swap.recipientBookTitle}"',
      'isRead': false,
      'relatedSwapId': swap.id,
      'relatedChatId': swap.chatId,
      'relatedBookId': swap.recipientBookId,
      'createdAt': FieldValue.serverTimestamp(),
      'readAt': null,
    });

    await batch.commit();
  }

  Future<void> declineSwap(Swap swap) async {
    final batch = _firestore.batch();

    // Update swap status
    batch.update(_firestore.collection('swaps').doc(swap.id), {
      'status': SwapStatus.declined.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update both books back to available status
    batch.update(_firestore.collection('books').doc(swap.requesterBookId), {
      'status': BookStatus.available.toFirestore(),
      'currentSwapId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection('books').doc(swap.recipientBookId), {
      'status': BookStatus.available.toFirestore(),
      'currentSwapId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Send system message to chat
    if (swap.chatId != null) {
      final messageRef = _firestore
          .collection('chats')
          .doc(swap.chatId)
          .collection('messages')
          .doc();

      batch.set(messageRef, {
        'chatId': swap.chatId,
        'senderId': 'system',
        'senderName': 'System',
        'text': 'Swap offer was declined.',
        'type': MessageType.system.toFirestore(),
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      batch.update(_firestore.collection('chats').doc(swap.chatId), {
        'lastMessage': 'Swap offer was declined.',
        'lastMessageSenderId': 'system',
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    // Create notification for requester
    final notificationRef = _firestore.collection('notifications').doc();
    batch.set(notificationRef, {
      'userId': swap.requesterId,
      'type': NotificationType.swapDeclined.toFirestore(),
      'title': 'Swap Declined',
      'body':
          '${swap.recipientName} declined your swap offer for "${swap.recipientBookTitle}"',
      'isRead': false,
      'relatedSwapId': swap.id,
      'relatedChatId': swap.chatId,
      'relatedBookId': swap.recipientBookId,
      'createdAt': FieldValue.serverTimestamp(),
      'readAt': null,
    });

    await batch.commit();
  }

  Future<void> cancelSwap(Swap swap) async {
    final batch = _firestore.batch();

    // Update swap status
    batch.update(_firestore.collection('swaps').doc(swap.id), {
      'status': SwapStatus.cancelled.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Update both books back to available status
    batch.update(_firestore.collection('books').doc(swap.requesterBookId), {
      'status': BookStatus.available.toFirestore(),
      'currentSwapId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.update(_firestore.collection('books').doc(swap.recipientBookId), {
      'status': BookStatus.available.toFirestore(),
      'currentSwapId': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> markSwapCompleted(Swap swap) async {
    await _firestore.collection('swaps').doc(swap.id).update({
      'status': SwapStatus.completed.toFirestore(),
      'completedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

final swapServiceProvider = Provider((ref) => SwapService());
