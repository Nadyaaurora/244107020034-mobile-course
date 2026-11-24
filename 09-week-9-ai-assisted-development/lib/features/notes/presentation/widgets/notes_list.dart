import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/note.dart';
import '../providers/note_providers.dart';

class NotesList extends ConsumerWidget {
  const NotesList(this.notes, {super.key});

  final List<Note> notes;

  String _formatDate(DateTime dt) {
    final day = dt.day.toString().padLeft(2, '0');
    final monthNames = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    final month = monthNames[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    return '$day $month $year, $hour:$minute';
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, Note note) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        content: Text(
          'Apakah Anda yakin ingin menghapus catatan "${note.title}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);
              if (note.id == null) return;

              final result = await ref.read(deleteNoteProvider).call(note.id!);
              if (result.failure != null) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(result.failure!.message)),
                  );
                }
                return;
              }

              ref.invalidate(notesProvider);
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Catatan berhasil dihapus.')),
                );
              }
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: notes.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final note = notes[index];
        final isDirty = note.dirty;

        return Card(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: Colors.grey.shade200, width: 1.5),
          ),
          color: Theme.of(context).cardColor,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Baris Atas: Judul, Status Sinkronisasi, dan Tombol Hapus
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            note.title,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 6),
                          // Badge Status Sinkronisasi
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: isDirty
                                  ? Colors.orange.shade50
                                  : Colors.green.shade50,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isDirty
                                    ? Colors.orange.shade300
                                    : Colors.green.shade300,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  isDirty
                                      ? Icons.cloud_off_rounded
                                      : Icons.cloud_done_rounded,
                                  size: 14,
                                  color: isDirty
                                      ? Colors.orange.shade800
                                      : Colors.green.shade800,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  isDirty
                                      ? 'Belum tersinkron'
                                      : 'Sudah tersinkron',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: isDirty
                                        ? Colors.orange.shade800
                                        : Colors.green.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red.shade400,
                      ),
                      tooltip: 'Hapus catatan',
                      onPressed: () => _confirmDelete(context, ref, note),
                    ),
                  ],
                ),
                // Isi Catatan
                if (note.body.trim().isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Text(
                    note.body,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade700,
                      height: 1.4,
                    ),
                  ),
                ],
                const SizedBox(height: 12),
                const Divider(height: 1),
                const SizedBox(height: 8),
                // Waktu Catatan
                Row(
                  children: [
                    Icon(
                      Icons.schedule_rounded,
                      size: 13,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(note.updatedAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
