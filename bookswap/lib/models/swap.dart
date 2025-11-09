import 'package:cloud_firestore/cloud_firestore.dart';

/// Swap model
class Swap {
  final String id;
  final String requesterId;
  final String requesterBookId;
  final String recipientId;
  final String recipientBookId;
  final String status; // pending, accepted, declined, completed
  final DateTime createdAt;

  Swap({
    required this.id,
    required this.requesterId,
    required this.requesterBookId,
    required this.recipientId,
    required this.recipientBookId,
    required this.status,
    required this.createdAt,
  });

  factory Swap.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Swap(
      id: doc.id,
      requesterId: data['requesterId'] as String? ?? '',
      requesterBookId: data['requesterBookId'] as String? ?? '',
      recipientId: data['recipientId'] as String? ?? '',
      recipientBookId: data['recipientBookId'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'requesterId': requesterId,
      'requesterBookId': requesterBookId,
      'recipientId': recipientId,
      'recipientBookId': recipientBookId,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
