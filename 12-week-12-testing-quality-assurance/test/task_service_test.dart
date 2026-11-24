import 'package:flutter_test/flutter_test.dart';
import 'package:testing_quality_assurance/task_service.dart';

class FakeTaskRepository implements TaskRepository {
  FakeTaskRepository({this.tasks = const [], this.error});

  final List<String> tasks;
  final Exception? error;

  @override
  Future<List<String>> getTasks() async {
    if (error != null) throw error!;
    return tasks;
  }
}

void main() {
  group('TaskService Unit Tests dengan FakeTaskRepository', () {
    test('meneruskan data dari repository saat sukses', () async {
      // Arrange
      final fakeRepo = FakeTaskRepository(
        tasks: ['Baca materi', 'Kerjakan kuis'],
      );
      final service = TaskService(fakeRepo);

      // Act
      final result = await service.loadTasks();

      // Assert
      expect(result, ['Baca materi', 'Kerjakan kuis']);
      expect(result.length, 2);
    });

    test(
      'mengembalikan daftar kosong ketika repository tidak memiliki tugas',
      () async {
        // Arrange
        final fakeRepo = FakeTaskRepository(tasks: []);
        final service = TaskService(fakeRepo);

        // Act
        final result = await service.loadTasks();

        // Assert
        expect(result, isEmpty);
      },
    );

    test('meneruskan error dari repository saat gagal tanpa berubah diam-diam jadi list kosong', () async {
      // Arrange
      final expectedError = Exception('Koneksi database lokal terputus');
      final fakeRepo = FakeTaskRepository(error: expectedError);
      final service = TaskService(fakeRepo);

      // Act & Assert
      expect(
        () => service.loadTasks(),
        throwsA(
          isA<Exception>().having(
            (e) => e.toString(),
            'pesan error',
            contains('Koneksi database lokal terputus'),
          ),
        ),
      );
    });
  });
}
