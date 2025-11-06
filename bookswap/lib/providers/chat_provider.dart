import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat.dart';
import '../models/message.dart';
import '../models/notifications.dart';
import 'auth_provider.dart';

final myChatsProvider = StreamProvider<List<Chat>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('chats')
      .where('participants', arrayContains: user.uid)
      .orderBy('lastUpdated', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList(),
      );
});

final chatByIdProvider = StreamProvider.family<Chat?, String>((ref, chatId) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .snapshots()
      .map((doc) => doc.exists ? Chat.fromFirestore(doc) : null);
});

final chatMessagesProvider = StreamProvider.family<List<Message>, String>((
  ref,
  chatId,
) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList(),
      );
});

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String senderName,
    required String text,
    required List<String> participants,
  }) async {
    final batch = _firestore.batch();

    // Add message to subcollection
    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    batch.set(messageRef, {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'type': MessageType.text.toFirestore(),
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Update chat with last message and increment unread count for other participant
    final otherParticipantId = participants.firstWhere((id) => id != senderId);

    batch.update(_firestore.collection('chats').doc(chatId), {
      'lastMessage': text,
      'lastMessageSenderId': senderId,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'lastUpdated': FieldValue.serverTimestamp(),
      'unreadCount.$otherParticipantId': FieldValue.increment(1),
    });

    // Create notification for other participant
    final notificationRef = _firestore.collection('notifications').doc();
    batch.set(notificationRef, {
      'userId': otherParticipantId,
      'type': NotificationType.newMessage.toFirestore(),
      'title': 'New Message from $senderName',
      'body': text.length > 50 ? '${text.substring(0, 50)}...' : text,
      'isRead': false,
      'relatedChatId': chatId,
      'data': {'senderId': senderId, 'senderName': senderName},
      'createdAt': FieldValue.serverTimestamp(),
      'readAt': null,
    });

    await batch.commit();
  }

  Future<void> markMessagesAsRead({
    required String chatId,
    required String userId,
  }) async {
    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.$userId': 0,
    });
  }

  Future<void> deleteChat(String chatId) async {
    // Delete all messages first
    final messages = await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .get();

    final batch = _firestore.batch();
    for (var doc in messages.docs) {
      batch.delete(doc.reference);
    }

    // Delete chat
    batch.delete(_firestore.collection('chats').doc(chatId));

    await batch.commit();
  }
}

final chatServiceProvider = Provider((ref) => ChatService());
