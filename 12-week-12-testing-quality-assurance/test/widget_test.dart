import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:testing_quality_assurance/main.dart';

void main() {
  group('Pengujian Widget TaskApp', () {
    testWidgets('menampilkan judul halaman tugas sesuai latihan modul', (
      tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(home: Scaffold(body: Text('Daftar tugas'))),
      );
      expect(find.text('Daftar tugas'), findsOneWidget);
    });

    testWidgets(
      'menampilkan judul halaman tugas dan keadaan awal kosong pada TaskApp',
      (tester) async {
        await tester.pumpWidget(const TaskApp());

        expect(find.text('Daftar tugas'), findsOneWidget);
        expect(find.text('Belum ada tugas'), findsOneWidget);
        expect(find.byKey(const Key('task-title-field')), findsOneWidget);
        expect(find.byKey(const Key('save-task-button')), findsOneWidget);
      },
    );

    testWidgets(
      'menambahkan tugas baru melalui interaksi input dan tombol simpan',
      (tester) async {
        await tester.pumpWidget(const TaskApp());

        await tester.enterText(
          find.byKey(const Key('task-title-field')),
          'Baca materi',
        );
        await tester.tap(find.byKey(const Key('save-task-button')));
        await tester.pumpAndSettle();

        expect(find.text('Baca materi'), findsOneWidget);
        expect(find.text('Belum ada tugas'), findsNothing);
      },
    );

    testWidgets(
      'menampilkan pesan error ketika input tugas kosong atau hanya spasi',
      (tester) async {
        await tester.pumpWidget(const TaskApp());

        await tester.enterText(
          find.byKey(const Key('task-title-field')),
          '   ',
        );
        await tester.tap(find.byKey(const Key('save-task-button')));
        await tester.pumpAndSettle();

        expect(find.text('Judul tugas tidak boleh kosong'), findsOneWidget);
        expect(find.text('Belum ada tugas'), findsOneWidget);
      },
    );

    testWidgets('menghapus tugas saat tombol hapus ditekan', (tester) async {
      await tester.pumpWidget(const TaskApp());

      await tester.enterText(
        find.byKey(const Key('task-title-field')),
        'Tugas Praktikum',
      );
      await tester.tap(find.byKey(const Key('save-task-button')));
      await tester.pumpAndSettle();

      expect(find.text('Tugas Praktikum'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.delete_outline));
      await tester.pumpAndSettle();

      expect(find.text('Tugas Praktikum'), findsNothing);
      expect(find.text('Belum ada tugas'), findsOneWidget);
    });
  });
}
