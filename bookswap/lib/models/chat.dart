import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String id;
  final List<String> participants;
  final String? relatedSwapId;
  final String? lastMessage;
  final DateTime? lastUpdated;

  Chat({
    required this.id,
    required this.participants,
    this.relatedSwapId,
    this.lastMessage,
    this.lastUpdated,
  });

  factory Chat.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chat(
      id: doc.id,
      participants: List<String>.from(data['participants'] as List? ?? []),
      relatedSwapId: data['relatedSwapId'] as String?,
      lastMessage: data['lastMessage'] as String?,
      lastUpdated: (data['lastUpdated'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'participants': participants,
      'relatedSwapId': relatedSwapId,
      'lastMessage': lastMessage,
      'lastUpdated': lastUpdated != null
          ? Timestamp.fromDate(lastUpdated!)
          : null,
    };
  }
}
