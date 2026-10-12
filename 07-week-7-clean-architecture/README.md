## Week 7 - Clean Architecture

---

**Nama :** Nadya Aurora Gebi Agista

**NIM :** 244107020034

---

## Praktikum 1 Audit Layer Project Lama

### 1. Pemetaan File ke Layer

Audit dilakukan untuk mengetahui pembagian tanggung jawab setiap file pada project `campus_notify` dan mengidentifikasi bagian yang masih perlu diperbaiki sebelum menerapkan Clean Architecture.

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

  ![Penanganan error pada login_page.dart](/screenshot/penanganan%20error%20-%20login_page.dart.png)

- **Deklarasi provider pada auth_provider.dart**

  ![Deklarasi provider pada auth_provider.dart](/screenshot/deklarasi%20providers%20-%20auth_provider.dart.png)

### 2. Hasil Pencarian Tiga Pelanggaran Klasik

- Akses jaringan atau database: Pola Dio(, http., openDatabase, SharedPreferences.getInstance, dan FlutterSecureStorage tidak ditemukan di lib/pages/.
- Pengolahan data di widget: Pola DateFormat, jsonDecode, dan .toIso8601String tidak ditemukan di lib/pages/.
- Instansiasi dan ketergantungan antar-layer: TokenStore() dan AuthRepository() ditemukan di auth_provider.dart. Sementara itu, login_page.dart masih menggunakan DioException dan apiErrorMessage() dari layer data.

## 3. Struktur Target Clean Architecture

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
