// ignore_for_file: deprecated_member_use

import 'package:bookswap/core/theme/app_theme.dart';
import 'package:bookswap/models/book.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/book_card.dart';

/// Select book screen
/// Allows user to select one of their available books to offer for a swap
class SelectBookScreen extends ConsumerStatefulWidget {
  final Book targetBook;

  const SelectBookScreen({super.key, required this.targetBook});

  @override
  ConsumerState<SelectBookScreen> createState() => _SelectBookScreenState();
}

class _SelectBookScreenState extends ConsumerState<SelectBookScreen> {
  bool _isLoading = false;
  List<Book> _availableBooks = [];

  @override
  void initState() {
    super.initState();
    _loadAvailableBooks();
  }

  /// Load user's available books
  Future<void> _loadAvailableBooks() async {
    try {
      final bookService = ref.read(bookServiceProvider);
      final currentUser = ref.read(authServiceProvider).currentUser;

      if (currentUser != null) {
        final books = await bookService.getUserAvailableBooks(currentUser.uid);
        if (mounted) {
          setState(() {
            _availableBooks = books;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading books: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle swap creation
  Future<void> _createSwap(Book offeredBook) async {
    setState(() => _isLoading = true);

    try {
      final swapService = ref.read(swapServiceProvider);
      await swapService.createSwap(
        recipientBookId: widget.targetBook.id,
        offeredBookId: offeredBook.id,
      );

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Swap offer sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back to home
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error creating swap: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: const Text('Select a Book to Offer')),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation(AppTheme.accentYellow),
              ),
            )
          : Column(
              children: [
                // Target book info
                Container(
                  padding: const EdgeInsets.all(16),
                  color: Theme.of(context).cardTheme.color,
                  child: Row(
                    children: [
                      const Icon(
                        Icons.swap_horiz,
                        color: AppTheme.accentYellow,
                        size: 34,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'You want to swap for:',
                              style: TextStyle(
                                fontSize: 17,
                                color: AppTheme.accentYellow,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              widget.targetBook.title,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.primaryNavy,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'by ${widget.targetBook.author}',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color.fromARGB(255, 108, 108, 110),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    'Select one of your books to offer:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.accentYellow,
                    ),
                  ),
                ),
                // Available books list
                Expanded(
                  child: _availableBooks.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.library_books_outlined,
                                size: 80,
                                color: AppTheme.textGray.withOpacity(0.5),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'No available books to offer',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: AppTheme.primaryNavy,
                                ),
                              ),
                              const SizedBox(height: 8),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 32),
                                child: Text(
                                  'Add some books to your listings first',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Color.fromARGB(255, 77, 78, 79),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _availableBooks.length,
                          itemBuilder: (context, index) {
                            final book = _availableBooks[index];
                            return Padding(
                              padding: const EdgeInsets.only(
                                bottom: 12,
                              ), // spacing between cards
                              child: BookCardList(
                                book: book,
                                showOwner: false,
                                onTap: () {
                                  // Show confirmation dialog
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      backgroundColor: Theme.of(
                                        context,
                                      ).cardTheme.color,
                                      title: const Text(
                                        'Confirm Swap Offer',
                                        style: TextStyle(
                                          color: AppTheme.primaryNavy,
                                        ),
                                      ),
                                      content: Text(
                                        'Offer "${book.title}" for "${widget.targetBook.title}"?',
                                        style: const TextStyle(
                                          color: Color.fromARGB(
                                            255,
                                            70,
                                            72,
                                            73,
                                          ),
                                        ),
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () =>
                                              Navigator.pop(context),
                                          child: const Text(
                                            'Cancel',
                                            style: TextStyle(
                                              color: AppTheme.primaryNavy,
                                            ),
                                          ),
                                        ),
                                        ElevatedButton(
                                          onPressed: () {
                                            Navigator.pop(context);
                                            _createSwap(book);
                                          },
                                          child: const Text('Confirm'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
}
