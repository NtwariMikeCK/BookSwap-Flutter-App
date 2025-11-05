import 'package:cloud_firestore/cloud_firestore.dart';

class UserProfile {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;
  final bool emailVerified;
  final bool notificationReminders;
  final bool emailUpdates;
  final DateTime createdAt;
  final DateTime? updatedAt;

  UserProfile({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
    this.emailVerified = false,
    this.notificationReminders = true,
    this.emailUpdates = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserProfile.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserProfile(
      uid: data['uid'],
      name: data['name'],
      email: data['email'],
      photoUrl: data['photoUrl'] ?? '',
      emailVerified: data['emailVerified'] ?? false,
      notificationReminders: data['notificationReminders'] ?? true,
      emailUpdates: data['emailUpdates'] ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'email': email,
      'photoUrl': photoUrl,
      'emailVerified': emailVerified,
      'notificationReminders': notificationReminders,
      'emailUpdates': emailUpdates,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': updatedAt != null ? Timestamp.fromDate(updatedAt!) : null,
    };
  }

  UserProfile copyWith({
    String? name,
    String? photoUrl,
    bool? emailVerified,
    bool? notificationReminders,
    bool? emailUpdates,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserProfile(
      uid: uid,
      name: name ?? this.name,
      email: email,
      photoUrl: photoUrl ?? this.photoUrl,
      emailVerified: emailVerified ?? this.emailVerified,
      notificationReminders:
          notificationReminders ?? this.notificationReminders,
      emailUpdates: emailUpdates ?? this.emailUpdates,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
