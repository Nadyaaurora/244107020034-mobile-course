# AI Review vs Keputusan Teknis

## 1. Ruang Lingkup

- **PR:** [#1 — feat(notes): validasi judul kosong + test](https://github.com/Nadyaaurora/244107020034-mobile-course/pull/1)
- **Branch tujuan:** `develop`
- **File:** `note_repository_impl.dart` dan `note_repository_impl_test.dart`
- **Fokus:** Kebenaran kode, Clean Architecture, dan pengujian.

PR sudah di-merge. Review ini membandingkan saran AI dengan hasil pemeriksaan kode dan keputusan teknis.

## 2. Prompt AI

> Review PR Flutter ini sebagai senior Flutter developer. Fokus pada kebenaran kode, arsitektur feature-first Clean Architecture, dan test. Berikan lima temuan teratas beserta alasan dan usulan perbaikannya.

## 3. Output Awal AI

Review PR #1: **tidak ada blocker**. AI menemukan lima saran perbaikan, dua di antaranya merupakan hardening, bukan regresi yang pasti terjadi.

1. **Validasi berada di data layer.**  
   Validasi judul masih berada di `note_repository_impl.dart`. Sebaiknya dipindahkan ke use case domain agar aturan berlaku untuk semua implementasi repository.

   ```dart
   final normalized = title.trim();
   if (normalized.isEmpty) {
     return (note: null, failure: const ValidationFailure('Judul wajib diisi.'));
   }
   ```

2. **Input tidak valid menggunakan LocalFailure.**  
   Kesalahan input belum dibedakan dari kegagalan SQLite. AI menyarankan penambahan `ValidationFailure` agar presentation dapat menangani kesalahan validasi secara khusus.

   ```dart
   class ValidationFailure extends Failure {
     const ValidationFailure(super.message);
   }
   ```

3. **Penggunaan trim() mengubah judul valid.**  
   `title.trim()` menghapus spasi di awal dan akhir judul. Jika normalisasi tidak diperlukan, cukup gunakan `trim()` untuk validasi dan tetap simpan judul asli.

   ```dart
   if (title.trim().isEmpty) return invalidTitle;
   final storedTitle = title;
   ```

4. **Belum ada test jalur sukses.**  
   Pengujian baru mencakup penolakan judul kosong dan spasi. AI menyarankan test tambahan untuk memastikan judul valid berhasil disimpan dan nilainya sesuai dengan input.

   ```dart
   expect(result.failure, isNull);
   expect(result.note?.title, title);
   expect(insertedValues['title'], title);
   ```

5. **Skema SQLite masih menerima string kosong.**  
   `title TEXT NOT NULL` hanya mencegah nilai NULL. AI menyarankan constraint `CHECK` agar database juga menolak judul kosong.

   ```sql
   title TEXT NOT NULL CHECK (length(trim(title)) > 0)
   ```

   Constraint perlu disesuaikan dengan aturan whitespace Dart dan diterapkan melalui migrasi database.

## 4. Bukti Verifikasi

### 4.1 Pemeriksaan Kode

| Pemeriksaan | Hasil |
|---|---|
| Validasi judul | Berada di `note_repository_impl.dart`. |
| Penanganan error | Menggunakan `LocalFailure`. |
| Normalisasi judul | Menggunakan `title.trim()`. |
| Pengujian | Dua test untuk judul kosong dan spasi. |
| Penyimpanan | Menggunakan `db.insert` pada repository. |
| Skema database | `title TEXT NOT NULL` tanpa constraint `CHECK`. |

### 4.2 Dokumentasi Pengujian

| flutter analyze | flutter test |
| :---: | :---: |
| <img src="../screenshots/23-flutter analyze-ai.png"> | <img src="../screenshots/24-flutter test-ai.png"> |

Hasil menunjukkan analisis kode tidak menemukan masalah dan dua test validasi berhasil dijalankan.

## 5. Keputusan Teknis

| No. | Saran AI | Keputusan |
|---|---|---|
| 1 | Memindahkan validasi ke domain. | **Diterima.** |
| 2 | Menambahkan `ValidationFailure`. | **Diterima.** |
| 3 | Meninjau penggunaan `trim()`. | **Diterima.** Validasi tetap menggunakan `trim()`, tetapi judul asli dipertahankan. |
| 4 | Menambahkan test jalur sukses. | **Diterima.** |
| 5 | Menambahkan constraint SQLite. | **Ditolak untuk scope PR ini.** Belum diperlukan untuk perubahan yang dikerjakan dan berpotensi membutuhkan migrasi database. |

## 6. Kesimpulan

Dari lima saran AI, empat diterima sebagai arah perbaikan dan satu ditolak untuk scope PR ini. Hasil verifikasi menunjukkan validasi input berjalan sesuai pengujian, tetapi test jalur penyimpanan judul valid masih perlu ditambahkan.