## Week 5 - Local Storage and Offline First
---
**Nama  :** Nadya Aurora Gebi Agista

**NIM   :** 244107020034

---
### **Praktikum 1 SharedPreferences**
- Memusatkan akses `dark_mode` dan `last_opened_at` melalui `PrefsRepository` agar pengelolaan data preferensi tidak tersebar di widget.
- Menggunakan `AsyncNotifier` pada `DarkModeNotifier` untuk mengelola perubahan tema secara asynchronous.
- Menggunakan `AsyncValue.guard` agar proses penyimpanan preferensi dapat menangani kondisi error dengan baik.

#### Dokumentasi
| Light Mode | Dark Mode |
| :---: | :---: |
| <img src="./screenshot/Praktikum%201%20-%20Light%20mode.jpeg"> | <img src="./screenshot/Praktikum%201%20-%20Dark%20Mode.jpeg"> |

---
### **Praktikum 2 SQLite dan Repository Catatan**
- Menggunakan SQLite dengan `sqflite` untuk menyimpan data catatan secara permanen dan mendukung operasi CRUD.
- Membuat model `Note` untuk mengatur struktur data serta konversi antara object dan data SQLite.
- Memusatkan operasi database pada `NoteRepository` sehingga halaman aplikasi tidak mengakses SQLite secara langsung.

#### Dokumentasi
| Belum Ada Catatan | Pop-up Tambah Catatan | Daftar Catatan |
| :---: | :---: | :---: |
| <img src="./screenshot/Praktikum%202%20-%20Belum%20ada%20note.jpeg"> | <img src="./screenshot/Praktikum%202%20-%20Pop%20up%20Tambah%20Catatan.jpeg"> | <img src="./screenshot/Praktikum%202%20-%20Daftar%20catatan.jpeg"> |
---
### **Praktikum 3 Cache-First dan Sinkronisasi Data**
- Menerapkan strategi cache-first dengan membaca data dari cache lokal sebelum mengambil data dari API.
- Menyimpan data post yang berhasil diambil dari API ke SQLite agar tetap dapat digunakan saat offline.
- Menggunakan `dirty` flag untuk menandai catatan yang belum tersinkronisasi dan memisahkan proses sinkronisasi ke `sync.dart`.

#### Dokumentasi Cached Posts (Online dan Offline)
| Online | Offline (Mode Pesawat) |
| :---: | :---: |
| <img src="./screenshot/Praktikum%203%20-%20Chached%20Post%20Online.jpeg"> | <img src="./screenshot/Praktikum%203%20-%20Chached%20Post%20Offline.jpeg"> |

#### Dokumentasi Sinkronisasi Catatan Dirty
| Sebelum Sinkron | Sesudah Sinkron |
| :---: | :---: |
| <img src="./screenshot/Praktikum%203%20-%20Sebelum%20sinkron.jpeg"> | <img src="./screenshot/Praktikum%203%20-%20Sesudah%20sinkron.jpeg"> |

---
### AI Challenge

#### Prompt yang Digunakan
```
Aplikasi Flutter Offline Notes: CRUD catatan + preferensi tema.
Bandingkan SharedPreferences, Hive, sqflite (SQLite), dan Drift
untuk dua kebutuhan ini. Requirements:
- Kriteria: kompleksitas query, kebutuhan relasi, reaktivitas (stream),
  type-safety, ukuran boilerplate, dan kemudahan testing.
- Beri rekomendasi final: mana untuk preferensi, mana untuk catatan,
  beserta alasannya dalam 1 tabel.
- Tunjukkan skema tabel/kotak untuk 1000+ catatan.
Jelaskan trade-off setiap pilihan.
```

#### Output Awal AI

**Tabel Perbandingan**
| Kriteria | SharedPreferences | Hive | sqflite SQLite | Drift |
| --- | --- | --- | --- | --- |
| Kompleksitas query | Sangat sederhana karena menggunakan key-value. Tidak cocok untuk pencarian dan pengurutan banyak catatan. | Cocok untuk mengambil objek berdasarkan key, tetapi filter biasanya dilakukan di aplikasi. | Mendukung SQL seperti `WHERE`, `ORDER BY`, indeks, dan join. | Mendukung query relasional melalui SQL dan DSL dengan penggunaan yang lebih terstruktur. |
| Kebutuhan relasi | Tidak mendukung relasi. | Bukan database relasional sehingga relasi perlu dikelola sendiri. | Mendukung tabel, foreign key, dan join. | Mendukung relasi SQLite dengan API query yang lebih nyaman. |
| Reaktivitas | Tidak menyediakan stream perubahan data. | Dapat mengamati perubahan data melalui stream atau watch. | Tidak memiliki stream query bawaan sehingga perubahan perlu dikelola sendiri. | Query dapat diamati sebagai stream dan otomatis memberikan data terbaru ketika terjadi perubahan. |
| Type safety | Tipe data dasar terbatas dan tidak memiliki struktur khusus untuk catatan. | Mendukung model dan adapter, tetapi query tidak setipe seperti pada Drift. | Menggunakan SQL sehingga beberapa kesalahan baru diketahui saat aplikasi berjalan. | Memiliki type safety yang lebih tinggi karena skema dan query dapat diperiksa saat proses kompilasi. |
| Ukuran boilerplate | Paling sedikit untuk kebutuhan preferensi sederhana. | Relatif sedikit, tetapi tetap membutuhkan model dan adapter. | Membutuhkan SQL dan pemetaan hasil query ke model. | Membutuhkan setup dan code generation lebih banyak di awal, tetapi dapat mengurangi kode manual setelahnya. |
| Kemudahan testing | Relatif mudah untuk data preferensi sederhana. | Dapat diuji, tetapi perlu menyiapkan adapter dan database. | Dapat menggunakan database in-memory untuk menguji query dan perilaku database. | Dapat menggunakan SQLite in-memory, tetapi membutuhkan setup testing yang lebih banyak. |

**Rekomendasi AI**
| Kebutuhan | Pilihan AI | Alasan |
| --- | --- | --- |
| Preferensi tema | `SharedPreferences` | Data yang disimpan sederhana dan tidak membutuhkan relasi atau query kompleks. |
| Catatan 1000 atau lebih | `Drift` | Memiliki query yang lebih terstruktur, dukungan stream, dan type safety yang lebih baik. |

**Skema yang Diusulkan AI**
```sql
CREATE TABLE notes (
  id         INTEGER PRIMARY KEY AUTOINCREMENT,
  title      TEXT NOT NULL,
  content    TEXT NOT NULL,
  created_at INTEGER NOT NULL,
  updated_at INTEGER NOT NULL
);

CREATE INDEX idx_notes_updated_at ON notes(updated_at DESC);
```

#### AI Verification Checklist

| Poin Verifikasi | Hasil | Penjelasan |
| --- | --- | --- |
| Apakah AI menempatkan daftar catatan di SharedPreferences? | Tidak | AI menggunakan SharedPreferences untuk preferensi tema dan tidak merekomendasikannya untuk menyimpan daftar catatan. |
| Apakah skema AI sudah mendukung antrean sinkronisasi dengan `dirty` dan `updated_at`? | Tidak | Skema yang diberikan AI hanya memiliki `created_at` dan `updated_at`. Kolom `dirty` belum tersedia sehingga perlu ditambahkan pada implementasi aplikasi. |
| Apakah klaim real-time dari AI didukung oleh penggunaan stream? | Ya | AI menjelaskan bahwa Drift dapat menggunakan stream untuk memperbarui data ketika terjadi perubahan pada database. |
| Apakah perkiraan boilerplate sesuai dengan implementasi yang dilakukan? | Ya | Drift membutuhkan code generation dan setup tambahan sehingga lebih banyak persiapan dibandingkan `sqflite`. |

#### Keputusan Final
`SharedPreferences` digunakan untuk preferensi tema, sedangkan `sqflite` digunakan untuk catatan. `sqflite` dipilih karena sudah memenuhi kebutuhan CRUD dan sinkronisasi tanpa code generation tambahan. Kolom `dirty` ditambahkan untuk menandai catatan yang belum tersinkronisasi.

---
### Refactoring dan Testing
#### Refactoring Challenge

| Refactoring NoteTile | Refactoring Logic Sync | Refactoring Detail Catatan |
| :---: | :---: | :---: |
| <img src="./screenshot/Refactoring%20-%20nomor%201.jpeg" width="300"> | <img src="./screenshot/Refactoring%20-%20nomor%202.jpeg" width="300"> | <img src="./screenshot/Refactoring%20-%20nomor%203.jpeg" width="300"> |

#### Testing


| flutter analyze | flutter test |
| :---: | :---: |
| <img src="./screenshot/Refactoring%20flutter%20analyze.png" width="500"> | <img src="./screenshot/Refactoring%20flutter%20test.png" width="500"> |

---

#### Checklist Verifikasi Mandiri

- ☑ UI tidak mengakses SQLite atau SharedPreferences secara langsung, semua akses data melalui repository dan lapisan data.
- ☑ CRUD catatan dapat digunakan secara lokal tanpa koneksi internet.
- ☑ Badge `dirty` menampilkan status catatan yang belum tersinkronisasi.
- ☑ Cache posts dapat digunakan saat offline jika data sudah pernah tersimpan.
- ☑ `flutter analyze` tanpa issue dan semua test lulus.

---

### Refleksi

- **Mengapa akses `SharedPreferences` dan SQLite dipusatkan di repository, bukan dipanggil langsung di widget?**

    **Jawab :**

    Karena akses penyimpanan dipusatkan agar widget hanya menangani tampilan dan interaksi pengguna, sedangkan repository menangani proses penyimpanan dan pengambilan data sehingga kode lebih terstruktur dan mudah diuji.

- **Apa risiko pola cache-first jika aturan konflik last-write-wins tidak didefinisikan secara eksplisit?**

    **Jawab :**

    Data yang lebih lama bisa saja menimpa data yang lebih baru saat proses sinkronisasi. Jadi, aturan konflik perlu ditentukan supaya aplikasi tahu data mana yang harus dipertahankan.

- **Mengapa flag `dirty` penting untuk aplikasi offline-first, dan apa yang terjadi jika flag ini tidak ada?**

    **Jawab :** 

    Karena flag `dirty` membantu menandai catatan yang belum tersinkronisasi. Kalau flag ini tidak ada, aplikasi akan kesulitan mengetahui catatan mana yang masih perlu disinkronisasi.

- **Bagian mana dari rekomendasi AI yang Anda terima atau tolak, dan mengapa?**
   
    **Jawab :**

  Rekomendasi `SharedPreferences` untuk preferensi tema diterima, sedangkan rekomendasi Drift untuk catatan ditolak. `sqflite` dipilih karena sudah memenuhi kebutuhan CRUD dan sinkronisasi tanpa code generation tambahan.