import 'package:bookswap/models/chat.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Chat service handling messaging between users
class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Create or get existing chat between users
  Future<String> createOrGetChat({
    required List<String> participantIds,
    String? relatedSwapId,
  }) async {
    try {
      // Sort participant IDs for consistent query
      final sortedIds = List<String>.from(participantIds)..sort();

      // Check if chat already exists
      final existingChats = await _firestore
          .collection('chats')
          .where('participants', isEqualTo: sortedIds)
          .limit(1)
          .get();

      if (existingChats.docs.isNotEmpty) {
        return existingChats.docs.first.id;
      }

      // Create new chat
      final chatRef = await _firestore.collection('chats').add({
        'participants': sortedIds,
        'relatedSwapId': relatedSwapId,
        'lastMessage': null,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      return chatRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Send a message in a chat
  Future<void> sendMessage({
    required String chatId,
    required String text,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify user is a participant
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();
      if (!chatDoc.exists) throw Exception('Chat not found');

      final participants = List<String>.from(
        chatDoc.data()?['participants'] ?? [],
      );
      if (!participants.contains(user.uid)) {
        throw Exception('Not authorized to send messages in this chat');
      }

      // Create message
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
            'senderId': user.uid,
            'text': text,
            'createdAt': FieldValue.serverTimestamp(),
          });

      // Update chat's last message and timestamp
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': text,
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      rethrow;
    }
  }

  /// Get chat by ID
  Future<Chat?> getChat(String chatId) async {
    try {
      final doc = await _firestore.collection('chats').doc(chatId).get();
      if (!doc.exists) return null;
      return Chat.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  /// Get other participant in a chat
  Future<String?> getOtherParticipant(String chatId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return null;

      final chat = await getChat(chatId);
      if (chat == null) return null;

      return chat.participants.firstWhere(
        (id) => id != user.uid,
        orElse: () => '',
      );
    } catch (e) {
      return null;
    }
  }
}
