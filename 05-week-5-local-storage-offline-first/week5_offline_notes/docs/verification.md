# Laporan verifikasi Offline Notes

Tanggal pemeriksaan: 2026-10-05

## Ringkasan checklist

| Checklist | Status | Bukti dan batasan |
|---|---|---|
| UI tidak mengakses SQLite atau SharedPreferences secara langsung | **Lulus untuk halaman UI** | Pemanggilan plugin penyimpanan berada di repository dan lapisan data. Halaman memakai provider/repository. Operasi cache posts masih dijalankan langsung oleh helper di `lib/data/sync.dart`, bukan melalui repository khusus cache. |
| Baca, tambah, dan hapus catatan dapat bekerja tanpa internet | **Didukung implementasi; belum diuji di perangkat mode pesawat** | Catatan dibaca, ditambah, dan dihapus melalui `NoteRepository` lokal berbasis SQLite. Alur ini tidak memerlukan permintaan jaringan. Konfirmasi runtime tetap perlu dilakukan pada emulator/perangkat dengan mode pesawat. |
| Badge dirty akurat sebelum/sesudah sync | **Akurat untuk status lokal; sync server belum tersedia** | Catatan baru ditandai `dirty`, badge menghitung item dirty dari daftar lokal, lalu daftar dimuat ulang sesudah sinkronisasi. Namun, `syncNotes` saat ini hanya menunggu satu detik dan mengubah flag menjadi bersih; tidak ada pengiriman catatan ke server. Jadi badge menunjukkan status simulasi lokal, bukan konfirmasi sinkronisasi server. |
| Cache posts tampil tanpa internet | **Lulus jika cache sudah pernah terisi** | Posts yang tersimpan dibaca terlebih dahulu dan refresh jaringan berjalan di latar belakang. Pada instalasi baru tanpa cache dan tanpa internet, pengambilan awal gagal karena tidak ada data lokal untuk ditampilkan. |
| `flutter analyze` tanpa issue | **Lulus** | `flutter analyze` — `No issues found!` |
| Semua test lulus | **Lulus** | `flutter test` — 4 test lulus, 0 gagal. |
| Hasil AI diverifikasi dan didokumentasikan di `docs/` | **Lulus** | Ringkasan ini mencatat hasil verifikasi otomatis, inspeksi alur, dan batasan yang belum diuji manual. |

## Perintah validasi

Dijalankan dari direktori `week5_offline_notes`:

```text
flutter analyze
flutter test
```

## Cakupan test saat ini

`test/note_test.dart` memeriksa pemulihan model dari field yang hilang, serialisasi flag dirty, serta kondisi sukses dan error pada provider catatan menggunakan repository palsu. Test ini tidak membuka SQLite sungguhan, memeriksa interaksi UI badge, mensimulasikan kegagalan jaringan, atau menguji perangkat dalam mode pesawat.

## Tindak lanjut sebelum menyatakan verifikasi end-to-end

1. Uji baca/tambah/hapus catatan pada emulator atau perangkat setelah mengaktifkan mode pesawat.
2. Isi cache posts ketika online, aktifkan mode pesawat, lalu pastikan daftar cache tetap terlihat.
3. Tentukan dan implementasikan kontrak API sinkronisasi catatan sebelum menganggap perubahan dirty telah tersinkron ke server.
4. Tambahkan test integrasi untuk SQLite/cache dan test widget untuk badge sebelum/sesudah sinkronisasi.
