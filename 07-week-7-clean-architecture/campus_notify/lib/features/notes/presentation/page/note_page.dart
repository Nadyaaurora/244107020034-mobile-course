import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/note_providers.dart';
import '../widgets/error_view.dart';
import '../widgets/notes_list.dart';

class NotesPage extends ConsumerStatefulWidget {
  const NotesPage({super.key});

  @override
  ConsumerState<NotesPage> createState() => _NotesPageState();
}

class _NotesPageState extends ConsumerState<NotesPage> {
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  @override
  void dispose() {
    titleController.dispose();
    bodyController.dispose();
    super.dispose();
  }

  Future<void> addNote() async {
    final result = await ref
        .read(addNoteProvider)
        .addNote(title: titleController.text, body: bodyController.text);

    if (!mounted) return;

    if (result.failure != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.failure!.message)));
      return;
    }

    titleController.clear();
    bodyController.clear();
    ref.invalidate(notesProvider);

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Catatan berhasil disimpan.')));
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(notesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Catatan')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(
                    labelText: 'Judul catatan',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: bodyController,
                  decoration: const InputDecoration(
                    labelText: 'Isi catatan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: addNote,
                    child: const Text('Simpan Catatan'),
                  ),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: state.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(
                message: '$e',
                onRetry: () => ref.invalidate(notesProvider),
              ),
              data: (notes) => notes.isEmpty
                  ? const Center(child: Text('Belum ada catatan.'))
                  : NotesList(notes),
            ),
          ),
        ],
      ),
    );
  }
}
