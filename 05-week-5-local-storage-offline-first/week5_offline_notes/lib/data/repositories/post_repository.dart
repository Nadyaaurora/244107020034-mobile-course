import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:sqflite/sqflite.dart';

import '../local/db.dart';
import '../models/post.dart';

class PostRepository {
  PostRepository(this._dio);
  final Dio _dio;

  Future<List<Post>> fetchPosts() async {
    final response = await _dio.get<List>('/posts');
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().map(Post.fromJson).toList();
  }

  Future<Post> fetchPost(int id) async {
    final response = await _dio.get<Map<String, dynamic>>('/posts/$id');
    return Post.fromJson(response.data ?? const <String, dynamic>{});
  }

  Future<List<Post>> fetchPostsPage({required int page, int limit = 10}) async {
    final response = await _dio.get<List>(
      '/posts',
      queryParameters: {'_page': page, '_limit': limit},
    );
    final data = response.data ?? [];
    return data.whereType<Map<String, dynamic>>().map(Post.fromJson).toList();
  }

  Future<List<Post>> readCachedPosts() async {
    final db = await openNotesDb();

    final rows = await db.query(
      'cached_posts',
      orderBy: 'cached_at DESC',
    );

    return rows
        .map(
          (row) => Post.fromJson(
            jsonDecode(row['payload'] as String) as Map<String, dynamic>,
          ),
        )
        .toList();
  }

  Future<void> saveCachedPosts(List<Post> posts) async {
    final db = await openNotesDb();
    final batch = db.batch();

    for (final post in posts) {
      batch.insert(
        'cached_posts',
        {
          'id': post.id,
          'payload': jsonEncode(post.toJson()),
          'cached_at': DateTime.now().toIso8601String(),
        },
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    }

    await batch.commit(noResult: true);
  }

  Future<void> refreshPostsInBackground() async {
    try {
      final posts = await fetchPosts();
      await saveCachedPosts(posts);
    } catch (_) {}
  }

  Future<List<Post>> loadPostsCacheFirst() async {
    final cached = await readCachedPosts();
    refreshPostsInBackground();
    return cached;
  }
}
