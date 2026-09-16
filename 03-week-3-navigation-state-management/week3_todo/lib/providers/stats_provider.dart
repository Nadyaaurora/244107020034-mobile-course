import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Mengambil dan menyimpan tiga nilai statistik untuk ditampilkan oleh UI.
class StatsNotifier extends AsyncNotifier<List<String>> {
  /// Random dan durasi dapat diganti saat test agar hasilnya deterministik.
  StatsNotifier({
    Random? random,
    this.requestDelay = const Duration(seconds: 2),
  }) : _random = random ?? Random();

  final Random _random;
  final Duration requestDelay;

  /// Menunggu seperti request network, lalu gagal dengan peluang sebesar 30%.
  @override
  Future<List<String>> build() async {
    await Future.delayed(requestDelay);

    if (_random.nextDouble() < 0.3) {
      throw Exception('Data statistik tidak dapat dimuat.');
    }

    return [
      'Total Pengguna: 1.248',
      'Pesanan Hari Ini: 86',
      'Pendapatan: Rp12,5 jt',
    ];
  }
}

/// Satu-satunya provider yang menjadi sumber state asynchronous halaman statistik.
final statsProvider = AsyncNotifierProvider<StatsNotifier, List<String>>(
  StatsNotifier.new,
);
