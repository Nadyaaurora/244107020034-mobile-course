import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'models/post.dart';
import 'providers.dart';

class PagedPostsState {
  const PagedPostsState({
    this.items = const [],
    this.page = 0,
    this.isLoading = true,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
  });

  final List<Post> items;
  final int page;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;
}

class PagedPostsNotifier extends Notifier<PagedPostsState> {
  bool _requestInFlight = false;

  @override
  PagedPostsState build() {
    Future.microtask(loadFirstPage);
    return const PagedPostsState();
  }

  Future<void> loadFirstPage() async {
    if (_requestInFlight) return;
    _requestInFlight = true;
    final repository = ref.read(postRepositoryProvider);
    state = PagedPostsState(
      items: state.items,
      page: state.page,
      isLoading: true,
      hasMore: state.hasMore,
    );
    try {
      final items = await repository.fetchPostsPage(page: 1, limit: 10);
      state = PagedPostsState(
        items: items,
        page: 1,
        isLoading: false,
        hasMore: items.length == 10,
      );
    } catch (e) {
      state = PagedPostsState(isLoading: false, error: e);
    } finally {
      _requestInFlight = false;
    }
  }

  Future<void> loadNextPage() async {
    if (_requestInFlight || state.isLoadingMore || !state.hasMore) {
      return;
    }
    _requestInFlight = true;
    final repo = ref.read(postRepositoryProvider);
    final currentItems = state.items;
    final currentPage = state.page;
    state = PagedPostsState(
      items: currentItems,
      page: currentPage,
      isLoading: false,
      isLoadingMore: true,
      hasMore: state.hasMore,
    );
    try {
      final next = currentPage + 1;
      final items = await repo.fetchPostsPage(page: next, limit: 10);
      state = PagedPostsState(
        items: [...currentItems, ...items],
        page: next,
        isLoading: false,
        hasMore: items.length == 10,
      );
    } catch (e) {
      state = PagedPostsState(
        items: currentItems,
        page: currentPage,
        isLoading: false,
        error: e,
      );
    } finally {
      _requestInFlight = false;
    }
  }
}

final pagedPostsProvider =
    NotifierProvider<PagedPostsNotifier, PagedPostsState>(
      PagedPostsNotifier.new,
    );
