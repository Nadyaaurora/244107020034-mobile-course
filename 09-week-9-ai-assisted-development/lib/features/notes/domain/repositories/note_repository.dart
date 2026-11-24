import '../entities/note.dart';
import '../../../../core/failures.dart';

abstract class NoteRepository {
  Future<({List<Note> notes, Failure? failure})> fetchNotes();

  Future<({Note? note, Failure? failure})> addNote({
    required String title,
    String body = '',
    bool isSynced = false,
  });

  Future<({bool success, Failure? failure})> deleteNote(int id);

  Future<({int syncedCount, Failure? failure})> syncNotes();
}
