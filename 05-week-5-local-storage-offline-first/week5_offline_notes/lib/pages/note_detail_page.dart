import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'notes_page.dart';

class NoteDetailPage extends ConsumerWidget {
  const NoteDetailPage({
    super.key,
    required this.id,
  });

  final int id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder(
      future: ref.read(noteRepositoryProvider).getNoteById(id),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Detail Catatan'),
            ),
            body: Center(
              child: Text('Terjadi kesalahan: ${snapshot.error}'),
            ),
          );
        }

        final note = snapshot.data;

        if (note == null) {
          return const Scaffold(
            body: Center(
              child: Text('Catatan tidak ditemukan'),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Catatan'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  note.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),
                Text(
                  note.body.isEmpty
                      ? 'Tidak ada isi'
                      : note.body,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}