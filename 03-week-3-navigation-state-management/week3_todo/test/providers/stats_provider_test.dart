import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:week3_todo/providers/stats_provider.dart';

/// Random sederhana yang selalu mengembalikan nilai yang ditentukan untuk test.
class FixedRandom implements Random {
  /// Membuat random palsu dengan hasil `nextDouble` tetap.
  const FixedRandom(this.value);

  final double value;

  @override
  bool nextBool() => value >= 0.5;

  @override
  double nextDouble() => value;

  @override
  int nextInt(int max) => (value * max).floor();
}

void main() {
  test('notifier mengembalikan tiga statistik saat request berhasil', () async {
    // Override membuat test tidak menunggu dua detik dan selalu masuk jalur sukses.
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(
            random: const FixedRandom(0.5),
            requestDelay: Duration.zero,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // read memicu build notifier dan menunggu hasil asynchronous-nya.
    final result = await container.read(statsProvider.future);

    expect(result, hasLength(3));
    expect(result.first, 'Total Pengguna: 1.248');
  });

  test('notifier menghasilkan error saat simulasi request gagal', () async {
    // Nilai random di bawah 0.3 memaksa cabang kegagalan 30 persen.
    final container = ProviderContainer(
      overrides: [
        statsProvider.overrideWith(
          () => StatsNotifier(
            random: const FixedRandom(0.1),
            requestDelay: Duration.zero,
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    // Listener menjaga provider aktif dan menangkap state AsyncError dari notifier.
    final errorState = Completer<AsyncValue<List<String>>>();
    final subscription = container.listen(statsProvider, (previous, next) {
      if (next.hasError && !errorState.isCompleted) {
        errorState.complete(next);
      }
    }, fireImmediately: true);
    addTearDown(subscription.close);

    // State error harus muncul setelah request asynchronous selesai.
    final result = await errorState.future.timeout(const Duration(seconds: 1));
    expect(result.error, isA<Exception>());
  });
}
