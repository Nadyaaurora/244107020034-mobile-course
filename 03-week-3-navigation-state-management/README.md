# Tugas Praktikum Minggu 3: Navigation & State Management
---
**Nama:** Nadya Aurora Gebi Agista

**NIM :** 244107020034

---

### Praktikum 1: Aplikasi Multi-page dengan GoRouter

#### Dokumentasi
| Halaman Home | Halaman Detail |
| :---: | :---: |
| <img src="./screenshot/Praktikum%201%20-%20Halaman%20Home.jpeg"> | <img src="./screenshot/Praktikum%201%20-%20Halaman%20Detail.jpeg"> |

#### Pengamatan
- Path pada URL berubah mengikuti layar yang sedang aktif (`/detail/5` saat membuka Item 5).
- Path detail dapat diakses langsung tanpa harus melewati halaman Home terlebih dahulu.
- Tombol back sistem tetap berfungsi mengembalikan ke route sebelumnya.

---
### Praktikum 2: Aplikasi ToDo dengan Riverpod

#### Dokumentasi
| Daftar Kosong | Daftar Tugas (toggle & hapus) |
| :---: | :---: |
| <img src="./screenshot/Praktikum%202%20-%20Daftar%20Kosong.jpeg"> | <img src="./screenshot/Praktikum%202%20-%20To%20do%20list.jpeg"> |

#### Pengamatan
- `ref.watch` di dalam `build` membuat halaman otomatis ter-rebuild saat daftar berubah.
- `ref.read(todoListProvider.notifier)` di dalam callback hanya memanggil method tanpa berlangganan perubahan.
- Tugas yang ditandai selesai ditampilkan dengan `TextDecoration.lineThrough`.
- State ToDo tetap bertahan saat berpindah halaman karena disimpan di luar widget tree.

---
### Praktikum 3: Uji Ketiga State AsyncValue

#### Dokumentasi
| Error + Tombol Coba Lagi | Success |
| :---: | :---: |
| <img src="./screenshot/Praktikum%203%20-%20Coba%20lagi.jpeg"> | <img src="./screenshot/Praktikum%203%20-%20Success.jpeg"> |

#### Pengamatan
- State loading tampil sebagai `CircularProgressIndicator` selama 2 detik pertama (simulasi network).
- Saat `build()` dibuat melempar `Exception('Gagal terhubung ke server')`, UI menampilkan pesan error beserta tombol *Coba lagi*.
- Menekan *Coba lagi* memanggil `ref.invalidate` sehingga provider dijalankan ulang dan state kembali ke success.

### Refleksi Praktikum 3
**Mengapa menampilkan ulang data lama (stale data) dengan indikator refresh kadang lebih baik daripada mengosongkan layar? Kapan pola itu penting?**

  **Jawab :**

  Menampilkan data lama membuat pengguna tetap dapat melihat informasi yang tersedia saat data terbaru sedang dimuat. Indikator refresh memberikan tanda bahwa aplikasi sedang memperbarui data, sehingga pengguna tidak merasa aplikasi kosong atau tidak merespons. Pola ini penting pada dashboard, daftar transaksi, atau data yang sering diperbarui melalui jaringan, karena pengguna tetap dapat mengakses data sebelumnya sambil menunggu data terbaru.

#### Pola yang Sering Keliru
| Kesalahan | Perbaikan |
| :--- | :--- |
| Memanggil `ref.watch` di dalam callback | Gunakan `ref.read` di callback, `ref.watch` hanya di `build` |
| Mengubah state langsung tanpa membuat objek baru | Buat list/objek baru (`[...state]`, `copyWith`) |
| Melupakan UI error sehingga layar putih saat API gagal | Tangani cabang `error` pada `when` |
| Menggunakan `setState` untuk state lintas halaman | Naikkan state ke provider Riverpod |

---
### Praktikum 5: AI Challenge

#### AI Verification Checklist
| Poin Verifikasi | Hasil | Catatan / Perbaikan |
| :--- | :---: | :--- |
| State diubah secara immutable (tidak ada `state.add()` atau mutasi list langsung) | ☑ | `TodoListNotifier` memakai spread (`[...state]`) dan `copyWith`; tidak ditemukan mutasi langsung pada `state`. |
| `ref.watch` hanya dipakai di dalam `build`, `ref.read` di callback | ☑ | `ref.watch` hanya ditemukan di `build`/provider turunan; aksi pada `TodoPage` memakai `ref.read` di callback. |
| Ketiga state `AsyncValue` ditangani (bukan hanya success) | ☑ | `ProductPage` dan `StatsPage` menangani `loading`, `error`, dan `data` melalui `when`; error menyediakan tombol retry. |
| Provider dideklarasikan dengan tipe eksplisit dan tidak duplikat | ☑ | Provider memakai `NotifierProvider`, `AsyncNotifierProvider`, atau `Provider` dengan tipe state eksplisit; tidak ada provider duplikat. |
| Tidak memakai API Riverpod versi lama (`StateProvider` antipattern, `StateNotifierProvider` usang, `Consumer` bertingkat) | ☑ | Pencarian pada `lib/` tidak menemukan API lama atau `Consumer` bertingkat; pola yang digunakan adalah `Notifier`/`AsyncNotifier` dan `ConsumerWidget`. |
| Lolos `flutter analyze` dan `flutter test` tanpa warning | ☑ | `flutter analyze`: `No issues found!`; `flutter test`: `3` test lulus. |

#### Perbaikan yang Dilakukan & Alasan Teknis
1. Tidak ada perbaikan kode yang diperlukan setelah audit: implementasi sudah menggunakan pola `Notifier`/`AsyncNotifier` yang sesuai.
2. Verifikasi immutable dilakukan pada operasi tambah, toggle, dan hapus; setiap perubahan menghasilkan list baru.
3. Dokumentasi checklist ini dilengkapi berdasarkan hasil inspeksi kode, `flutter analyze`, dan `flutter test`.

| flutter analyze | flutter test |
| :---: | :---: |
| <img src="./screenshot/AI%20Verification_flutter%20analyze.png"> | <img src="./screenshot/AI%20Verification_flutter%20test.png"> |

---
### Praktikum 6: Refactoring dan Testing

#### Refactoring Challenge
| No | Refactoring | Status | Keterangan |
| :---: | :--- | :---: | :--- |
| 1 | Pisahkan widget baris ToDo menjadi `TodoTile` tersendiri | ☑ | `build` pada `TodoPage` menjadi lebih pendek dan `TodoTile` lebih mudah diuji. |
| 2 | Ekstrak logika filter menjadi `Provider` turunan dari `todoListProvider` | ☑ | Provider turunan membaca `todoListProvider` dan mengembalikan daftar hasil filter. |
| 3 | Integrasikan ToDo dengan GoRouter (`/` dan `/stats`) + `NavigationBar` | ☑ | Perpindahan tab ToDo ↔ Stats tanpa kehilangan state daftar tugas. |

#### Dokumentasi Setelah Refactoring
| NavigationBar — Tab ToDo | NavigationBar — Tab Stats |
| :---: | :---: |
| <img src="./screenshot/Praktikum%206%20-%20Tab%20Daftar.jpeg"> | <img src="./screenshot/Praktikum%206%20-%20Tab%20Statistik.jpeg"> |

#### Testing
Widget test disimpan pada folder `test/` untuk memverifikasi bahwa UI bereaksi terhadap perubahan state provider (menambah tugas baru) serta penanganan state asinkron.

Hasil verifikasi:
- `flutter analyze` → `No issues found!`
- `flutter test` → 3 test lulus

| flutter analyze | flutter test |
| :---: | :---: |
| <img src="./screenshot/Testing_flutter%20analyze.png"> | <img src="./screenshot/Testing_flutter%20test.png"> |

---
### Checklist Verifikasi Mandiri
- [x] Navigasi GoRouter bekerja: pindah halaman, back, dan akses path detail langsung.
- [x] `ProviderScope` membungkus root aplikasi; state ToDo bertahan saat berpindah halaman.
- [x] UI `AsyncValue` menangani loading, error, dan success, bukan hanya success.
- [x] `flutter analyze` tanpa issue dan semua test lulus.
- [x] Hasil AI diverifikasi dan didokumentasikan pada folder `docs/`.
- [x] Struktur folder `lib/`, `test/`, `docs/`, `screenshot/`, dan `README.md` sudah lengkap.

### Struktur Folder
| Struktur Folder |
| :---: |
| <img src="./screenshot/struktur%20folder.png"> |

---
### Refleksi
- **Kapan `setState` masih cukup, dan kapan state harus naik ke Riverpod?**

  **Jawab :**

  setState cukup untuk state lokal yang hanya digunakan satu widget, seperti input atau animasi. Riverpod digunakan ketika state dipakai beberapa widget/halaman, perlu dipertahankan saat navigasi, atau memiliki logika bisnis dan asynchronous state.

- **Apa perbedaan `context.go` dan `context.push`, dan kapan masing-masing tepat digunakan?**

  **Jawab :**

  context.go mengganti konfigurasi route sehingga cocok untuk perpindahan halaman utama atau redirect. context.push menambahkan route baru ke stack dan cocok untuk halaman detail karena pengguna dapat kembali ke halaman sebelumnya.

- **Bagaimana `AsyncValue` mencegah bug dibanding tiga boolean terpisah?**

  **Jawab :**

  AsyncValue menyatukan kondisi loading, error, dan data dalam satu state sehingga lebih konsisten. Hal ini mengurangi risiko kombinasi state yang tidak sesuai dan membuat setiap kondisi dapat ditangani dengan jelas melalui when.

- **Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?**

  **Jawab :**

  Hasil AI diverifikasi dan disesuaikan dengan pola Riverpod proyek. Perbaikan meliputi penggunaan immutable state dengan spread dan copyWith, pemisahan ref.watch dan ref.read, serta penanganan kondisi loading, error, dan success. Kode kemudian diperiksa menggunakan flutter analyze dan flutter test.
