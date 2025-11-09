// ignore_for_file: deprecated_member_use

import 'package:bookswap/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/swap_card.dart';

/// My swaps screen
/// Shows swap requests initiated by user and incoming offers
class MySwapsScreen extends ConsumerStatefulWidget {
  const MySwapsScreen({super.key});

  @override
  ConsumerState<MySwapsScreen> createState() => _MySwapsScreenState();
}

class _MySwapsScreenState extends ConsumerState<MySwapsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('My Swaps'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentYellow,
          labelColor: AppTheme.accentYellow,
          unselectedLabelColor: AppTheme.textGray,
          tabs: const [
            Tab(text: 'My Requests'),
            Tab(text: 'Incoming Offers'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // My requests tab
          _MyRequestsTab(),
          // Incoming offers tab
          _IncomingOffersTab(),
        ],
      ),
    );
  }
}

/// My requests tab - swaps I initiated
class _MyRequestsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final swapsAsync = ref.watch(mySwapsProvider);

    return swapsAsync.when(
      data: (swaps) {
        if (swaps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.swap_horiz,
                  size: 80,
                  color: AppTheme.textGray.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No swap requests yet',
                  style: TextStyle(fontSize: 18, color: AppTheme.textGray),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Browse books and offer a swap!',
                  style: TextStyle(fontSize: 14, color: AppTheme.textGray),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index];
            return SwapCard(swap: swap, isRequester: true);
          },
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
                'Error loading swaps',
                style: TextStyle(fontSize: 18, color: AppTheme.textWhite),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppTheme.textGray),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Incoming offers tab - swaps for my books
class _IncomingOffersTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final swapsAsync = ref.watch(incomingSwapsProvider);

    return swapsAsync.when(
      data: (swaps) {
        if (swaps.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.inbox_outlined,
                  size: 80,
                  color: AppTheme.textGray.withOpacity(0.5),
                ),
                const SizedBox(height: 16),
                const Text(
                  'No incoming offers',
                  style: TextStyle(fontSize: 18, color: AppTheme.textGray),
                ),
                const SizedBox(height: 8),
                const Text(
                  'You\'ll see offers for your books here',
                  style: TextStyle(fontSize: 14, color: AppTheme.textGray),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: swaps.length,
          itemBuilder: (context, index) {
            final swap = swaps[index];
            return SwapCard(swap: swap, isRequester: false);
          },
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
                'Error loading offers',
                style: TextStyle(fontSize: 18, color: AppTheme.textWhite),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: AppTheme.textGray),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
