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
  final searchController = TextEditingController();

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  void _showAddNoteSheet() {
    final titleCtrl = TextEditingController();
    final bodyCtrl = TextEditingController();
    bool isSynced = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 24,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Tambah Catatan Baru',
                    style: Theme.of(ctx).textTheme.titleLarge
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(ctx),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleCtrl,
                autofocus: true,
                decoration: const InputDecoration(
                  labelText: 'Judul catatan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: bodyCtrl,
                decoration: const InputDecoration(
                  labelText: 'Isi catatan',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 8),
              CheckboxListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Tandai sudah tersinkron'),
                subtitle: const Text(
                  'Status catatan akan langsung berwarna hijau',
                ),
                value: isSynced,
                onChanged: (val) {
                  setSheetState(() {
                    isSynced = val ?? false;
                  });
                },
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('Simpan Catatan'),
                onPressed: () async {
                  final result = await ref
                      .read(addNoteProvider)
                      .addNote(
                        title: titleCtrl.text,
                        body: bodyCtrl.text,
                        isSynced: isSynced,
                      );

                  if (!mounted) return;

                  if (result.failure != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(result.failure!.message)),
                    );
                    return;
                  }

                  ref.invalidate(notesProvider);
                  if (ctx.mounted) Navigator.pop(ctx);

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Catatan berhasil disimpan.')),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _syncAllNotes() async {
    final result = await ref.read(syncNotesProvider).call();

    if (!mounted) return;

    if (result.failure != null) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(result.failure!.message)));
      return;
    }

    ref.invalidate(notesProvider);

    final count = result.syncedCount;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          count > 0
              ? '$count catatan berhasil disinkronkan!'
              : 'Semua catatan sudah tersinkron.',
        ),
        backgroundColor: Colors.green.shade700,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredState = ref.watch(filteredNotesProvider);
    final query = ref.watch(searchQueryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_sync_outlined),
            tooltip: 'Sinkronkan semua catatan',
            onPressed: _syncAllNotes,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Muat ulang',
            onPressed: () => ref.invalidate(notesProvider),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddNoteSheet,
        icon: const Icon(Icons.add),
        label: const Text('Catatan Baru'),
      ),
      body: Column(
        children: [
          // Bagian Pencarian Utama di Depan
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Cari catatan berdasarkan judul...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          searchController.clear();
                          ref.read(searchQueryProvider.notifier).clear();
                        },
                      )
                    : null,
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 14,
                ),
              ),
              onChanged: (val) {
                ref.read(searchQueryProvider.notifier).setQuery(val);
              },
            ),
          ),
          const Divider(height: 1),
          // Daftar Catatan / Empty State
          Expanded(
            child: filteredState.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => ErrorView(
                message: '$e',
                onRetry: () => ref.invalidate(notesProvider),
              ),
              data: (notes) {
                if (notes.isEmpty) {
                  if (query.trim().isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_off,
                            size: 64,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Catatan "$query" tidak ditemukan',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Coba gunakan kata kunci lain',
                            style: TextStyle(
                              color: Colors.grey.shade500,
                              fontSize: 13,
                            ),
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            icon: const Icon(Icons.clear, size: 16),
                            label: const Text('Reset Pencarian'),
                            onPressed: () {
                              searchController.clear();
                              ref.read(searchQueryProvider.notifier).clear();
                            },
                          ),
                        ],
                      ),
                    );
                  }
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_alt_outlined,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Belum ada catatan',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Tekan tombol + Catatan Baru di bawah untuk menambah',
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return NotesList(notes);
              },
            ),
          ),
        ],
      ),
    );
  }
}
