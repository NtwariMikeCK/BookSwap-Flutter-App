import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType {
  text, // Regular text message
  system, // System-generated message (e.g., "Swap accepted")
  image, // Image message (future feature)
}

extension MessageTypeExtension on MessageType {
  String toFirestore() {
    return toString().split('.').last;
  }

  static MessageType fromString(String value) {
    return MessageType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => MessageType.text,
    );
  }
}

class Message {
  final String id;
  final String chatId;
  final String senderId;
  final String senderName;
  final String text;
  final MessageType type;
  final bool isRead;
  final DateTime createdAt;

  Message({
    required this.id,
    required this.chatId,
    required this.senderId,
    required this.senderName,
    required this.text,
    this.type = MessageType.text,
    this.isRead = false,
    required this.createdAt,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Message(
      id: doc.id,
      chatId: data['chatId'] ?? '',
      senderId: data['senderId'] ?? '',
      senderName: data['senderName'] ?? '',
      text: data['text'] ?? '',
      type: MessageTypeExtension.fromString(data['type'] ?? 'text'),
      isRead: data['isRead'] ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'senderId': senderId,
      'senderName': senderName,
      'text': text,
      'type': type.toFirestore(),
      'isRead': isRead,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Message copyWith({
    String? id,
    String? chatId,
    String? senderId,
    String? senderName,
    String? text,
    MessageType? type,
    bool? isRead,
    DateTime? createdAt,
  }) {
    return Message(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      text: text ?? this.text,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
