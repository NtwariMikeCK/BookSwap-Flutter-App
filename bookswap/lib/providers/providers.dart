import 'package:bookswap/models/book.dart';
import 'package:bookswap/models/chat.dart';
import 'package:bookswap/models/message.dart';
import 'package:bookswap/models/person.dart';
import 'package:bookswap/models/swap.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For state management
import 'package:firebase_auth/firebase_auth.dart'; // For Email Password Validator
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/auth_service.dart';
import '../services/book_service.dart';
import '../services/swap_service.dart';
import '../services/chat_service.dart';

/// Service providers
final authServiceProvider = Provider<AuthService>((ref) => AuthService());
final bookServiceProvider = Provider<BookService>((ref) => BookService());
final swapServiceProvider = Provider<SwapService>((ref) => SwapService());
final chatServiceProvider = Provider<ChatService>((ref) => ChatService());

/// Current Firebase user stream
final authStateProvider = StreamProvider<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Current user profile provider
final currentUserProvider = StreamProvider<UserProfile?>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .snapshots()
          .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// All available books provider
final availableBooksProvider = StreamProvider<List<Book>>((ref) {
  return FirebaseFirestore.instance
      .collection('books')
      .where('status', isEqualTo: 'available')
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
      });
});

/// My books provider
final myBooksProvider = StreamProvider<List<Book>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return FirebaseFirestore.instance
          .collection('books')
          .where('ownerId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) => Book.fromFirestore(doc)).toList();
          });
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// My swaps provider (initiated by me)
final mySwapsProvider = StreamProvider<List<Swap>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return FirebaseFirestore.instance
          .collection('swaps')
          .where('requesterId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) => Swap.fromFirestore(doc)).toList();
          });
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Incoming swaps provider (offers for my books)
final incomingSwapsProvider = StreamProvider<List<Swap>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return FirebaseFirestore.instance
          .collection('swaps')
          .where('recipientId', isEqualTo: user.uid)
          .orderBy('createdAt', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) => Swap.fromFirestore(doc)).toList();
          });
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// My chats provider
final myChatsProvider = StreamProvider<List<Chat>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    data: (user) {
      if (user == null) return Stream.value([]);
      return FirebaseFirestore.instance
          .collection('chats')
          .where('participants', arrayContains: user.uid)
          .orderBy('lastUpdated', descending: true)
          .snapshots()
          .map((snapshot) {
            return snapshot.docs.map((doc) => Chat.fromFirestore(doc)).toList();
          });
    },
    loading: () => Stream.value([]),
    error: (_, __) => Stream.value([]),
  );
});

/// Chat messages provider
final chatMessagesProvider = StreamProvider.family<List<Message>, String>((
  ref,
  chatId,
) {
  return FirebaseFirestore.instance
      .collection('chats')
      .doc(chatId)
      .collection('messages')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
      });
});

/// Book detail provider
final bookDetailProvider = StreamProvider.family<Book?, String>((ref, bookId) {
  return FirebaseFirestore.instance
      .collection('books')
      .doc(bookId)
      .snapshots()
      .map((doc) => doc.exists ? Book.fromFirestore(doc) : null);
});

/// User profile by ID provider
final userProfileProvider = StreamProvider.family<UserProfile?, String>((
  ref,
  userId,
) {
  return FirebaseFirestore.instance
      .collection('users')
      .doc(userId)
      .snapshots()
      .map((doc) => doc.exists ? UserProfile.fromFirestore(doc) : null);
});
