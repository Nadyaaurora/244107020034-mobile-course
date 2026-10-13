# Week 7 - Clean Architecture

---

**Nama :** Nadya Aurora Gebi Agista

**NIM :** 244107020034

---

## **Praktikum 1 Audit Layer Project Lama**

### 1. Pemetaan File ke Layer

| File | Layer Saat Ini | Hasil Audit |
|---|---|---|
| `pages/login_page.dart` | Presentation | Masih menggunakan `DioException` dan `apiErrorMessage()` dari layer data untuk menangani error login. |
| `pages/home_page.dart` | Presentation | Menggunakan provider untuk menjalankan proses logout. |
| `data/api_client.dart` | Data | Menangani request API, autentikasi token, refresh token, dan retry request. |
| `providers/auth_provider.dart` | Presentation | Mengelola state autentikasi, tetapi masih menggunakan implementasi konkret `AuthRepository` dan `TokenStore`. |
| `data/auth_repository.dart` | Data | Menangani proses autentikasi, tetapi kontrak repository dan implementasinya belum dipisahkan. |
| `data/token_store.dart` dan `data/api_errors.dart` | Data | Menangani penyimpanan token dan pemetaan error API. |

Salah satu masalah yang ditemukan adalah login_page.dart masih bergantung langsung pada DioException dan fungsi apiErrorMessage() dari layer data. Selain itu, auth_provider.dart membuat objek TokenStore() dan AuthRepository() secara langsung.

**Bukti Kode**

- **Penanganan error pada login_page.dart**

  <img src="screenshot/penanganan%20error%20-%20login_page.dart.png" alt="Penanganan error pada login_page.dart" width="400">

- **Deklarasi provider pada auth_provider.dart**

  <img src="screenshot/deklarasi%20providers%20-%20auth_provider.dart.png" alt="Deklarasi provider pada auth_provider.dart" width="400">

### 2. Hasil Pencarian Tiga Pelanggaran Klasik

- Akses jaringan atau database: Pola Dio(, http., openDatabase, SharedPreferences.getInstance, dan FlutterSecureStorage tidak ditemukan di lib/pages/.
- Pengolahan data di widget: Pola DateFormat, jsonDecode, dan .toIso8601String tidak ditemukan di lib/pages/.
- Instansiasi dan ketergantungan antar-layer: TokenStore() dan AuthRepository() ditemukan di auth_provider.dart. Sementara itu, login_page.dart masih menggunakan DioException dan apiErrorMessage() dari layer data.

### 3. Struktur Target Clean Architecture

```text
lib/
├── core/
│   ├── failures.dart
│   └── providers.dart
├── features/
│   └── announcements/
│       ├── domain/
│       │   ├── entities/
│       │   ├── repositories/
│       │   └── usecases/
│       ├── data/
│       │   ├── models/
│       │   └── repositories/
│       └── presentation/
│           ├── providers/
│           └── pages/
└── routes.dart
```

## Praktikum 2 Domain dan Data per Fitur

| **Layer** | **File** | **Peran** |
|---|---|---|
| core | `failures.dart` | Mendefinisikan Failure domain yang murni Dart. |
| domain | `entities/note.dart` | Entity catatan tanpa mapping data. |
| domain | `repositories/note_repository.dart` | Kontrak atau interface repository. |
| domain | `usecases/get_notes.dart` | Mengambil daftar catatan melalui repository. |
| data | `models/note_model.dart` | Menangani mapping melalui `toMap`, `fromMap`, dan `toEntity`. |
| data | `datasources/local/notes_database.dart` | Mengelola akses database lokal. |
| data | `repositories/note_repository_impl.dart` | Implementasi repository yang mengubah error menjadi `Failure`. |

Use case diterapkan pada `GetNotes`. Operasi CRUD sederhana dapat menggunakan repository langsung melalui notifier agar tidak menambah lapisan yang belum diperlukan.

## Praktikum 3 Presentation, DI, dan Verifikasi

- Memusatkan wiring dependency pada `note_providers.dart`.
- Membuat halaman yang hanya membaca state tanpa SQL, Dio, JSON, atau format mentah.
- Memverifikasi dependency rule dengan pencarian pada kode.

### Verifikasi Dependency Rule

| Pemeriksaan | Hasil |
| --- | --- |
| Presentation bebas dari akses data mentah | Nol hasil |
| Domain bebas dari import Flutter, Dio, SQLite, dan Firebase | Nol hasil |

| Cek Layer Presentation | Cek Layer Domain |
| :---: | :---: |
| <img src="./screenshot/Praktikum%203%20-%20Cek%20layer%20presentation.png"> | <img src="./screenshot/Praktikum%203%20-%20Cek%20layer%20domain.png"> |

### Hasil Analyze dan Test

| flutter analyze | flutter test |
| :---: | :---: |
| <img src="./screenshot/Praktikum 3 - Flutter analyze.png"> | <img src="./screenshot/Praktikum%203%20-%20Flutter%20test.png"> |

### Uji manual emulator (sebelum vs sesudah)

Tampilan dan perilaku tetap identik, sedangkan yang berubah hanya struktur kode.

- **Halaman Login**

  | Sebelum (Week 6) | Sesudah (Week 7) |
  | :---: | :---: |
  | <img src="./screenshot/Praktikum 1 - Login (P6).jpeg"> | <img src="./screenshot/Praktikum 3 - Login (P7).jpeg"> |

- **Email dan Password Terisi**

  | Sebelum (Week 6) | Sesudah (Week 7) |
  | :---: | :---: |
  | <img src="./screenshot/Praktikum 1 - email dan password (P6).jpeg"> | <img src="./screenshot/Praktikum 3 - email dan password (P7).jpeg"> |

- **Login Gagal (Password Salah)**

  | Sebelum (Week 6) | Sesudah (Week 7) |
  | :---: | :---: |
  | <img src="./screenshot/Praktikum 1 - Login gagal (Password salah) (P6).jpeg"> | <img src="./screenshot/Praktikum 3 - Login gagal (Password salah) (P7).jpeg"> |

- **Login Berhasil**

  | Sebelum (Week 6) | Sesudah (Week 7) |
  | :---: | :---: |
  | <img src="./screenshot/Praktikum 1 - Login berhasil (P6).jpeg"> | <img src="./screenshot/Praktikum 3 - Login berhasil (P7).jpeg"> |

---

## AI Challenge

### Prompt yang Digunakan

```
Project Flutter saya: campus_notify (auth + FCM + daftar pengumuman).
Kondisi kini: folder lib/{data, providers, pages, messaging},
repository tercampur dengan implementasi, widget memanggil Dio langsung.
Tugas:
1. Usulkan struktur feature-first Clean Architecture
(presentation/domain/data) untuk fitur auth + announcements.
2. Untuk tiap file lama, sebutkan tujuan barunya (pindah/pecah/hapus).
3. Tandai bagian yang over-engineering bila diterapkan ke CRUD sederhana,
dan kapan use case benar-benar dibutuhkan vs repository langsung.
4. Tunjukkan wiring DI dengan Riverpod (tanpa package DI tambahan).
Jelaskan trade-off setiap keputusan.
```

Prompt, output awal AI, tabel usulan dan keputusan akhir, serta hasil verifikasi didokumentasikan pada folder docs/.
- Prompt AI
- Output Awal AI
- Keputusan Arsitektur dan Tabel Usulan vs Keputusan Final
- Verifikasi Dependency

---

## Refactoring dan Testing

### Refactoring Challenge

| No | Refactoring | Status | Keterangan |
| :---: | --- | :---: | --- |
| 1 | Memusatkan wiring dependency auth pada provider | ☑ | `tokenStoreProvider` dan `authRepositoryProvider` menjadi satu-satunya tempat pembuatan objek, sehingga widget tidak membuat repository sendiri. |
| 2 | Proses login berjalan lewat provider | ☑ | `AuthNotifier` memanggil repository untuk login lalu menyimpan token lewat `TokenStore`. |
| 3 | Error mentah diubah menjadi pesan ramah pengguna | ☑ | Halaman login hanya menampilkan pesan hasil `apiErrorMessage` pada SnackBar. |

### Dokumentasi

| Deklarasi Provider | Proses Login |
| :---: | :---: |
| <img src="./screenshot/deklarasi%20providers%20-%20auth_provider.dart.png"> | <img src="./screenshot/proses%20login%20-%20auth_provider.dart.png"> |

| Import pada Halaman Login | Penanganan Error |
| :---: | :---: |
| <img src="./screenshot/import%20-%20login_page.dart.png"> | <img src="./screenshot/penanganan%20error%20-%20login_page.dart.png"> |

### Testing

| flutter analyze | flutter test |
| :---: | :---: |
| <img src="./screenshot/Refactoring%20-%20Flutter%20analyze.png"> | <img src="./screenshot/Refactoring - Flutter test.png"> |

---

## Checklist Verifikasi Mandiri

| No | Checklist | Status | Bukti atau Catatan |
| :---: | --- | :---: | --- |
| 1 | Pemeriksaan sterilitas presentation dan domain menghasilkan nol temuan. | Berhasil | Kedua pemeriksaan tidak menemukan import atau pemanggilan terlarang, dibuktikan pada Praktikum 3. |
| 2 | Interface berada di domain, implementasi di data, dan mapping hanya di model. | Berhasil | `note_repository.dart` berada di domain, sedangkan `note_repository_impl.dart` dan `note_model.dart` berada di data. |
| 3 | Widget tidak membuat repository sendiri dan semua lewat provider. | Berhasil | Pembuatan objek hanya terjadi di provider, dibuktikan pada bagian Refactoring. |
| 4 | Aplikasi berjalan identik sebelum dan sesudah refactor. | Berhasil | Tabel perbandingan login Week 6 dan Week 7 menunjukkan tampilan dan perilaku yang sama. |
| 5 | `flutter analyze` bersih dan semua test lulus. | Berhasil | `flutter analyze` tanpa temuan dan seluruh test lulus. |

---

## Struktur Folder

```
07-week-7-clean-architecture/
├── lib/
│   ├── main.dart
│   ├── routes.dart
│   ├── core/
│   │   └── failures.dart
│   ├── data/
│   │   ├── api_client.dart
│   │   ├── api_errors.dart
│   │   ├── auth_repository.dart
│   │   └── token_store.dart
│   ├── features/
│   │   └── notes/
│   │       ├── data/
│   │       │   ├── datasources/local/notes_database.dart
│   │       │   ├── models/note_model.dart
│   │       │   └── repositories/note_repository_impl.dart
│   │       ├── domain/
│   │       │   ├── entities/note.dart
│   │       │   ├── repositories/note_repository.dart
│   │       │   └── usecases/get_notes.dart
│   │       └── presentation/
│   │           ├── page/note_page.dart
│   │           ├── providers/note_providers.dart
│   │           └── widgets/
│   │               ├── error_view.dart
│   │               └── notes_list.dart
│   ├── pages/
│   │   ├── announcement_page.dart
│   │   ├── home_page.dart
│   │   └── login_page.dart
│   ├── providers/
│   │   └── auth_provider.dart
│   └── services/
│       └── push_service.dart
├── test/
├── docs/
├── screenshot/
└── README.md
```

---

## Refleksi

- **Mengapa interface repository harus tinggal di domain, bukan di data? Apa yang rusak bila dibalik?**

  **Jawab :**

  Interface repository ditempatkan di domain karena domain berisi aturan bisnis yang seharusnya tidak bergantung pada teknologi penyimpanan data. Dengan begitu, layer data dapat diganti tanpa mengubah aturan bisnis selama kontraknya tetap sama. Sebaliknya, jika interface berada di data, domain berisiko bergantung pada implementasi teknis sehingga perubahan teknologi dan pengujian menjadi lebih sulit.

- **Kapan use case benar-benar dibutuhkan, dan kapan repository langsung ke notifier sudah cukup?**

  **Jawab :** 

  Use case dibutuhkan ketika operasi melibatkan aturan bisnis, validasi, atau beberapa repository. Sebaliknya, untuk CRUD sederhana yang hanya meneruskan pemanggilan repository tanpa logika tambahan, repository dapat digunakan langsung melalui notifier. Pemilihan ini menjaga kode tetap sederhana tanpa menambah lapisan yang belum diperlukan.

- **Apa biaya over-engineering bagi tim kecil, dan kapan biayanya sepadan?**

    **Jawab :** 

  Pada tim kecil, penggunaan use case untuk setiap operasi CRUD satu baris menambah jumlah file, waktu pengembangan, dan beban pemeliharaan tanpa manfaat yang sebanding. Biaya tersebut sepadan jika aplikasi memiliki logika bisnis yang kompleks, proses yang digunakan kembali, atau kebutuhan pengujian yang lebih terstruktur, sehingga pemisahan tanggung jawab benar-benar membantu pengembangan dan pemeliharaan aplikasi.

- **Bagian mana dari usulan AI yang Anda tolak atau sederhanakan dan mengapa?**

    **Jawab :** 

  Usulan pembuatan use case untuk setiap operasi CRUD disederhanakan dengan mempertahankan GetNotes sebagai use case dan menggunakan repository langsung untuk operasi sederhana. Selain itu, migrasi fitur auth dan announcements belum dilakukan sepenuhnya agar perubahan arsitektur tidak mengganggu fitur yang sudah berjalan.