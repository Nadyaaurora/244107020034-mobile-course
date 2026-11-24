import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/providers/note_data_providers.dart';
import '../../domain/entities/note.dart';
import '../../domain/usecases/delete_note.dart';
import '../../domain/usecases/get_notes.dart';
import '../../domain/usecases/search_notes.dart';
import '../../domain/usecases/sync_notes.dart';

final getNotesProvider = Provider<GetNotes>((ref) {
  return GetNotes(ref.watch(noteRepositoryProvider));
});

final notesProvider = FutureProvider<List<Note>>((ref) async {
  final result = await ref.watch(getNotesProvider).call();
  if (result.failure != null) throw Exception(result.failure!.message);
  return result.notes;
});

final addNoteProvider = Provider((ref) {
  return ref.watch(noteRepositoryProvider);
});

final deleteNoteProvider = Provider<DeleteNote>((ref) {
  return DeleteNote(ref.watch(noteRepositoryProvider));
});

final syncNotesProvider = Provider<SyncNotes>((ref) {
  return SyncNotes(ref.watch(noteRepositoryProvider));
});

class SearchQueryNotifier extends Notifier<String> {
  @override
  String build() => '';

  void setQuery(String query) => state = query;
  void clear() => state = '';
}

final searchQueryProvider = NotifierProvider<SearchQueryNotifier, String>(
  SearchQueryNotifier.new,
);

final searchNotesProvider = Provider<SearchNotes>((ref) {
  return const SearchNotes();
});

final filteredNotesProvider = Provider<AsyncValue<List<Note>>>((ref) {
  final notesAsync = ref.watch(notesProvider);
  final query = ref.watch(searchQueryProvider);
  final searchUseCase = ref.watch(searchNotesProvider);

  return notesAsync.whenData((notes) => searchUseCase(notes, query));
});
