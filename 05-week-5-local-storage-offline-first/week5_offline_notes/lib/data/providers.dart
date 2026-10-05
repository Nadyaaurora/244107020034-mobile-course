import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'api_client.dart';
import 'models/post.dart';
import 'repositories/post_repository.dart';
import 'sync.dart';

final dioProvider = Provider<Dio>((ref) => createDio());

final postRepositoryProvider = Provider<PostRepository>(
  (ref) => PostRepository(ref.watch(dioProvider)),
);

class ForceOfflineNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void toggle() {
    state = !state;
  }
}

final forceOfflineProvider =
    NotifierProvider<ForceOfflineNotifier, bool>(
  ForceOfflineNotifier.new,
);

class PostListNotifier extends AsyncNotifier<List<Post>> {
  @override
  Future<List<Post>> build() async {
    final repository = ref.watch(postRepositoryProvider);
    final forceOffline = ref.watch(forceOfflineProvider);

    if (forceOffline) {
      return readCachedPosts();
    }

    return loadPostsCacheFirst(repository);
  }

  Future<void> refresh() async {
    state = const AsyncLoading();

    try {
      final repository = ref.read(postRepositoryProvider);
      final posts = await repository.fetchPosts();

      await saveCachedPosts(posts);

      state = AsyncData(posts);
    } catch (e, st) {
      try {
        final cached = await readCachedPosts();

        state = AsyncData(cached);
      } catch (_) {
        state = AsyncError(e, st);
      }
    }
  }
}

final postListProvider =
    AsyncNotifierProvider<PostListNotifier, List<Post>>(
  PostListNotifier.new,
  retry: (retryCount, error) => null,
);