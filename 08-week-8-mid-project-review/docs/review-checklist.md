# Checklist Review Tengah Semester

Project yang direview: `07-week-7-clean-architecture/campus_notify`

## Praktikum 1 — Audit dan Perbaikan Commit

Audit dilakukan terhadap 15 commit terakhir untuk memeriksa riwayat commit, penggunaan branch, dan status repository.

### Hasil Audit

- Beberapa pekerjaan sebelumnya dilakukan langsung pada branch `main`.
- Tidak ditemukan pesan commit `fix bug` atau `update` pada 15 commit terakhir.
- Branch `develop` dan `feat/notes-validation` telah dibuat.
- Working tree bersih saat pemeriksaan awal.

### Simulasi Perbaikan Pesan Commit

| Sebelum | Usulan Perbaikan |
|---|---|
| `feat: add week 7 task answers, reflection, and verification` | `docs(week-7): add task answers, reflection, and verification` |
| `feat: complete clean architecture practicum` | `feat(week-7): complete clean architecture implementation` |
| `feat: add note detail route` | `feat(notes): add note detail route` |

Perubahan pesan commit di atas hanya berupa simulasi dan tidak mengubah riwayat Git asli.

### Implementasi

Perbaikan dilakukan pada fitur notes dengan menambahkan validasi agar judul kosong atau hanya berisi spasi tidak dapat disimpan. Pengujian unit juga ditambahkan untuk memastikan validasi berjalan sesuai kebutuhan.

## Praktikum 2 — Pull Request dan Code Review

Pull Request dibuat dari branch `feat/notes-validation` menuju `develop` dengan judul `feat(notes): validasi judul kosong + test`.

Review dilakukan secara mandiri dengan memeriksa kebenaran implementasi, struktur arsitektur, pengujian, dan keterbacaan kode.

Hasil pemeriksaan menunjukkan bahwa judul kosong dan judul yang hanya berisi spasi berhasil ditolak. Salah satu saran pengembangan adalah memisahkan validasi ke use case dan menambahkan pengujian untuk judul valid serta kegagalan database.

**Keputusan review: Approve.**

Pull Request berhasil di-merge menggunakan metode squash ke branch `develop`. Setelah proses merge, branch feature lokal dan remote dihapus.

## Praktikum 3 — Static Analysis dan Continuous Integration

### Pemeriksaan Kualitas Kode

Pemeriksaan dilakukan menggunakan beberapa perintah berikut.

| Pemeriksaan | Hasil |
|---|---|
| `flutter analyze` | Tidak ditemukan masalah pada pemeriksaan terakhir |
| `dart format --set-exit-if-changed lib test` | 27 file diperiksa dan 15 file diformat |
| `flutter test` | 13 test berhasil |

### Konfigurasi CI

GitHub Actions ditambahkan melalui `.github/workflows/ci.yml` pada root repository. Workflow dikonfigurasi agar berjalan ketika terdapat Pull Request dengan menjalankan `flutter analyze` dan `flutter test`.

### Kesimpulan

Project telah menerapkan struktur feature-first dengan pemisahan domain, data, dan presentation. Validasi input dan pengujian unit telah ditambahkan pada fitur notes. Penggunaan branch, Pull Request, dan konfigurasi CI juga menjadi bagian dari perbaikan alur pengembangan.

Secara keseluruhan, project telah memiliki struktur kode dan proses pemeriksaan yang lebih terarah untuk mendukung pengembangan selanjutnya.