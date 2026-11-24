import 'package:sqflite/sqflite.dart';

import '../../../../core/failures.dart';
import '../../domain/entities/note.dart';
import '../../domain/repositories/note_repository.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  NoteRepositoryImpl({required this._openDb});

  final Future<Database> Function() _openDb;

  @override
  Future<({List<Note> notes, Failure? failure})> fetchNotes() async {
    try {
      final db = await _openDb();
      final rows = await db.query('notes', orderBy: 'updated_at DESC');

      final notes = rows.map((r) => NoteModel.fromMap(r).toEntity()).toList();

      return (notes: notes, failure: null);
    } catch (e) {
      return (
        notes: const <Note>[],
        failure: LocalFailure('Gagal membaca catatan: $e'),
      );
    }
  }

  @override
  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
    bool isSynced = false,
  }) async {
    if (title.trim().isEmpty) {
      return (
        note: null,
        failure: const LocalFailure('Judul catatan tidak boleh kosong.'),
      );
    }

    try {
      final db = await _openDb();
      final now = DateTime.now();
      final validTitle = title.trim();

      final id = await db.insert(
        'notes',
        NoteModel(
          title: validTitle,
          body: body,
          updatedAt: now,
          dirty: !isSynced,
        ).toMap(),
      );

      return (
        note: Note(
          id: id,
          title: validTitle,
          body: body,
          updatedAt: now,
          dirty: !isSynced,
        ),
        failure: null,
      );
    } catch (e) {
      return (note: null, failure: LocalFailure('Gagal menyimpan: $e'));
    }
  }

  @override
  Future<({bool success, Failure? failure})> deleteNote(int id) async {
    try {
      final db = await _openDb();
      await db.delete('notes', where: 'id = ?', whereArgs: [id]);
      return (success: true, failure: null);
    } catch (e) {
      return (
        success: false,
        failure: LocalFailure('Gagal menghapus catatan: $e'),
      );
    }
  }

  @override
  Future<({int syncedCount, Failure? failure})> syncNotes() async {
    try {
      final db = await _openDb();
      final count = await db.update('notes', {'dirty': 0}, where: 'dirty = 1');
      return (syncedCount: count, failure: null);
    } catch (e) {
      return (
        syncedCount: 0,
        failure: LocalFailure('Gagal menyinkronkan catatan: $e'),
      );
    }
  }
}
