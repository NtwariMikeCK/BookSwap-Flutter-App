import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/book.dart';
import 'auth_provider.dart';

final booksProvider = StreamProvider<List<Book>>((ref) {
  return FirebaseFirestore.instance
      .collection('books')
      .where('status', isEqualTo: BookStatus.available.toString())
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList(),
      );
});

final myBooksProvider = StreamProvider<List<Book>>((ref) {
  final user = ref.watch(authStateProvider).value;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection('books')
      .where('ownerId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map(
        (snapshot) =>
            snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList(),
      );
});

final bookByIdProvider = StreamProvider.family<Book?, String>((ref, bookId) {
  return FirebaseFirestore.instance
      .collection('books')
      .doc(bookId)
      .snapshots()
      .map((doc) => doc.exists ? Book.fromFirestore(doc) : null);
});

class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String?> uploadBookCover(File imageFile, String bookId) async {
    try {
      final ref = _storage.ref().child('book_covers/$bookId.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      return null;
    }
  }

  Future<void> createBook({
    required String title,
    required String author,
    required String ownerId,
    required String ownerName,
    required BookCondition condition,
    String? description,
    File? coverImage,
  }) async {
    final docRef = _firestore.collection('books').doc();

    String? coverUrl;
    if (coverImage != null) {
      coverUrl = await uploadBookCover(coverImage, docRef.id);
    }

    await docRef.set({
      'title': title,
      'author': author,
      'ownerId': ownerId,
      'ownerName': ownerName,
      'condition': condition.toString(),
      'description': description,
      'coverUrl': coverUrl,
      'status': BookStatus.available.toString(),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateBook({
    required String bookId,
    required String title,
    required String author,
    required BookCondition condition,
    String? description,
    File? newCoverImage,
    String? existingCoverUrl,
  }) async {
    String? coverUrl = existingCoverUrl;
    if (newCoverImage != null) {
      coverUrl = await uploadBookCover(newCoverImage, bookId);
    }

    await _firestore.collection('books').doc(bookId).update({
      'title': title,
      'author': author,
      'condition': condition.toString(),
      'description': description,
      'coverUrl': coverUrl,
    });
  }

  Future<void> deleteBook(String bookId) async {
    await _firestore.collection('books').doc(bookId).delete();

    try {
      await _storage.ref().child('book_covers/$bookId.jpg').delete();
    } catch (e) {
      // Ignore if image doesn't exist
    }
  }
}

final bookServiceProvider = Provider((ref) => BookService());
