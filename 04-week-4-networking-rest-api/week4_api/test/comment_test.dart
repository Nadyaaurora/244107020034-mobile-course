import 'package:flutter_test/flutter_test.dart';
import 'package:week4_api/data/models/comment.dart';

void main() {
  test('Comment.fromJson memakai nilai default saat field hilang', () {
    // JSON kosong mensimulasikan response dengan semua field tidak tersedia.
    final comment = Comment.fromJson(<String, dynamic>{});

    // Angka menjadi 0 dan teks menjadi string kosong agar model selalu aman dipakai.
    expect(comment.postId, 0);
    expect(comment.id, 0);
    expect(comment.name, '');
    expect(comment.email, '');
    expect(comment.body, '');
  });
}
