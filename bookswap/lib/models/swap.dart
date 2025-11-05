// ==================== SWAP MODEL ====================
import 'package:cloud_firestore/cloud_firestore.dart';

enum SwapStatus {
  pending, // Swap offer has been sent, awaiting response
  accepted, // Recipient accepted the swap
  declined, // Recipient declined the swap
  completed, // Swap has been physically completed
  cancelled, // Requester cancelled before acceptance
}

extension SwapStatusExtension on SwapStatus {
  String get displayName {
    switch (this) {
      case SwapStatus.pending:
        return 'Pending';
      case SwapStatus.accepted:
        return 'Accepted';
      case SwapStatus.declined:
        return 'Declined';
      case SwapStatus.completed:
        return 'Completed';
      case SwapStatus.cancelled:
        return 'Cancelled';
    }
  }

  String toFirestore() {
    return toString().split('.').last;
  }

  static SwapStatus fromString(String value) {
    return SwapStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => SwapStatus.pending,
    );
  }
}

class Swap {
  final String id;
  final String requesterId; // User who initiated the swap
  final String requesterName; // Name of requester
  final String requesterBookId; // Book offered by requester
  final String requesterBookTitle; // Title of requester's book
  final String recipientId; // User who received the swap offer
  final String recipientName; // Name of recipient
  final String recipientBookId; // Book requested from recipient
  final String recipientBookTitle; // Title of recipient's book
  final SwapStatus status;
  final String? chatId; // Reference to chat created for this swap
  final DateTime createdAt;
  final DateTime? acceptedAt;
  final DateTime? completedAt;
  final DateTime? updatedAt;

  Swap({
    required this.id,
    required this.requesterId,
    required this.requesterName,
    required this.requesterBookId,
    required this.requesterBookTitle,
    required this.recipientId,
    required this.recipientName,
    required this.recipientBookId,
    required this.recipientBookTitle,
    required this.status,
    this.chatId,
    required this.createdAt,
    this.acceptedAt,
    this.completedAt,
    this.updatedAt,
  });

  factory Swap.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Swap(
      id: doc.id,
      requesterId: data['requesterId'] ?? '',
      requesterName: data['requesterName'] ?? '',
      requesterBookId: data['requesterBookId'] ?? '',
      requesterBookTitle: data['requesterBookTitle'] ?? '',
      recipientId: data['recipientId'] ?? '',
      recipientName: data['recipientName'] ?? '',
      recipientBookId: data['recipientBookId'] ?? '',
      recipientBookTitle: data['recipientBookTitle'] ?? '',
      status: SwapStatusExtension.fromString(data['status'] ?? 'pending'),
      chatId: data['chatId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'requesterId': requesterId,
      'requesterName': requesterName,
      'requesterBookId': requesterBookId,
      'requesterBookTitle': requesterBookTitle,
      'recipientId': recipientId,
      'recipientName': recipientName,
      'recipientBookId': recipientBookId,
      'recipientBookTitle': recipientBookTitle,
      'status': status.toFirestore(),
      'chatId': chatId,
      'createdAt': Timestamp.fromDate(createdAt),
      'acceptedAt': acceptedAt != null ? Timestamp.fromDate(acceptedAt!) : null,
      'completedAt': completedAt != null
          ? Timestamp.fromDate(completedAt!)
          : null,
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Swap copyWith({
    String? id,
    String? requesterId,
    String? requesterName,
    String? requesterBookId,
    String? requesterBookTitle,
    String? recipientId,
    String? recipientName,
    String? recipientBookId,
    String? recipientBookTitle,
    SwapStatus? status,
    String? chatId,
    DateTime? createdAt,
    DateTime? acceptedAt,
    DateTime? completedAt,
    DateTime? updatedAt,
  }) {
    return Swap(
      id: id ?? this.id,
      requesterId: requesterId ?? this.requesterId,
      requesterName: requesterName ?? this.requesterName,
      requesterBookId: requesterBookId ?? this.requesterBookId,
      requesterBookTitle: requesterBookTitle ?? this.requesterBookTitle,
      recipientId: recipientId ?? this.recipientId,
      recipientName: recipientName ?? this.recipientName,
      recipientBookId: recipientBookId ?? this.recipientBookId,
      recipientBookTitle: recipientBookTitle ?? this.recipientBookTitle,
      status: status ?? this.status,
      chatId: chatId ?? this.chatId,
      createdAt: createdAt ?? this.createdAt,
      acceptedAt: acceptedAt ?? this.acceptedAt,
      completedAt: completedAt ?? this.completedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
