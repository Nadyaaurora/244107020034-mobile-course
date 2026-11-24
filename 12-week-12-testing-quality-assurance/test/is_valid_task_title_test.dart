import 'package:flutter_test/flutter_test.dart';
import 'package:testing_quality_assurance/is_valid_task_title.dart';

void main() {
  group('isValidTaskTitle Unit Tests', () {
    test('menerima judul yang berisi teks normal (Arrange-Act-Assert)', () {
      // Arrange
      const title = 'Belajar Flutter Testing';

      // Act
      final result = isValidTaskTitle(title);

      // Assert
      expect(result, isTrue);
    });

    test('menerima judul dengan spasi di awal dan akhir', () {
      // Arrange
      const title = '   Tugas Mobile Pemrograman   ';

      // Act
      final result = isValidTaskTitle(title);

      // Assert
      expect(result, isTrue);
    });

    test('menolak teks kosong', () {
      // Arrange
      const title = '';

      // Act
      final result = isValidTaskTitle(title);

      // Assert
      expect(result, isFalse);
    });

    test('menolak masukan yang hanya berisi spasi atau tab', () {
      // Arrange & Act & Assert
      expect(isValidTaskTitle('   '), isFalse);
      expect(isValidTaskTitle('\t\t'), isFalse);
      expect(isValidTaskTitle('\n   \n'), isFalse);
    });
  });
}
