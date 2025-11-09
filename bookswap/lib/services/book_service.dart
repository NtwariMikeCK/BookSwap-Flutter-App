import 'dart:io';
import 'package:bookswap/models/book.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloudinary_public/cloudinary_public.dart';

/// Book service handling CRUD operations for books
class BookService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // setup for cloudinary
  final CloudinaryPublic _cloudinary = CloudinaryPublic(
    'dfpxfdvli',
    'Bookswap flutter app',
    cache: false,
  );

  /// Upload image to Cloudinary and get URL
  Future<String> _uploadCoverToCloudinary(File imageFile) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(imageFile.path, folder: 'book_covers'),
      );
      return response.secureUrl;
    } catch (e) {
      throw Exception('Failed to upload image: $e');
    }
  }

  /// Create a new book listing
  Future<String> createBook({
    required String title,
    required String author,
    required String condition,
    String? description,
    File? coverImage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Get user profile for owner name
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      final userName = userDoc.data()?['name'] as String? ?? 'Unknown';

      // Upload cover image if provided
      String? coverUrl;
      if (coverImage != null) {
        coverUrl = await _uploadCoverToCloudinary(coverImage);
      }

      // Create book document
      final bookRef = await _firestore.collection('books').add({
        'title': title,
        'author': author,
        'condition': condition,
        'description': description,
        'ownerId': user.uid,
        'ownerName': userName,
        'coverUrl': coverUrl,
        'status': 'available',
        'createdAt': FieldValue.serverTimestamp(),
      });

      return bookRef.id;
    } catch (e) {
      rethrow;
    }
  }

  /// Update an existing book
  Future<void> updateBook({
    required String bookId,
    String? title,
    String? author,
    String? condition,
    String? description,
    File? coverImage,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify ownership
      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      if (!bookDoc.exists) throw Exception('Book not found');
      if (bookDoc.data()?['ownerId'] != user.uid) {
        throw Exception('Not authorized to update this book');
      }

      // Upload new cover image if provided
      String? coverUrl;
      if (coverImage != null) {
        coverUrl = await _uploadCoverToCloudinary(coverImage);
      }

      // String? coverUrl;
      // if (coverImage != null) {
      //   final fileName = '${DateTime.now().millisecondsSinceEpoch}.jpg';
      //   final ref = _storage.ref().child('book_covers/${user.uid}/$fileName');
      //   await ref.putFile(coverImage);
      //   coverUrl = await ref.getDownloadURL();
      // }

      // Update book document
      final updateData = <String, dynamic>{};
      if (title != null) updateData['title'] = title;
      if (author != null) updateData['author'] = author;
      if (condition != null) updateData['condition'] = condition;
      if (description != null) updateData['description'] = description;
      if (coverUrl != null) updateData['coverUrl'] = coverUrl;

      if (updateData.isNotEmpty) {
        await _firestore.collection('books').doc(bookId).update(updateData);
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Delete a book
  Future<void> deleteBook(String bookId) async {
    try {
      final user = _auth.currentUser;
      if (user == null) throw Exception('User not authenticated');

      // Verify ownership
      final bookDoc = await _firestore.collection('books').doc(bookId).get();
      if (!bookDoc.exists) throw Exception('Book not found');
      if (bookDoc.data()?['ownerId'] != user.uid) {
        throw Exception('Not authorized to delete this book');
      }

      // Check if book is in a pending swap
      final status = bookDoc.data()?['status'] as String? ?? 'available';
      if (status == 'pending') {
        throw Exception('Cannot delete a book that is part of a pending swap');
      }

      // Delete book document
      await _firestore.collection('books').doc(bookId).delete();

      // Note: Cover image could be deleted from storage, but we'll keep it for simplicity
    } catch (e) {
      rethrow;
    }
  }

  /// Get book by ID
  Future<Book?> getBook(String bookId) async {
    try {
      final doc = await _firestore.collection('books').doc(bookId).get();
      if (!doc.exists) return null;
      return Book.fromFirestore(doc);
    } catch (e) {
      rethrow;
    }
  }

  /// Get user's available books (for swap offering)
  Future<List<Book>> getUserAvailableBooks(String userId) async {
    try {
      final snapshot = await _firestore
          .collection('books')
          .where('ownerId', isEqualTo: userId)
          .where('status', isEqualTo: 'available')
          .get();

      return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
