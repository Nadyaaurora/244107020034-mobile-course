import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/local/note.dart';
import '../data/repositories/note_repository.dart';

final noteRepositoryProvider = Provider((ref) => NoteRepository());

final notesProvider =
    AsyncNotifierProvider<NotesNotifier, List<Note>>(NotesNotifier.new);

class NotesNotifier extends AsyncNotifier<List<Note>> {
  @override
  Future<List<Note>> build() {
    return ref.watch(noteRepositoryProvider).fetchNotes();
  }

  Future<void> loadNotes() async {
    state = AsyncData(
      await ref.read(noteRepositoryProvider).fetchNotes(),
    );
  }

  Future<void> addNote({
    required String title,
    required String body,
  }) async {
    await ref.read(noteRepositoryProvider).addNote(
          title: title,
          body: body,
        );

    await loadNotes();
  }

  Future<void> deleteNote(int id) async {
    await ref.read(noteRepositoryProvider).deleteNote(id);

    await loadNotes();
  }
}

class NotesPage extends ConsumerWidget {
  const NotesPage({super.key});

  Future<void> _addNote(
    BuildContext context,
    WidgetRef ref,
  ) async {
    final result = await showDialog<List<String>>(
      context: context,
      builder: (dialogContext) {
        final titleController = TextEditingController();
        final bodyController = TextEditingController();

        return AlertDialog(
          title: const Text('Tambah Catatan'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Judul',
                ),
              ),
              TextField(
                controller: bodyController,
                decoration: const InputDecoration(
                  labelText: 'Isi catatan',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                final title = titleController.text.trim();
                final body = bodyController.text.trim();

                if (title.isEmpty) return;

                Navigator.pop(
                  dialogContext,
                  [title, body],
                );
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    if (result == null) return;

    await ref.read(notesProvider.notifier).addNote(
          title: result[0],
          body: result[1],
        );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notes = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Offline Notes'),
        actions: [
          notes.when(
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Belum sync: -'),
            ),
            error: (_, _) => const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('Belum sync: -'),
            ),
            data: (items) {
              final dirtyCount =
                  items.where((note) => note.dirty).length;

              return Row(
                children: [
                  Text('Belum sync: $dirtyCount'),
                  IconButton(
                    onPressed: () {
                      ref
                          .read(notesProvider.notifier)
                          .loadNotes();
                    },
                    icon: const Icon(Icons.sync),
                  ),
                ],
              );
            },
          ),
        ],
      ),
      body: notes.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Text('Terjadi kesalahan: $error'),
        ),
        data: (items) {
          if (items.isEmpty) {
            return const Center(
              child: Text('Belum ada catatan'),
            );
          }

          return ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) {
              final note = items[index];

              return ListTile(
                title: Text(note.title),
                subtitle: Text(
                  note.body.isEmpty
                      ? 'Tidak ada isi'
                      : note.body,
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (note.dirty)
                      const Chip(
                        label: Text('Belum tersinkron'),
                      ),
                    IconButton(
                      onPressed: () {
                        ref
                            .read(notesProvider.notifier)
                            .deleteNote(note.id!);
                      },
                      icon: const Icon(Icons.delete),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _addNote(context, ref),
        child: const Icon(Icons.add),
      ),
    );
  }
}