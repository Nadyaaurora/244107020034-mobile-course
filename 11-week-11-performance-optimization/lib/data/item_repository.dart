import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'item_model.dart';

class ItemRepository {
  final Map<int, List<Item>> _pageCache = {};
  int _networkRequestCount = 0;

  int get networkRequestCount => _networkRequestCount;

  Future<List<Item>> fetchPage(int page, {int pageSize = 15}) async {
    if (_pageCache.containsKey(page)) {
      return _pageCache[page]!;
    }

    _networkRequestCount++;
    await Future.delayed(const Duration(milliseconds: 400));

    if (page > 5) return [];

    final startIndex = (page - 1) * pageSize;
    final items = List.generate(pageSize, (i) {
      final id = startIndex + i + 1;
      return Item(
        id: id,
        title: 'Pengumuman Akademik Polinema #$id',
        description:
            'Informasi jadwal kuliah, verifikasi berkas ujian, dan bimbingan proyek akhir mahasiswa angkatan 2026/2027.',
        category: id % 2 == 0 ? 'Akademik' : 'Kemahasiswaan',
        imageUrl: 'https://picsum.photos/seed/$id/300/200',
      );
    });

    _pageCache[page] = items;
    return items;
  }

  void clearCache() {
    _pageCache.clear();
  }
}

final itemRepositoryProvider = Provider<ItemRepository>((ref) {
  return ItemRepository();
});
