// Remember to remove unused code

// ignore_for_file: deprecated_member_use

import 'package:bookswap/core/theme/app_theme.dart';
import 'package:bookswap/models/book.dart';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;

/// Book card widget for list view - matching the BookSwap UI design
class BookCardList extends StatelessWidget {
  final Book book;
  final VoidCallback onTap;
  final bool showOwner;

  const BookCardList({
    super.key,
    required this.book,
    required this.onTap,
    this.showOwner = true,
  });

  // Color _getConditionColor() {
  //   switch (book.condition.toLowerCase()) {
  //     case 'new':
  //       return const Color(0xFF10B981); // green
  //     case 'like new':
  //       return const Color(0xFF3B82F6); // blue
  //     case 'good':
  //       return const Color(0xFFF59E0B); // amber
  //     case 'used':
  //       return const Color(0xFFEF4444); // red
  //     default:
  //       return Colors.grey;
  //   }
  // }

  String _getTimeAgo() => timeago.format(book.createdAt, locale: 'en_short');

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Book cover
            ClipRRect(
              borderRadius: BorderRadius.circular(1),
              child: CachedNetworkImage(
                imageUrl: book.coverUrl ?? '',
                width: 110,
                height: 125,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: 110,
                  height: 125,
                  color: AppTheme.primaryNavy,
                  child: const Icon(Icons.menu_book, color: Colors.white70),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 110,
                  height: 125,
                  color: AppTheme.primaryNavy,
                  child: const Icon(Icons.menu_book, color: Colors.white70),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Book details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title
                  Text(
                    book.title,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Author
                  Text(
                    book.author,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color.fromARGB(255, 92, 94, 97),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  // Condition badge
                  Container(
                    padding: const EdgeInsets.symmetric(
                      // horizontal: 8,
                      vertical: 3,
                    ),
                    // decoration: BoxDecoration(
                    //   color: _getConditionColor().withOpacity(0.15),
                    //   borderRadius: BorderRadius.circular(6),
                    // ),
                    child: Text(
                      book.condition,
                      style: TextStyle(
                        color: AppTheme.primaryNavy,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),

                  // Time ago
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 15,
                        color: Color.fromARGB(255, 38, 39, 41),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${_getTimeAgo()} Ago',
                        style: const TextStyle(
                          color: Color.fromARGB(255, 38, 39, 41),
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
