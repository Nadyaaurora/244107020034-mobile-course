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
          return Scaffold(
            appBar: AppBar(title: const Text('Detail Catatan')),
            body: const Center(
              child: Text('Catatan tidak ditemukan'),
            ),
          );
        }
        final updatedAt = note.updatedAt.toLocal();
        final status = note.dirty ? 'Belum tersinkron' : 'Sudah tersinkron';

        return Scaffold(
          appBar: AppBar(
            title: const Text('Detail Catatan'),
          ),
          body: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(note.title, style: Theme.of(context).textTheme.headlineSmall),
                const SizedBox(height: 12),
                Text(note.body.isEmpty ? 'Tidak ada isi' : note.body, style: Theme.of(context).textTheme.bodyLarge),
                const SizedBox(height: 24),
                const SizedBox(height: 10),
                Text('Terakhir diperbarui', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                Text('${updatedAt.day} ${_monthName(updatedAt.month)} ${updatedAt.year}, ${updatedAt.hour.toString().padLeft(2, '0')}:${updatedAt.minute.toString().padLeft(2, '0')}'),
                const SizedBox(height: 20),
                Text('Status', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(note.dirty ? Icons.sync_problem : Icons.check_circle, size: 18),
                    const SizedBox(width: 8),
                    Text(status),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _monthName(int month) {
    const months = ['Januari', 'Februari', 'Maret', 'April', 'Mei', 'Juni', 'Juli', 'Agustus', 'September', 'Oktober', 'November', 'Desember'];
    return months[month - 1];
  }
}