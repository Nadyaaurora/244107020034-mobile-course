import '../entities/note.dart';

class SearchNotes {
  const SearchNotes();

  List<Note> call(List<Note> notes, String query) {
    final trimmed = query.trim().toLowerCase();
    if (trimmed.isEmpty) {
      return notes;
    }

    return notes
        .where((note) => note.title.toLowerCase().contains(trimmed))
        .toList();
  }
}
