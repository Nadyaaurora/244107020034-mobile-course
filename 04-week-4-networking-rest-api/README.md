# Tugas Praktikum Minggu 4: Networking & REST API dengan Riverpod
---
**Nama  :** Nadya Aurora Gebi Agista

**NIM   :** 244107020034

---
### Praktikum 1: Dio dan Model Data


#### Dokumentasi
| Sebelum  | Setelah Tombol Ditekan |
| :---: | :---: |
| <img src="./screenshot/Praktikum%201.jpeg"> | <img src="./screenshot/Praktikum%201_Pushed%20the%20Button.jpeg"> |

---
### Praktikum 2: Provider dan Error Handling

#### Skenario 1: Internet Normal
| Loading Awal | Daftar 100 Posts |
| :---: | :---: |
| <img src="./screenshot/Praktikum%202_awal%20data.jpeg"> | <img src="./screenshot/Praktikum%202_daftar%20100%20posts.jpeg"> |

#### Skenario 2: Mode Pesawat (Tanpa Internet)
| Pesan Error + Tombol Coba Lagi | Setelah Internet Dinyalakan Kembali |
| :---: | :---: |
| <img src="./screenshot/Praktikum%202_pesan%20dan%20coba%20lagi.jpeg"> | <img src="./screenshot/Praktikum%202_menggunakan%20internet.jpeg"> |

#### Skenario 3: baseUrl Diubah menjadi Salah
| Kode baseUrl Diubah (salah) | Kode baseUrl Dikembalikan (benar) |
| :---: | :---: |
| <img src="./screenshot/Praktikum%202_Nomor%203_code.png"> | <img src="./screenshot/Praktikum%202_Nomor%203_URL%20Benar_code.png"> |

| Error Koneksi (baseUrl salah) | Sukses (baseUrl dikembalikan) |
| :---: | :---: |
| <img src="./screenshot/Praktikum%202_ubah%20baseUrl.jpeg"> | <img src="./screenshot/Praktikum%202_baseUrl%20success.jpeg"> |

---
### Praktikum 3: Pagination Dasar

#### Dokumentasi
| Portrait | Landscape |
| :---: | :---: |
| <img src="./screenshot/Praktikum%203_portrait.jpeg"> | <img src="./screenshot/Praktikum%203_landscape.jpeg"> |

---
### AI Challenge

#### Prompt yang Digunakan
```
Buatkan repository layer Flutter untuk endpoint GET /comments?postId={id}
dari JSONPlaceholder menggunakan Dio + flutter_riverpod.
Requirements:
- Model Comment dengan fromJson aman null (postId, id, name, email, body).
- CommentRepository dengan method fetchComments(postId) + timeout 10 detik.
- AsyncNotifierProvider dengan penanganan error otomatis (AsyncError)
  dan fungsi pesan error ramah pengguna untuk timeout, connection error, 404, dan 500.
- Satu unit test untuk fromJson dengan field yang hilang.
Jelaskan setiap bagian kode dalam komentar.
```

#### Dokumentasi
<img src="./screenshot/AI%20Challenge.jpeg">

#### AI Verification Checklist
| Pemeriksaan | Hasil | Temuan |
| :--- | :---: | :--- |
| UI memanggil Dio langsung? | Lulus | UI menggunakan provider atau notifier. Dio hanya dibuat di `data/api_client.dart` dan digunakan oleh repository. |
| `Comment.fromJson` aman terhadap null/field hilang? | Lulus | Field angka menggunakan `num?` dengan fallback `0`, sedangkan field teks menggunakan fallback string kosong. |
| Timeout, connection error, 404, dan 500 dipetakan? | Lulus | `friendlyErrorMessage` menangani tiga jenis timeout, `connectionError`, status 404 dan 500, serta error jaringan lainnya. |
| `baseUrl` dan timeout terpusat? | Lulus | `api_client.dart` menjadi tempat konfigurasi `baseUrl` dan timeout 10 detik. Repository hanya menentukan path dan query. |
| Test menguji field hilang, bukan hanya happy path? | Lulus | `test/comment_test.dart` mengirim JSON kosong dan memverifikasi default seluruh field `Comment`. |
| `flutter analyze` dan `flutter test` bebas warning/error? | Lulus | `flutter analyze` menghasilkan `No issues found!` dan dua test terfokus berhasil dijalankan. |

**Struktur Akses Komentar**
- `CommentRepository.fetchComments(postId)` mengambil `GET /comments?postId={id}` melalui Dio.
- `commentsProvider` adalah `AsyncNotifierProvider.family`; exception dari repository otomatis menjadi `AsyncError`.
- `friendlyErrorMessage` mengubah error jaringan menjadi pesan yang dapat dipahami pengguna.

| flutter analyze (AI Challenge) | flutter test (AI Challenge) |
| :---: | :---: |
| <img src="./screenshot/AI%20-%20Flutter%20analyze.png"> | <img src="./screenshot/AI%20-%20Flutter%20test.png"> |

---
### Refactoring dan Testing

#### Refactoring Challenge
| No | Refactoring | Status | Keterangan |
| :---: | :--- | :---: | :--- |
| 1 | Ekstrak widget baris post menjadi `PostTile` tersendiri | ☑ | `ListView.builder` menjadi lebih pendek dan `PostTile` mudah diuji terpisah. |
| 2 | Pindahkan `friendlyErrorMessage` ke `lib/data/network_errors.dart` | ☑ | Dipakai ulang oleh halaman paged maupun non-paged. |
| 3 | Tambahkan halaman detail post via GoRouter (`/post/:id`) | ☑ | Menampilkan `title` dan `body` lengkap; data diambil dari list yang sudah dimuat atau repository. |

#### Dokumentasi
| Sebelum Refactoring (Data Awal) | Setelah Refactoring + PostTile | Setelah Refactoring (Data Akhir) |Halaman Detail Post (GoRouter) |
| :---: | :---: | :---: | :---: |
| <img src="./screenshot/Refactoting_paged%20awal%20data.jpeg"> | <img src="./screenshot/Refactoring_paged%20dan%20post%20tile.jpeg"> | <img src="./screenshot/Refactoring_paged%20akhir%20data.jpeg"> |<img src="./screenshot/Refactoring_detail%20post.jpeg"> |

#### Testing

| flutter analyze | flutter test |
| :---: | :---: |
| <img src="./screenshot/Testing%20-%20Flutter%20analyze.png"> | <img src="./screenshot/Testing%20-%20Flutter%20test.png"> |

---
#### Checklist Verifikasi Mandiri

Dokumentasi lengkap tersedia di [`docs/verification.md`](./week4_api/docs/verification.md).

- [x] UI tidak memanggil Dio langsung, semua akses data lewat repository + provider.
- [x] Empat state tampil benar: loading, error (+ retry), empty, success.
- [x] Pagination: data bertambah saat scroll, tidak ada request ganda, ada indikator akhir data.
- [x] `flutter analyze` tanpa issue dan semua test lulus.
- [x] Hasil AI diverifikasi dan didokumentasikan pada folder `docs/`.

### Struktur Folder
| <img src="./screenshot/Struktur folder.png"> |

---
### Refleksi
- **Mengapa UI dilarang memanggil Dio langsung? Apa yang rusak jika aturan ini dilanggar?**

  **Jawab:**

  UI yang memanggil Dio secara langsung membuat widget menangani tampilan sekaligus proses jaringan. Hal ini membuat kode sulit diuji, sulit digunakan kembali, dan dapat menyebabkan duplikasi kode. Dengan repository, UI cukup membaca data dari provider dan repository dapat diganti dengan repository palsu saat testing.

- **Kapan pagination client-side cukup, dan kapan harus mengandalkan pagination server (`_page`/`_limit`)?**

  **Jawab:**

  Pagination client-side cukup untuk jumlah data yang kecil dan masih aman disimpan di memori. Pagination server lebih tepat untuk data dalam jumlah besar karena menghemat bandwidth, waktu loading, dan penggunaan memori. Pagination server juga cocok untuk data yang terus bertambah seperti feed atau log.

- **Bagaimana exception repository berubah menjadi `AsyncError` tanpa try/catch di setiap widget? Kapan try/catch eksplisit tetap dibutuhkan?**

  **Jawab:**

  Exception yang terjadi di dalam AsyncNotifier.build() akan ditangkap Riverpod dan otomatis menjadi AsyncError. Karena itu, UI tidak perlu menggunakan try/catch untuk setiap widget. try/catch tetap diperlukan pada method seperti refresh() atau loadNextPage() agar error dapat ditangani dan ditampilkan pada UI.

- **Bagian mana dari hasil AI yang Anda perbaiki, dan mengapa?**

  **Jawab:**

  Hasil AI diperiksa dan diperbaiki pada CommentRepository, AsyncNotifierProvider, dan pengujian. Perbaikan dilakukan untuk memastikan UI tidak memanggil Dio langsung, fromJson() aman terhadap field yang hilang, error jaringan ditangani dengan baik, serta terdapat test untuk kondisi field yang hilang dan error.