import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/stats_provider.dart';

/// Menampilkan state loading, error, atau tiga data statistik.
class StatsPage extends ConsumerWidget {
  /// Membuat halaman statistik.
  const StatsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // watch membuat widget membangun ulang setiap kali state provider berubah.
    final stats = ref.watch(statsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Statistik')),
      body: stats.when(
        // State ini tampil selama notifier menunggu simulasi request selesai.
        loading: () => const Center(child: CircularProgressIndicator()),
        // Pesan error dan tombol retry memberi pengguna cara memulai request baru.
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Gagal memuat statistik: $error'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(statsProvider),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
        // Data sukses ditampilkan sebagai tiga baris pada ListView.
        data: (items) => ListView.builder(
          itemCount: items.length,
          itemBuilder: (context, index) => ListTile(
            leading: const Icon(Icons.bar_chart),
            title: Text(items[index]),
          ),
        ),
      ),
    );
  }
}
