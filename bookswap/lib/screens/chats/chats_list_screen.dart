// ignore_for_file: deprecated_member_use

import 'package:bookswap/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../providers/providers.dart';
import 'chat_screen.dart';

/// Chats list screen
/// Shows all active chats for the current user
class ChatsListScreen extends ConsumerWidget {
  const ChatsListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final chatsAsync = ref.watch(myChatsProvider);
    final currentUserAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Chats'),
        automaticallyImplyLeading: false,
      ),
      body: chatsAsync.when(
        data: (chats) {
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: AppTheme.textGray.withOpacity(0.5),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'No chats yet',
                    style: TextStyle(fontSize: 18, color: AppTheme.textGray),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 48),
                    child: Text(
                      'Chats are created automatically when you start a swap with someone',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14, color: AppTheme.textGray),
                    ),
                  ),
                ],
              ),
            );
          }

          return currentUserAsync.when(
            data: (currentUser) {
              if (currentUser == null) {
                return const Center(
                  child: Text(
                    'Please log in to view chats',
                    style: TextStyle(color: AppTheme.textGray),
                  ),
                );
              }

              return ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: chats.length,
                itemBuilder: (context, index) {
                  final chat = chats[index];

                  // Get other user ID
                  final otherUserId = chat.participants.firstWhere(
                    (id) => id != currentUser.uid,
                    orElse: () => '',
                  );

                  if (otherUserId.isEmpty) {
                    return const SizedBox.shrink();
                  }

                  // Watch other user profile
                  final otherUserAsync = ref.watch(
                    userProfileProvider(otherUserId),
                  );

                  return otherUserAsync.when(
                    data: (otherUser) {
                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        color: Theme.of(context).cardTheme.color,
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.accentYellow,
                            child: Text(
                              (otherUser?.name ?? 'U')
                                  .substring(0, 1)
                                  .toUpperCase(),
                              style: const TextStyle(
                                color: AppTheme.primaryNavy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          title: Text(
                            otherUser?.name ?? 'Unknown User',
                            style: const TextStyle(
                              color: AppTheme.textWhite,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: chat.lastMessage != null
                              ? Text(
                                  chat.lastMessage!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: AppTheme.textGray,
                                  ),
                                )
                              : const Text(
                                  'Start a conversation',
                                  style: TextStyle(
                                    color: AppTheme.textGray,
                                    fontStyle: FontStyle.italic,
                                  ),
                                ),
                          trailing: chat.lastUpdated != null
                              ? Text(
                                  _formatTimestamp(chat.lastUpdated!),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: AppTheme.textGray,
                                  ),
                                )
                              : null,
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (_) => ChatScreen(
                                  chatId: chat.id,
                                  otherUserId: otherUserId,
                                ),
                              ),
                            );
                          },
                        ),
                      );
                    },
                    loading: () => Card(
                      margin: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      color: Theme.of(context).cardTheme.color,
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: AppTheme.textGray,
                        ),
                        title: Text(
                          'Loading...',
                          style: TextStyle(color: AppTheme.textGray),
                        ),
                      ),
                    ),
                    error: (_, __) => const SizedBox.shrink(),
                  );
                },
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
                  'Error loading chats',
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

  /// Format timestamp for display
  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays == 0) {
      return DateFormat('HH:mm').format(timestamp);
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return DateFormat('EEE').format(timestamp);
    } else {
      return DateFormat('MMM dd').format(timestamp);
    }
  }
}
