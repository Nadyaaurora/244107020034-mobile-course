import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:week4_api/widgets/post_tile.dart';

import '../data/paged_posts.dart';
import '../data/network_errors.dart';

class PagedPostPage extends ConsumerStatefulWidget {
  const PagedPostPage({super.key});

  @override
  ConsumerState<PagedPostPage> createState() => _PagedPostPageState();
}

class _PagedPostPageState extends ConsumerState<PagedPostPage> {
  final _controller = ScrollController();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        ref.read(pagedPostsProvider.notifier).loadFirstPage().then((_) {
          _maybeLoadMoreIfNotScrollable();
        });
      }
    });

    _controller.addListener(() {
      if (!_controller.hasClients) return;
      final position = _controller.position;
      if (!position.hasContentDimensions) return;
      if (position.pixels >= position.maxScrollExtent - 200) {
        ref.read(pagedPostsProvider.notifier).loadNextPage();
      }
    });
  }

  void _maybeLoadMoreIfNotScrollable() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_controller.hasClients) return;
      final position = _controller.position;
      if (!position.hasContentDimensions) return;

      final state = ref.read(pagedPostsProvider);
      if (position.maxScrollExtent == 0 &&
          state.hasMore &&
          !state.isLoading &&
          !state.isLoadingMore) {
        ref.read(pagedPostsProvider.notifier).loadNextPage().then((_) {
          _maybeLoadMoreIfNotScrollable();
        });
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(pagedPostsProvider, (previous, next) {
      _maybeLoadMoreIfNotScrollable();
    });

    final state = ref.watch(pagedPostsProvider);
    if (state.isLoading && state.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text('Posts Paged')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (state.error != null && state.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posts Paged')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(friendlyErrorMessage(state.error!)),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(pagedPostsProvider.notifier).loadFirstPage(),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }
    if (!state.isLoading && state.items.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('Posts Paged')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Belum ada data.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () =>
                    ref.read(pagedPostsProvider.notifier).loadFirstPage(),
                child: const Text('Muat ulang'),
              ),
            ],
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Posts Paged')),
      body: ListView.builder(
        controller: _controller,
        itemCount: state.items.length + 1,
        itemBuilder: (context, index) {
          if (index == state.items.length) {
            if (state.error != null) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Text(friendlyErrorMessage(state.error!)),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () =>
                          ref.read(pagedPostsProvider.notifier).loadNextPage(),
                      child: const Text('Coba lagi'),
                    ),
                  ],
                ),
              );
            }
            if (!state.hasMore) {
              return const Padding(
                padding: EdgeInsets.all(16),
                child: Center(child: Text('Semua data termuat.')),
              );
            }
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(child: CircularProgressIndicator()),
            );
          }
          final post = state.items[index];
          return PostTile(post: post);
        },
      ),
    );
  }
}
