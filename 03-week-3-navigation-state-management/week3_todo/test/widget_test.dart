import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:week3_todo/main.dart';

void main() {
  testWidgets('menampilkan halaman produk dan loading state', (
    WidgetTester tester,
  ) async {
    // ConsumerWidget harus berada di bawah ProviderScope saat diuji.
    await tester.pumpWidget(const ProviderScope(child: MyApp()));

    // Request produk memiliki delay, sehingga frame pertama menampilkan spinner.
    expect(find.text('Produk'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    // Majukan fake clock agar timer asynchronous selesai sebelum test berakhir.
    await tester.pump(const Duration(seconds: 2));
  });
}
