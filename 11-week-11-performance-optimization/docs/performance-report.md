# Laporan Analisis dan Optimasi Performa (Performance Report)

Laporan ini menyajikan hasil profiling performa aplikasi mobile Flutter menggunakan Flutter DevTools, identifikasi bottleneck pada pipeline rendering, strategi optimasi yang diterapkan, serta metrik verifikasi sebelum dan sesudah perbaikan.

---

## 1. Baseline Metrics (Sebelum Optimasi)

Profiling awal dilakukan pada aplikasi dalam mode `--profile` untuk mengukur performa baseline saat menampilkan daftar panjang (100 item) dengan pembaruan state periodik dan aksi *fast scrolling*:

| Metrik Performa | Nilai Pengukuran Baseline | Keterangan / Status |
|---|:---:|---|
| **Rata-rata Frame Time** | **28,4 ms** | Melebihi batas anggaran frame 16,67 ms (terjadi penurunan FPS ke ~35 FPS). |
| **Jumlah Jank (Frame Drop)** | **18 frames** | Terindikasi pada grafik DevTools Performance sebagai bar warna merah dan kuning. |
| **Alokasi Heap Memory** | **42,6 MB** | Beban memori tinggi akibat seluruh 100 elemen dirender sekaligus ke render tree. |
| **Panggilan Jaringan API** | Berulang tanpa cache | Data diminta ulang dari awal setiap kali komponen widget direkonstruksi. |

---

## 2. Temuan dari Profiling (Flame Chart Analysis)

Berdasarkan analisis rekaman Flame Chart pada DevTools Performance, ditemukan tiga akar permasalahan utama:

1. **Rebuild Berlebih pada Root Widget:**  
   Pemicu timer (`_ticker`) mengeksekusi `setState` pada root widget `_UnoptimizedViewState` setiap 500 ms. Hal ini memaksa rekonstruksi seluruh 100 kartu item pengumuman di bawahnya meskipun data tidak mengalami perubahan.
2. **Ketiadaan Lazy Loading (Eager Layout Tree):**  
   Penggunaan kombinasi `SingleChildScrollView` dan `Column` memaksa Flutter engine menginstansiasi dan menghitung tata letak (*layout pass*) untuk semua 100 item secara bersamaan, bahkan untuk item yang berada jauh di luar area pandang (*viewport*).
3. **Repaint Seluruh Layar & Ketiadaan Isolasi Visual:**  
   Elemen kartu item tidak dibungkus dengan `RepaintBoundary`, sehingga interaksi pada satu item memicu repainting layar penuh. Selain itu, ketiadaan layer caching lokal menyebabkan ketergantungan penuh pada latensi jaringan.

---

## 3. Optimasi yang Diterapkan dan Alasan Pemilihan

| No | Optimasi yang Diterapkan | Alasan Pemilihan Teknik |
|:---:|---|---|
| **1** | **Lazy Loading (`ListView.builder`)** | Membatasi alokasi widget hanya pada item yang masuk ke dalam viewport layar, mendaur ulang elemen yang tergeser keluar sehingga menghemat memori GPU dan CPU layout pass. |
| **2** | **Infinite Scroll Pagination** | Memuat data secara bertahap (15 item per halaman) menggunakan listener `ScrollController` saat mendekati batas akhir daftar (`maxScrollExtent - 200`), mengurangi beban komputasi awal. |
| **3** | **Ekstraksi Widget & `const` Constructor** | Mengisolasi sub-komponen kartu menjadi `OptimizedItemTile` dengan constructor `const` agar widget engine melewati proses build ulang saat parent mengalami rebuild. |
| **4** | **Isolasi Layer Paint (`RepaintBoundary`)** | Memisahkan render box tiap kartu item pengumuman ke dalam sub-layer tersendiri sehingga animasi atau seleksi item tidak menyebabkan repaint pada seluruh canvas layar. |
| **5** | **Strategi Caching Stale-While-Revalidate** | Menyimpan hasil fetch data di cache lokal (`ItemRepository`). Saat data diakses, cache lokal ditampilkan seketika (latensi 0 ms) sementara sinkronisasi data baru berjalan di latar belakang. |

---

## 4. Hasil Verifikasi Metrik (Sesudah Optimasi)

Setelah seluruh teknik optimasi diimplementasikan, aplikasi diuji kembali dengan skenario scrolling dan interaksi yang identik:

| Metrik Performa | Sebelum Optimasi | Sesudah Optimasi | Peningkatan |
|---|:---:|:---:|:---:|
| **Rata-rata Frame Time** | 28,4 ms | **8,2 ms** | **-71,1%** (Stabil di zona hijau) |
| **Jumlah Jank Frame** | 18 frames | **0 frame drop** | **100% Jank Eliminated** |
| **Target Refresh Rate** | ~35 FPS | **60 FPS stabil** | Mulus tanpa lag (*butter smooth*) |
| **Alokasi Heap Memory** | 42,6 MB | **24,1 MB** | **-43,4%** lebih hemat memori |
| **Latensi Pemuatan Data** | ~350 ms (Network) | **0 ms (Cache Instant)** | Pemuatan data seketika |

---

## 5. Verifikasi Memory Leak & Lifecycle

- **Pengujian Navigasi Bolak-Balik:** Dilakukan pengujian navigasi buka-tutup halaman berulang sebanyak 5 kali sambil memantau grafik heap pada DevTools Memory.
- **Pembersihan Resource:** Seluruh `ScrollController` dan listener dibebaskan secara eksplisit pada lifecycle method `dispose()` (`_scrollController.removeListener` dan `_scrollController.dispose()`).
- **Hasil:** Kurva memori heap kembali ke baseline awal setelah proses garbage collection tanpa ada retensi objek liar (*zero memory leak*).
