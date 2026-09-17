// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:week4_api/data/paged_posts.dart';
import 'package:week4_api/pages/paged_post_page.dart';

class _FakePagedPostsNotifier extends PagedPostsNotifier {
  @override
  PagedPostsState build() => const PagedPostsState(hasMore: false);
}

void main() {
  testWidgets('aplikasi berjalan di dalam ProviderScope', (
    WidgetTester tester,
  ) async {
    // ProviderScope diperlukan karena halaman utama membaca provider Riverpod.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          pagedPostsProvider.overrideWith(_FakePagedPostsNotifier.new),
        ],
        child: const MaterialApp(home: PagedPostPage()),
      ),
    );

    // App bar membuktikan widget utama berhasil dibuat tanpa error provider.
    expect(find.text('Posts Paged'), findsOneWidget);
  });
}
