import 'package:bookswap/models/person.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

final currentUserProfileProvider = StreamProvider<UserProfile?>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value(null);

  return FirebaseFirestore.instance
      .collection('users')
      .doc(user.uid)
      .snapshots()
      .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = userCredential.user;
    if (user != null) {
      await user.sendEmailVerification();

      await _firestore.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'photoUrl': null,
        'emailVerified':
            user.emailVerified, // Add initial email verification status
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return user;
  }

  /// New method to sync email verification status from Firebase Auth to Firestore
  Future<void> syncEmailVerificationStatus() async {
    final user = _auth.currentUser;
    if (user != null) {
      await user.reload(); // Refreshes user info from Firebase Auth
      if (user.emailVerified) {
        await _firestore.collection('users').doc(user.uid).update({
          'emailVerified': true,
        });
      }
    }
  }

  Future<User?> signIn({
    required String email,
    required String password,
  }) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // Sync email verification status on login
    await syncEmailVerificationStatus();

    return userCredential.user;
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  User? get currentUser => _auth.currentUser;
}

final authServiceProvider = Provider((ref) => AuthService());
