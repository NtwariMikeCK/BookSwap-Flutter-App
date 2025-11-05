import 'package:cloud_firestore/cloud_firestore.dart';

enum NotificationType {
  swapOffer, // Someone offered a swap
  swapAccepted, // Your swap offer was accepted
  swapDeclined, // Your swap offer was declined
  newMessage, // New chat message
  reminder, // General reminder
}

extension NotificationTypeExtension on NotificationType {
  String toFirestore() {
    return toString().split('.').last;
  }

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => NotificationType.reminder,
    );
  }
}

class AppNotification {
  final String id;
  final String userId; // Recipient of notification
  final NotificationType type;
  final String title;
  final String body;
  final bool isRead;
  final String? relatedSwapId; // Reference to swap if applicable
  final String? relatedChatId; // Reference to chat if applicable
  final String? relatedBookId; // Reference to book if applicable
  final Map<String, dynamic>? data; // Additional data payload
  final DateTime createdAt;
  final DateTime? readAt;

  AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.body,
    this.isRead = false,
    this.relatedSwapId,
    this.relatedChatId,
    this.relatedBookId,
    this.data,
    required this.createdAt,
    this.readAt,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AppNotification(
      id: doc.id,
      userId: data['userId'] ?? '',
      type: NotificationTypeExtension.fromString(data['type'] ?? 'reminder'),
      title: data['title'] ?? '',
      body: data['body'] ?? '',
      isRead: data['isRead'] ?? false,
      relatedSwapId: data['relatedSwapId'],
      relatedChatId: data['relatedChatId'],
      relatedBookId: data['relatedBookId'],
      data: data['data'] as Map<String, dynamic>?,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      readAt: (data['readAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'type': type.toFirestore(),
      'title': title,
      'body': body,
      'isRead': isRead,
      'relatedSwapId': relatedSwapId,
      'relatedChatId': relatedChatId,
      'relatedBookId': relatedBookId,
      'data': data,
      'createdAt': Timestamp.fromDate(createdAt),
      'readAt': readAt != null ? Timestamp.fromDate(readAt!) : null,
    };
  }

  AppNotification copyWith({
    String? id,
    String? userId,
    NotificationType? type,
    String? title,
    String? body,
    bool? isRead,
    String? relatedSwapId,
    String? relatedChatId,
    String? relatedBookId,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    DateTime? readAt,
  }) {
    return AppNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      body: body ?? this.body,
      isRead: isRead ?? this.isRead,
      relatedSwapId: relatedSwapId ?? this.relatedSwapId,
      relatedChatId: relatedChatId ?? this.relatedChatId,
      relatedBookId: relatedBookId ?? this.relatedBookId,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
    );
  }
}
