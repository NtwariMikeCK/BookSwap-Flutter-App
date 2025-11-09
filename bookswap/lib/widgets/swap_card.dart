// ignore_for_file: deprecated_member_use

import 'package:bookswap/core/theme/app_theme.dart';
import 'package:bookswap/models/book.dart';
import 'package:bookswap/models/swap.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';

/// Swap card widget
/// Displays swap information with action buttons
class SwapCard extends ConsumerWidget {
  final Swap swap;
  final bool isRequester;

  const SwapCard({super.key, required this.swap, required this.isRequester});

  /// Get status color
  Color _getStatusColor() {
    switch (swap.status) {
      case 'pending':
        return Colors.orange;
      case 'accepted':
        return Colors.green;
      case 'declined':
        return Colors.red;
      case 'cancelled':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  /// Handle accept swap
  Future<void> _handleAccept(BuildContext context, WidgetRef ref) async {
    try {
      final swapService = ref.read(swapServiceProvider);
      await swapService.acceptSwap(swap.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Swap accepted!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle decline swap
  Future<void> _handleDecline(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: const Text(
          'Decline Swap',
          style: TextStyle(color: AppTheme.textWhite),
        ),
        content: const Text(
          'Are you sure you want to decline this swap offer?',
          style: TextStyle(color: AppTheme.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppTheme.textGray),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Decline'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final swapService = ref.read(swapServiceProvider);
      await swapService.declineSwap(swap.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Swap declined'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handle cancel swap
  Future<void> _handleCancel(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: const Text(
          'Cancel Swap',
          style: TextStyle(color: AppTheme.textWhite),
        ),
        content: const Text(
          'Are you sure you want to cancel this swap request?',
          style: TextStyle(color: AppTheme.textGray),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No', style: TextStyle(color: AppTheme.textGray)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Cancel Swap'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      final swapService = ref.read(swapServiceProvider);
      await swapService.cancelSwap(swap.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Swap cancelled'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requesterBookAsync = ref.watch(
      bookDetailProvider(swap.requesterBookId),
    );
    final recipientBookAsync = ref.watch(
      bookDetailProvider(swap.recipientBookId),
    );
    final otherUserId = isRequester ? swap.recipientId : swap.requesterId;
    final otherUserAsync = ref.watch(userProfileProvider(otherUserId));

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: Theme.of(context).cardTheme.color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Other user name
                otherUserAsync.when(
                  data: (user) => Row(
                    children: [
                      const Icon(
                        Icons.person,
                        size: 20,
                        color: AppTheme.textGray,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        user?.name ?? 'Unknown',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textWhite,
                        ),
                      ),
                    ],
                  ),
                  loading: () => const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                  error: (_, __) => const Text(
                    'Unknown User',
                    style: TextStyle(color: AppTheme.textGray),
                  ),
                ),
                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: _getStatusColor().withOpacity(0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: _getStatusColor(), width: 1),
                  ),
                  child: Text(
                    swap.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      color: _getStatusColor(),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Date
            Text(
              DateFormat('MMM dd, yyyy').format(swap.createdAt),
              style: const TextStyle(fontSize: 12, color: AppTheme.textGray),
            ),
            const SizedBox(height: 16),
            // Books info
            Row(
              children: [
                // My book (or their offer)
                Expanded(
                  child: isRequester
                      ? requesterBookAsync.when(
                          data: (book) =>
                              _BookInfo(title: 'Your Offer', book: book),
                          loading: () =>
                              const CircularProgressIndicator(strokeWidth: 2),
                          error: (_, __) => const Text('Error'),
                        )
                      : recipientBookAsync.when(
                          data: (book) =>
                              _BookInfo(title: 'Your Book', book: book),
                          loading: () =>
                              const CircularProgressIndicator(strokeWidth: 2),
                          error: (_, __) => const Text('Error'),
                        ),
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(Icons.swap_horiz, color: AppTheme.accentYellow),
                ),
                // Their book
                Expanded(
                  child: isRequester
                      ? recipientBookAsync.when(
                          data: (book) =>
                              _BookInfo(title: 'Their Book', book: book),
                          loading: () =>
                              const CircularProgressIndicator(strokeWidth: 2),
                          error: (_, __) => const Text('Error'),
                        )
                      : requesterBookAsync.when(
                          data: (book) =>
                              _BookInfo(title: 'Their Offer', book: book),
                          loading: () =>
                              const CircularProgressIndicator(strokeWidth: 2),
                          error: (_, __) => const Text('Error'),
                        ),
                ),
              ],
            ),
            // Action buttons for incoming offers
            if (!isRequester && swap.status == 'pending') ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _handleDecline(context, ref),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      child: const Text('Decline'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _handleAccept(context, ref),
                      child: const Text('Accept'),
                    ),
                  ),
                ],
              ),
            ],
            // Cancel button for my pending requests
            if (isRequester && swap.status == 'pending') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => _handleCancel(context, ref),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                  ),
                  child: const Text('Cancel Request'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Book info widget for swap card
class _BookInfo extends StatelessWidget {
  final String title;
  final Book? book;

  const _BookInfo({required this.title, required this.book});

  @override
  Widget build(BuildContext context) {
    if (book == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppTheme.textGray),
          ),
          const SizedBox(height: 4),
          const Text(
            'Book not found',
            style: TextStyle(fontSize: 14, color: Colors.red),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 12, color: AppTheme.textGray),
        ),
        const SizedBox(height: 4),
        Text(
          book!.title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.textWhite,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),
        Text(
          book!.author,
          style: const TextStyle(fontSize: 12, color: AppTheme.textGray),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
