// ignore_for_file: deprecated_member_use

import 'package:bookswap/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../providers/providers.dart';
import 'select_book_screen.dart';

/// Book detail screen
/// Shows full information about a book and allows users to initiate swaps
class BookDetailScreen extends ConsumerWidget {
  final String bookId;

  const BookDetailScreen({super.key, required this.bookId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bookAsync = ref.watch(bookDetailProvider(bookId));
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Book Details', style: TextStyle(fontSize: 25)),
      ),
      body: bookAsync.when(
        data: (book) {
          if (book == null) {
            return const Center(
              child: Text(
                'Book not found',
                style: TextStyle(fontSize: 18, color: AppTheme.textGray),
              ),
            );
          }

          return currentUserAsync.when(
            data: (currentUser) {
              final isMyBook = currentUser?.uid == book.ownerId;
              final canSwap = !isMyBook && book.status == 'available';

              return SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Book cover image
                    Container(
                      height: 300,
                      width: double.infinity,
                      color: AppTheme.primaryNavy,
                      child: book.coverUrl != null && book.coverUrl!.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: book.coverUrl!,
                              fit: BoxFit.contain,
                              placeholder: (context, url) => const Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation(
                                    AppTheme.accentYellow,
                                  ),
                                ),
                              ),
                              errorWidget: (context, url, error) => const Icon(
                                Icons.menu_book,
                                size: 100,
                                color: AppTheme.textGray,
                              ),
                            )
                          : const Icon(
                              Icons.menu_book,
                              size: 100,
                              color: AppTheme.textGray,
                            ),
                    ),
                    // Book information
                    Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Title
                          Text(
                            book.title,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: 8),
                          // Author
                          Text(
                            'by ${book.author}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Color.fromARGB(255, 92, 94, 97),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Condition
                          Row(
                            children: [
                              const Text(
                                'Condition: ',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: AppTheme.accentYellow.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: AppTheme.accentYellow,
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  book.condition,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: AppTheme.accentYellow,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Owner
                          Row(
                            children: [
                              const Icon(
                                Icons.person_outline,
                                size: 20,
                                color: AppTheme.primaryNavy,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Owner: ${book.ownerName ?? 'Unknown'}',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          // Status
                          Row(
                            children: [
                              Icon(
                                book.status == 'available'
                                    ? Icons.check_circle_outline
                                    : Icons.pending_outlined,
                                size: 20,
                                color: book.status == 'available'
                                    ? Colors.green
                                    : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                'Status: ${book.status.toUpperCase()}',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: book.status == 'available'
                                      ? Colors.green
                                      : Colors.orange,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          if (book.description != null &&
                              book.description!.isNotEmpty) ...[
                            const SizedBox(height: 24),
                            const Text(
                              'Description',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              book.description!,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 92, 94, 97),
                                height: 1.5,
                              ),
                            ),
                          ],
                          const SizedBox(height: 32),
                          // Swap button
                          if (canSwap)
                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton.icon(
                                onPressed: () {
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          SelectBookScreen(targetBook: book),
                                    ),
                                  );
                                },
                                icon: const Icon(Icons.swap_horiz),
                                label: const Text('Offer a Swap'),
                              ),
                            )
                          else if (isMyBook)
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'This is your book',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.textGray),
                              ),
                            )
                          else
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardTheme.color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                'Book is currently ${book.status}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: AppTheme.textGray,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => const Center(
              child: Text(
                'Error loading user data',
                style: TextStyle(color: AppTheme.textGray),
              ),
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
                  'Error loading book details',
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
