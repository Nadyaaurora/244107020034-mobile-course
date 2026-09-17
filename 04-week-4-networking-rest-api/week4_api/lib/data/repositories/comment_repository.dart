import 'package:dio/dio.dart';

import '../models/comment.dart';

/// Repository yang menjadi satu-satunya lapisan akses endpoint komentar.
class CommentRepository {
  /// Menyimpan client Dio yang dipakai untuk request HTTP.
  CommentRepository(this._dio);

  final Dio _dio;

  /// Mengambil semua komentar untuk post tertentu.
  Future<List<Comment>> fetchComments(int postId) async {
    // Base URL dan seluruh timeout berasal dari Dio client terpusat.
    final response = await _dio.get<List>(
      '/comments',
      queryParameters: {'postId': postId},
    );

    // Response kosong dianggap sebagai daftar kosong, bukan null.
    final data = response.data ?? const [];
    return data
        .whereType<Map<String, dynamic>>()
        .map(Comment.fromJson)
        .toList();
  }
}
