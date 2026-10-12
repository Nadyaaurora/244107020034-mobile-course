# Hasil Pengujian dan Verifikasi

## Pengujian manual FCM

Pengujian pada perangkat untuk tiga kondisi aplikasi telah dilakukan dan dilaporkan berhasil oleh pengguna. Pesan diterima, notifikasi ditampilkan, dan klik mengarahkan aplikasi menggunakan rute dalam `data.route`. Pengujian ini tidak dijalankan ulang oleh Copilot.

| Kondisi aplikasi | Penerimaan pesan | Tampilan notifikasi | Hasil klik | Rute tujuan | Status |
|---|---|---|---|---|---|
| Foreground | Berhasil | Notifikasi lokal berhasil ditampilkan | Klik berhasil | Sesuai `data.route` pada pesan uji | ✅ Berhasil |
| Background | Berhasil | Notifikasi berhasil ditampilkan | Klik berhasil | Sesuai `data.route` pada pesan uji | ✅ Berhasil |
| Terminated | Berhasil | Notifikasi berhasil ditampilkan | Klik berhasil membuka aplikasi | Sesuai `data.route` pada pesan uji | ✅ Berhasil |

Nama perangkat, isi payload, dan nilai rute spesifik tidak dicatat. Hasil manual tersebut merupakan laporan pengguna.

## Checklist verifikasi mandiri Section 7

| Pemeriksaan | Status | Bukti atau batasan |
|---|---|---|
| Konstanta rute dipusatkan dan digunakan pada konfigurasi GoRouter serta redirect autentikasi | Selesai dan terverifikasi | `routes.dart` menyediakan rute login, beranda, dan detail pengumuman. |
| `routeFromMessage()` menangani rute kosong dan relatif serta digunakan oleh `PushService` | Selesai dan terverifikasi | Tes memeriksa rute kosong, rute tanpa garis miring awal, dan rute dengan garis miring awal. Validasi navigasi tetap menolak rute eksternal dan backslash. |
| Pesan error Dio dipetakan dan ditampilkan di UI login | Implementasi pemetaan terverifikasi; integrasi API login belum tersedia | `apiErrorMessage()` digunakan untuk `DioException` di `LoginPage` dan pemetaannya diuji. Namun, `AuthRepository.login` saat ini masih simulasi dan belum membuat request Dio. |
| Access token dan refresh token disimpan secara aman | Implementasi tersedia dan diperiksa | `TokenStore` menggunakan `FlutterSecureStorage`. Tes klien memakai fake store dalam memori dan tidak menguji plugin penyimpanan pada perangkat. |
| Token tidak disimpan di SharedPreferences atau dicetak lengkap ke log | Selesai dan diperiksa pada kode | Tidak ditemukan penggunaan SharedPreferences untuk token maupun log yang mencetak token. Header autentikasi dikirim melalui request dan nilainya tidak dicatat. |
| Respons 401 memicu refresh lalu retry maksimal satu kali | Selesai dan terverifikasi oleh tes klien | `test/auth_push_test.dart` — `API client retries one unauthorized request with refreshed access` menjalankan interceptor produksi terhadap `HttpServer` lokal. Token tes adalah nilai dummy. |
| Refresh gagal atau retry tetap 401 membersihkan sesi | Selesai dan terverifikasi oleh tes klien | `test/auth_push_test.dart` — `failed token refresh clears the saved session` dan `a retried 401 clears the session without refreshing again` memeriksa penghapusan kedua token serta callback kedaluwarsa sesi. |
| Sesi kedaluwarsa mengubah status autentikasi menjadi belum login | Selesai dan terverifikasi oleh tes provider | `test/auth_push_test.dart` — `provider session expiration changes authenticated state to false` menjalankan `apiClientProvider` dan memeriksa `authStateProvider`. |
| API client dipakai untuk request backend dari repository aplikasi | Belum terintegrasi untuk request backend aplikasi | `apiClientProvider` tersedia dan dipakai oleh tes produksi, tetapi belum ada repository atau fitur aplikasi yang menggunakannya untuk request backend nyata. Login masih menggunakan repository simulasi. |
| Langganan topik untuk broadcast | Implementasi tersedia; pengiriman broadcast server belum diuji | `PushService` menyediakan langganan dan berhenti berlangganan `pengumuman-kampus`. |
| Pengiriman personal memakai token perangkat | Belum terintegrasi | Pendaftaran token perangkat ke `POST /devices` dan pengiriman dari backend belum tersedia atau teruji. |
| FCM foreground, background, dan terminated | Berhasil menurut pengujian manual pengguna | Hasil dipertahankan sebagai laporan pengguna, bukan pengujian perangkat yang dijalankan Copilot. |
| `flutter analyze` | Selesai dan terverifikasi pada 12 Oktober 2026 pukul 20.27 WIB | Pemeriksaan terakhir lulus tanpa temuan. |
| `flutter test` | Selesai dan terverifikasi pada 12 Oktober 2026 pukul 20.27 WIB | Semua tes otomatis lulus, termasuk tes klien dengan server lokal, pemetaan error, status provider, rute, dan widget. |
| `git diff --check` | Selesai dan terverifikasi pada 12 Oktober 2026 pukul 20.27 WIB | Perintah selesai tanpa menemukan masalah whitespace. |

Tes otomatis refresh menggunakan server HTTP lokal, auth fake, dan token dummy. Tes tersebut menjalankan kode produksi API client tanpa backend asli, token sungguhan, atau koneksi Firebase.

## Batasan integrasi

URL `https://example-campus-api.test` tetap alamat contoh yang sudah ada di proyek. Tidak ada endpoint backend aktif atau kontrak request yang dapat diverifikasi. Pengiriman token FCM ke `POST /devices` karena itu belum dihubungkan. Hasil uji manual notifikasi membuktikan alur penerimaan, tampilan, klik, dan navigasi yang diuji pengguna, bukan integrasi backend untuk token.
