import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/swap_provider.dart';
import '../../providers/auth_provider.dart';
import '../../core/theme/app_theme.dart';
import '../../models/swap.dart';
import '../chats/chat_conversation_screen.dart';

class SwapDetailsScreen extends ConsumerWidget {
  final String swapId;

  const SwapDetailsScreen({super.key, required this.swapId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final swapAsync = ref.watch(swapByIdProvider(swapId));
    final currentUser = ref.read(authStateProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('Swap Details')),
      body: swapAsync.when(
        data: (swap) {
          if (swap == null) {
            return const Center(child: Text('Swap not found'));
          }

          final isRecipient = currentUser?.uid == swap.recipientId;
          final canAccept = isRecipient && swap.status == SwapStatus.pending;
          final canDecline = isRecipient && swap.status == SwapStatus.pending;
          final canCancel = !isRecipient && swap.status == SwapStatus.pending;
          final canMarkComplete = swap.status == SwapStatus.accepted;
          final canOpenChat = swap.chatId != null;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Status Banner
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  color: _getStatusColor(swap.status).withOpacity(0.1),
                  child: Column(
                    children: [
                      Icon(
                        _getStatusIcon(swap.status),
                        size: 48,
                        color: _getStatusColor(swap.status),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        swap.status.displayName,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: _getStatusColor(swap.status),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Participants
                      const Text(
                        'Swap Between',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildParticipantCard(
                        name: swap.requesterName,
                        role: 'Requester',
                        isCurrentUser: currentUser?.uid == swap.requesterId,
                      ),
                      const SizedBox(height: 8),
                      _buildParticipantCard(
                        name: swap.recipientName,
                        role: 'Recipient',
                        isCurrentUser: currentUser?.uid == swap.recipientId,
                      ),
                      const SizedBox(height: 24),

                      // Books Being Swapped
                      const Text(
                        'Books',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Expanded(
                            child: _buildBookInfo(
                              title: swap.requesterBookTitle,
                              label: '${swap.requesterName}\'s book',
                            ),
                          ),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 12),
                            child: Icon(
                              Icons.swap_horiz,
                              color: AppColors.secondary,
                              size: 32,
                            ),
                          ),
                          Expanded(
                            child: _buildBookInfo(
                              title: swap.recipientBookTitle,
                              label: '${swap.recipientName}\'s book',
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // Timeline
                      const Text(
                        'Timeline',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildTimelineItem(
                        'Created',
                        DateFormat(
                          'MMM d, yyyy • HH:mm',
                        ).format(swap.createdAt),
                        isCompleted: true,
                      ),
                      if (swap.acceptedAt != null)
                        _buildTimelineItem(
                          'Accepted',
                          DateFormat(
                            'MMM d, yyyy • HH:mm',
                          ).format(swap.acceptedAt!),
                          isCompleted: true,
                        ),
                      if (swap.completedAt != null)
                        _buildTimelineItem(
                          'Completed',
                          DateFormat(
                            'MMM d, yyyy • HH:mm',
                          ).format(swap.completedAt!),
                          isCompleted: true,
                        ),
                      const SizedBox(height: 32),

                      // Actions
                      if (canOpenChat) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => ChatConversationScreen(
                                    chatId: swap.chatId!,
                                    otherUserName: isRecipient
                                        ? swap.requesterName
                                        : swap.recipientName,
                                  ),
                                ),
                              );
                            },
                            icon: const Icon(Icons.chat_bubble_outline),
                            label: const Text('Open Chat'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.primary,
                              side: const BorderSide(color: AppColors.primary),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (canAccept) ...[
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Accept Swap'),
                                  content: const Text(
                                    'Are you sure you want to accept this swap offer? Both books will be marked as swapped.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      child: const Text('Accept'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && context.mounted) {
                                try {
                                  await ref
                                      .read(swapServiceProvider)
                                      .acceptSwap(swap);
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
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            child: const Text('Accept Swap'),
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],

                      if (canDecline)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Decline Swap'),
                                  content: const Text(
                                    'Are you sure you want to decline this swap offer? Both books will be available again.',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Decline'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && context.mounted) {
                                try {
                                  await ref
                                      .read(swapServiceProvider)
                                      .declineSwap(swap);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Swap declined'),
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('Decline'),
                          ),
                        ),

                      if (canCancel)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: OutlinedButton(
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Cancel Swap'),
                                  content: const Text(
                                    'Are you sure you want to cancel this swap offer?',
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(false),
                                      child: const Text('No'),
                                    ),
                                    TextButton(
                                      onPressed: () =>
                                          Navigator.of(context).pop(true),
                                      style: TextButton.styleFrom(
                                        foregroundColor: Colors.red,
                                      ),
                                      child: const Text('Cancel Swap'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && context.mounted) {
                                try {
                                  await ref
                                      .read(swapServiceProvider)
                                      .cancelSwap(swap);
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Swap cancelled'),
                                      ),
                                    );
                                    Navigator.of(context).pop();
                                  }
                                } catch (e) {
                                  if (context.mounted) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text('Error: ${e.toString()}'),
                                      ),
                                    );
                                  }
                                }
                              }
                            },
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.red,
                              side: const BorderSide(color: Colors.red),
                            ),
                            child: const Text('Cancel Swap'),
                          ),
                        ),

                      if (canMarkComplete)
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: () async {
                              await ref
                                  .read(swapServiceProvider)
                                  .markSwapCompleted(swap);
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Swap marked as completed!'),
                                    backgroundColor: Colors.green,
                                  ),
                                );
                              }
                            },
                            child: const Text('Mark as Completed'),
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
        error: (error, stack) => Center(child: Text('Error: $error')),
      ),
    );
  }

  Widget _buildParticipantCard({
    required String name,
    required String role,
    required bool isCurrentUser,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primary,
            child: Text(
              name.isNotEmpty ? name[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.secondary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          'You',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  role,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBookInfo({required String title, required String label}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.secondary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTimelineItem(
    String title,
    String time, {
    bool isCompleted = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: isCompleted ? Colors.green : Colors.grey[300],
              shape: BoxShape.circle,
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(SwapStatus status) {
    switch (status) {
      case SwapStatus.pending:
        return Colors.orange;
      case SwapStatus.accepted:
        return Colors.green;
      case SwapStatus.declined:
        return Colors.red;
      case SwapStatus.completed:
        return Colors.blue;
      case SwapStatus.cancelled:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon(SwapStatus status) {
    switch (status) {
      case SwapStatus.pending:
        return Icons.hourglass_empty;
      case SwapStatus.accepted:
        return Icons.check_circle;
      case SwapStatus.declined:
        return Icons.cancel;
      case SwapStatus.completed:
        return Icons.verified;
      case SwapStatus.cancelled:
        return Icons.block;
    }
  }
}
