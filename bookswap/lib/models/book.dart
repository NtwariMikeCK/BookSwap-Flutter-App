import 'package:cloud_firestore/cloud_firestore.dart';

enum BookCondition { newCondition, likenew, good, used }

extension BookConditionExtension on BookCondition {
  String get displayName {
    switch (this) {
      case BookCondition.newCondition:
        return 'New';
      case BookCondition.likenew:
        return 'Like New';
      case BookCondition.good:
        return 'Good';
      case BookCondition.used:
        return 'Used';
    }
  }

  String toFirestore() {
    return toString().split('.').last;
  }

  static BookCondition fromString(String value) {
    return BookCondition.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => BookCondition.good,
    );
  }
}

enum BookStatus {
  available, // Book is available for swapping
  pending, // Book is part of a pending swap offer
  swapped, // Book has been successfully swapped
  archived, // Book is archived by owner
}

extension BookStatusExtension on BookStatus {
  String get displayName {
    switch (this) {
      case BookStatus.available:
        return 'Available';
      case BookStatus.pending:
        return 'Pending Swap';
      case BookStatus.swapped:
        return 'Swapped';
      case BookStatus.archived:
        return 'Archived';
    }
  }

  String toFirestore() {
    return toString().split('.').last;
  }

  static BookStatus fromString(String value) {
    return BookStatus.values.firstWhere(
      (e) => e.toString().split('.').last == value,
      orElse: () => BookStatus.available,
    );
  }
}

class Book {
  final String id;
  final String title;
  final String author;
  final String ownerId;
  final String ownerName;
  final BookCondition condition;
  final String? description;
  final String? coverUrl;
  final BookStatus status;
  final String? currentSwapId; // Reference to active swap if in pending state
  final DateTime createdAt;
  final DateTime? updatedAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.ownerId,
    required this.ownerName,
    required this.condition,
    this.description,
    this.coverUrl,
    required this.status,
    this.currentSwapId,
    required this.createdAt,
    this.updatedAt,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      ownerId: data['ownerId'] ?? '',
      ownerName: data['ownerName'] ?? '',
      condition: BookConditionExtension.fromString(data['condition'] ?? 'good'),
      description: data['description'],
      coverUrl: data['coverUrl'],
      status: BookStatusExtension.fromString(data['status'] ?? 'available'),
      currentSwapId: data['currentSwapId'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'condition': condition.toFirestore(),
      'description': description,
      'coverUrl': coverUrl,
      'status': status.toFirestore(),
      'currentSwapId': currentSwapId,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? ownerId,
    String? ownerName,
    BookCondition? condition,
    String? description,
    String? coverUrl,
    BookStatus? status,
    String? currentSwapId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      coverUrl: coverUrl ?? this.coverUrl,
      status: status ?? this.status,
      currentSwapId: currentSwapId ?? this.currentSwapId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
