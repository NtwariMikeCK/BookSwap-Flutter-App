// ignore_for_file: deprecated_member_use

import 'package:bookswap/core/theme/app_theme.dart';
import 'package:bookswap/screens/home/book_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/book_card.dart';

/// Browse listings screen - shows all available books
/// This is the main home screen of the app

class BrowseListingsScreen extends ConsumerWidget {
  const BrowseListingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(availableBooksProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Browse Listings', style: TextStyle(fontSize: 30)),
        automaticallyImplyLeading: false,
      ),
      body: booksAsync.when(
        data: (books) {
          if (books.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.menu_book_rounded,
                    size: 80,
                    color: AppTheme.textGray.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No books available yet',
                    style: TextStyle(fontSize: 18, color: AppTheme.textGray),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Be the first to list a book!',
                    style: TextStyle(fontSize: 14, color: AppTheme.textGray),
                  ),
                ],
              ),
            );
          }

          return currentUserAsync.when(
            data: (currentUser) {
              // Filter out current user's books
              final otherUsersBooks = books
                  .where((book) => book.ownerId != currentUser?.uid)
                  .toList();

              if (otherUsersBooks.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text(
                      'No other books available.\nCheck back later!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppTheme.textGray),
                    ),
                  ),
                );
              }

              return ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: otherUsersBooks.length,
                // separatorBuilder: (context, index) =>
                //     const SizedBox(height: 12),
                separatorBuilder: (context, index) => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(
                    color: Color(0xFFE5E5E5), // light gray line
                    thickness: 2,
                    height: 1,
                  ),
                ),
                itemBuilder: (context, index) {
                  final book = otherUsersBooks[index];
                  return BookCardList(
                    book: book,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => BookDetailScreen(bookId: book.id),
                        ),
                      );
                    },
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: books.length,
              // separatorBuilder: (context, index) => const SizedBox(height: 12),
              separatorBuilder: (context, index) => const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Divider(
                  color: Color(0xFFE5E5E5),
                  thickness: 1,
                  height: 1,
                ),
              ),
              itemBuilder: (context, index) {
                final book = books[index];
                return BookCardList(
                  book: book,
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => BookDetailScreen(bookId: book.id),
                      ),
                    );
                  },
                );
              },
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation(AppTheme.accentYellow),
          ),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text(
                  'Error loading books',
                  style: TextStyle(fontSize: 18, color: AppTheme.textWhite),
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.textGray,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
