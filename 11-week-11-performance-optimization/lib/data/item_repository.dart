import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'item_model.dart';

class ItemRepository {
  // Cache lokal in-memory (simulasi Box Hive / SQLite cache)
  final Map<int, List<Item>> _pageCache = {};
  int _networkRequestCount = 0;

  int get networkRequestCount => _networkRequestCount;

  /// Mengambil data per halaman dengan pagination & cache lokal
  Future<List<Item>> fetchPage(int page, {int pageSize = 15}) async {
    // Cek apakah ada data di cache (Cache check)
    if (_pageCache.containsKey(page)) {
      return _pageCache[page]!;
    }

    // Simulasi network latency ke backend/CDN
    _networkRequestCount++;
    await Future.delayed(const Duration(milliseconds: 400));

    // Jika halaman melebihi 5 (total 75 item), stop data
    if (page > 5) return [];

    final startIndex = (page - 1) * pageSize;
    final items = List.generate(pageSize, (i) {
      final id = startIndex + i + 1;
      return Item(
        id: id,
        title: 'Pengumuman Akademik Polinema #$id',
        description: 'Informasi jadwal kuliah, verifikasi berkas ujian, dan bimbingan proyek akhir mahasiswa angkatan 2026/2027.',
        category: id % 2 == 0 ? 'Akademik' : 'Kemahasiswaan',
        imageUrl: 'https://picsum.photos/seed/$id/300/200',
      );
    });

    // Simpan ke local cache untuk strategi Stale-While-Revalidate
    _pageCache[page] = items;
    return items;
  }

  /// Menghapus seluruh cache (misal saat pull-to-refresh)
  void clearCache() {
    _pageCache.clear();
  }
}

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository();
});
