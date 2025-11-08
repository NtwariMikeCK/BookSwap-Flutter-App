import 'package:cloud_firestore/cloud_firestore.dart';

/// Book model
class Book {
  final String id;
  final String title;
  final String author;
  final String condition; // New, Like New, Good, Used
  final String? description;
  final String ownerId;
  final String? ownerName;
  final String? coverUrl;
  final String status; // available, pending, swapped
  final DateTime createdAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.condition,
    this.description,
    required this.ownerId,
    this.ownerName,
    this.coverUrl,
    required this.status,
    required this.createdAt,
  });

  factory Book.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Book(
      id: doc.id,
      title: data['title'] as String? ?? '',
      author: data['author'] as String? ?? '',
      condition: data['condition'] as String? ?? 'Good',
      description: data['description'] as String?,
      ownerId: data['ownerId'] as String? ?? '',
      ownerName: data['ownerName'] as String?,
      coverUrl: data['coverUrl'] as String?,
      status: data['status'] as String? ?? 'available',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'author': author,
      'condition': condition,
      'description': description,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'coverUrl': coverUrl,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  Book copyWith({
    String? id,
    String? title,
    String? author,
    String? condition,
    String? description,
    String? ownerId,
    String? ownerName,
    String? coverUrl,
    String? status,
    DateTime? createdAt,
  }) {
    return Book(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      condition: condition ?? this.condition,
      description: description ?? this.description,
      ownerId: ownerId ?? this.ownerId,
      ownerName: ownerName ?? this.ownerName,
      coverUrl: coverUrl ?? this.coverUrl,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
