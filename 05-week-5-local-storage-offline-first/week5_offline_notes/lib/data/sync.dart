import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'local/db.dart';
import 'models/post.dart';
import 'repositories/note_repository.dart';
import 'repositories/post_repository.dart';

Future<int> syncNotes(NoteRepository repo) async {
  final dirtyCount = await repo.countDirty();

  if (dirtyCount == 0) return 0;

  await Future.delayed(const Duration(seconds: 1));

  await repo.markAllSynced();

  return dirtyCount;
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
          jsonDecode(row['payload'] as String)
              as Map<String, dynamic>,
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

Future<void> refreshPostsInBackground(
  PostRepository repo,
) async {
  try {
    final posts = await repo.fetchPosts();
    await saveCachedPosts(posts);
  } catch (_) {}
}

Future<List<Post>> loadPostsCacheFirst(
  PostRepository repo,
) async {
  final cached = await readCachedPosts();

  if (cached.isNotEmpty) {
    refreshPostsInBackground(repo);
    return cached;
  }

  final posts = await repo.fetchPosts();
  await saveCachedPosts(posts);

  return posts;
}