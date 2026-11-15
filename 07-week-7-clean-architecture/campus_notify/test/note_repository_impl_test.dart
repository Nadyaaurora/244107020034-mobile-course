import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';
import 'package:campus_notify/core/failures.dart';
import 'package:campus_notify/features/notes/data/repositories/note_repository_impl.dart';

void main() {
  test('Menolak judul catatan kosong', () async {
    var databaseOpened = false;

    final repository = NoteRepositoryImpl(
      openDb: () async {
        databaseOpened = true;
        throw StateError('Database tidak seharusnya dibuka');
      },
    );

    final result = await repository.addNote(title: '');

    expect(result.note, isNull);
    expect(result.failure, isA<LocalFailure>());
    expect(
      result.failure?.message,
      'Judul catatan tidak boleh kosong.',
    );
    expect(databaseOpened, isFalse);
  });

  test('Menolak judul catatan yang hanya berisi spasi', () async {
    var databaseOpened = false;

    final repository = NoteRepositoryImpl(
      openDb: () async {
        databaseOpened = true;
        throw StateError('Database tidak seharusnya dibuka');
      },
    );

    final result = await repository.addNote(title: '   ');

    expect(result.note, isNull);
    expect(result.failure, isA<LocalFailure>());
    expect(
      result.failure?.message,
      'Judul catatan tidak boleh kosong.',
    );
    expect(databaseOpened, isFalse);
  });
}