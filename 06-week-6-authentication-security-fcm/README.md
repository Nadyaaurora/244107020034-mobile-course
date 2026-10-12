## Week 6 - Authentication, Secure Storage and Push Notification (FCM)
---

**Nama :** Nadya Aurora Gebi Agista

**NIM :** 244107020034
---

## Praktikum 1 Login, Secure Storage, dan Token Refresh

### Dokumentasi

| Halaman Login | Email dan Password Terisi |Login Gagal (Password Salah) | Login Berhasil |
| :---: | :---: | :---: | :---: |
| <img src="./screenshot/Praktikum%201%20-%20Login.jpeg"> | <img src="./screenshot/Praktikum%201%20-%20email%20dan%20password.jpeg">| <img src="./screenshot/Praktikum%201%20-%20Login%20gagal%20(Password%20salah).jpeg"> | <img src="./screenshot/Praktikum%201%20-%20Login%20berhasil.jpeg"> |

#### Pengamatan

- Pengguna yang belum login selalu diarahkan ke `/login`, sedangkan pengguna yang sudah login tidak bisa kembali ke halaman login.
- Login dengan email tanpa `@` atau kata sandi kurang dari 6 karakter ditolak dengan pesan kesalahan.
- Saat refresh token gagal, penyimpanan dibersihkan dan pengguna dipaksa login ulang.

---

## Praktikum 2 FCM, Permission, dan Token Lifecycle

### Dokumentasi

| Izin Notifikasi | Notifikasi Percobaan dari Firebase Console |
| :---: | :---: |
| <img src="./screenshot/Praktikum%202%20-%20Permission%20Notification.jpeg"> | <img src="./screenshot/Praktikum%202%20-%20Notifikasi%20Masuk.jpeg"> |

---

## Praktikum 3 Payload, Tiga App State, Klik, dan Topik

### Matriks Pengujian

| State | Yang Diharapkan | Cara Uji | Hasil |
| --- | --- | --- | :---: |
| Foreground | Banner lokal muncul, klik masuk ke `/pengumuman/3` | Aplikasi terbuka, kirim dari console atau backend | Berhasil |
| Background | Banner sistem muncul, klik masuk ke rute yang benar | Tekan Home, kirim, klik banner | Berhasil |
| Terminated | Aplikasi terbuka ke rute yang benar lewat `getInitialMessage` | Swipe-close aplikasi, kirim, klik banner | Berhasil |

### Dokumentasi

### **Foreground**

| Notifikasi Muncul | Halaman Tujuan Setelah Klik |
| :---: | :---: |
| <img src="./screenshot/Praktikum%203%20-%20Foreground.jpeg"> | <img src="./screenshot/Praktikum%203%20-%20Foreground%20Klik%20Notif.jpeg"> |

### **Background**

| Notifikasi Muncul | Halaman Tujuan Setelah Klik |
| :---: | :---: |
| <img src="./screenshot/Praktikum%203%20-%20Background.jpeg"> | <img src="./screenshot/Praktikum%203%20-%20Background%20Klik%20Notif.jpeg"> |

### **Terminated**

| Notifikasi Muncul | Halaman Tujuan Setelah Klik |
| :---: | :---: |
| <img src="./screenshot/Praktikum%203%20-%20Terminated.jpeg"> | <img src="./screenshot/Praktikum%203%20-%20Terminated%20Klik%20Notif.jpeg"> |

### **Topik `pengumuman-kampus`**

| Notifikasi Broadcast Muncul | Halaman Tujuan Setelah Klik |
| :---: | :---: |
| <img src="./screenshot/Praktikum%203%20-%20Topik.jpeg"> | <img src="./screenshot/Praktikum%203%20-%20Topik%20Klik%20Notif.jpeg"> |

---

## AI Challenge

### Prompt yang Digunakan

```
Aplikasi Flutter Campus Notification App.
Stack: firebase_messaging, flutter_local_notifications,
flutter_secure_storage, go_router, Riverpod.
Buatkan PushService dengan:
- requestPermission + getToken + onTokenRefresh (kirim ke POST /devices)
- onMessage (tampilkan local notification manual)
- onMessageOpenedApp + getInitialMessage (navigasi ke data.route)
- subscribe/unsubscribe topic pengumuman-kampus
- background handler top-level dengan @pragma('vm:entry-point')
Tandai bagian yang BERBEDA untuk Android 13+ vs iOS,
dan bagian yang tidak boleh mengakses BuildContext.
```

Output awal AI, daftar perbaikan manual, tabel hasil uji tiga app state, serta hasil `flutter analyze` dan `flutter test` untuk bagian ini didokumentasikan pada folder [`docs/`](./campus_notify/docs/).

---

## Refactoring dan Testing

### Refactoring Challenge

| No | Refactoring | Status | Keterangan |
| :---: | --- | :---: | --- |
| 1 | Pindahkan semua string rute ke `lib/routes.dart` | ☑ | Konstanta rute dipakai bersama oleh GoRouter dan deep link FCM sehingga tidak ada string rute yang tersebar. |
| 2 | Ekstrak parsing `RemoteMessage` menjadi fungsi murni `routeFromMessage` | ☑ | Logika routing dapat diuji tanpa Firebase. |
| 3 | Pindahkan pemetaan `DioException` ke `lib/data/api_errors.dart` | ☑ | UI hanya menerima pesan ramah pengguna untuk 401, timeout, dan offline. |

### Testing

| flutter analyze | flutter test |
| :---: | :---: |
| <img src="./screenshot/refactoring%20flutter%20analyze.png"> | <img src="./screenshot/refactoring%20flutter%20test.png"> |

---

## Checklist Verifikasi Mandiri

- ☑ Token hanya disimpan di `flutter_secure_storage`, tidak di `SharedPreferences`, log, atau screenshot penuh.
- ☑ HTTP 401 memicu refresh token dan retry maksimal satu kali. Jika refresh gagal, pengguna harus login kembali.
- ☑ Pengujian foreground, background, dan terminated berhasil. Klik notifikasi mengarahkan pengguna ke rute yang sesuai.
- ☑ Topik `pengumuman-kampus` digunakan untuk broadcast dan token perangkat digunakan untuk notifikasi personal.
- ☑ `flutter analyze` bersih dan semua test otomatis lulus.


---

## Refleksi

**1. Mengapa refresh token tidak boleh disimpan di SharedPreferences? Apa risikonya bila bocor?**

**Jawab :**

Refresh token tidak boleh disimpan di `SharedPreferences` karena penyimpanannya tidak dirancang khusus untuk melindungi data sensitif. Jika refresh token bocor, pihak lain dapat menggunakannya untuk meminta access token baru dan mengakses akun pengguna tanpa izin selama token tersebut masih berlaku. Oleh karena itu, refresh token sebaiknya disimpan menggunakan `flutter_secure_storage` agar perlindungannya lebih baik.

**2. Apa yang rusak bila `onTokenRefresh` diabaikan selama satu semester perkuliahan?**

**Jawab :**

Jika `onTokenRefresh` diabaikan, token FCM yang diperbarui tidak akan dikirim atau disimpan dengan benar. Akibatnya, server mungkin masih menggunakan token lama yang sudah tidak berlaku sehingga notifikasi tidak sampai ke perangkat pengguna. Hal ini dapat menyebabkan pengguna terlambat menerima informasi penting dari kampus.

**3. Kapan memakai topik dan kapan memakai token perangkat? Beri contoh pesan kampus untuk masing-masing.**

**Jawab :**

Topik digunakan untuk mengirim notifikasi kepada banyak pengguna yang berlangganan topik yang sama. Contohnya adalah pengumuman jadwal ujian yang dikirim melalui topik `pengumuman-kampus`. Sementara itu, token perangkat digunakan untuk mengirim notifikasi kepada pengguna tertentu. Contohnya adalah pemberitahuan pribadi kepada mahasiswa mengenai status pengajuan surat atau informasi akun miliknya.

**4. Bagian mana dari draf AI yang Anda tolak atau perbaiki, dan mengapa?**

**Jawab :**

Saya memperbaiki bagian draf AI yang belum sesuai dengan implementasi dan hasil pengujian aplikasi. Saya memastikan bahwa penjelasan mengenai penyimpanan token, proses refresh token, pengujian notifikasi pada tiga kondisi aplikasi, serta pengiriman notifikasi melalui topik dan token perangkat sesuai dengan fitur yang telah dibuat. Perbaikan ini dilakukan agar laporan tidak hanya berdasarkan saran AI, tetapi juga sesuai dengan implementasi dan hasil pengujian yang sebenarnya.