
# UTS Pemrograman Mobile Lanjut TIFB

## Kelompok
1. Muhammad Dimas Arya Nugroho (221240001316)
2. Janziar Nanda Veranty (221240001321)

## Product Requirement Document (PRD) — Aplikasi POS Penjualan (Versi Revisi Monetisasi)

### 1. Deskripsi Produk
Aplikasi POS Penjualan adalah aplikasi kasir digital berbasis Android yang membantu pelaku UMKM mengelola penjualan, mencatat transaksi, dan mencetak struk otomatis. Kini aplikasi dikembangkan dalam dua versi — **Gratis** dan **Premium Berbayar** — untuk memberikan fleksibilitas bagi pengguna sesuai kebutuhan usahanya.

### 2. Tujuan Pengembangan
- Menyediakan solusi kasir digital dengan fitur cetak struk otomatis.
- Meningkatkan efisiensi pencatatan dan pelaporan transaksi penjualan.
- Menyediakan opsi monetisasi (gratis dan berbayar) agar aplikasi berkelanjutan.
- Mendukung digitalisasi UMKM dengan fitur sinkronisasi data online di versi premium.

### 3. Fitur Utama
| Kategori | Fitur | Deskripsi |
|-----------|--------|-----------|
| Autentikasi | Login & Registrasi | Pengguna login sebelum mengakses aplikasi; mendukung multi-user. |
| Dashboard | Ringkasan penjualan & navigasi cepat | Menampilkan total penjualan harian, akses cepat ke menu utama. |
| Produk | CRUD Produk | Tambah, ubah, hapus produk dengan harga dan stok. |
| Transaksi | Penjualan cepat & input kuantitas | Pilih produk, masukkan jumlah, dan hitung total otomatis. |
| Cetak Struk | Print via Bluetooth / Thermal Printer | Setelah transaksi, pengguna dapat mencetak struk langsung ke printer kasir. |
| Riwayat Transaksi | Daftar transaksi sebelumnya | Lihat detail transaksi, termasuk salinan struk digital. |
| Laporan Penjualan | Statistik & grafik otomatis | Tampilkan total, rata-rata, produk terjual, dan grafik penjualan. |
| Monetisasi | Gratis dan Premium | Sistem pembagian versi: Gratis (dengan iklan), Premium (tanpa iklan + sinkronisasi online). |

### 4. Fitur Premium (Berbayar)
1. Sinkronisasi Online Otomatis  
2. Multi-Device Login (maksimal 3 perangkat)  
3. Tanpa Iklan  
4. Backup & Restore Otomatis  
5. Upgrade Data Otomatis dari Versi Gratis  
6. Pembayaran via Payment Gateway (Duitku)

### 5. Kebutuhan Non-Fungsional
| Aspek | Keterangan |
|--------|-------------|
| Platform | Android (mobile-based) |
| Database | Versi Gratis: SQLite (lokal), Versi Premium: Online Database (Firebase/Server API) |
| UI/UX | Tampilan simple, modern, dan responsif |
| Keamanan | Enkripsi data & autentikasi akun |
| Performa | Ringan, cepat, kompatibel dengan printer Bluetooth |
| Integrasi | Thermal printer (58mm/80mm), Payment Gateway Duitku |

### 6. Kelebihan Produk
- Tampilan lebih simple dan menarik setelah revisi UI/UX.  
- Mendukung mode offline (gratis) dan online (premium).  
- Cetak struk otomatis gratis tanpa langganan tambahan.  
- Upgrade data mudah dari lokal ke cloud.  
- Pembayaran premium aman melalui gateway resmi.  
- Cocok untuk UMKM dengan skala usaha berkembang.

### 7. Model Monetisasi
| Versi | Fitur Utama | Keterangan |
|--------|--------------|------------|
| Gratis | Semua fitur dasar POS, cetak struk, laporan, dengan iklan. | Data disimpan lokal (offline). |
| Premium (Berbayar) | Sinkronisasi data online, multi-device, tanpa iklan, backup otomatis. | Berbasis server dengan integrasi payment gateway Duitku. |

### 8. Perbandingan dengan Aplikasi Rujukan
| Aplikasi | Kekurangan | Keunggulan Aplikasi Ini |
|-----------|-------------|--------------------------|
| Kasir Pintar | Premium mahal, cetak struk terbatas | Cetak struk gratis dan opsi premium terjangkau |
| Cazh POS | Tidak mendukung printer Bluetooth | Mendukung thermal printer 58/80mm |
| Simple Kasir | Tidak ada laporan grafik visual | Ada grafik penjualan otomatis |
| Aplikasi Ini (Revisi) | — | Ada sistem monetisasi (gratis & premium online) |

### 9. Kesimpulan
Aplikasi POS Penjualan kini hadir dengan sistem monetisasi yang jelas dan profesional. Pengguna dapat memilih versi gratis (offline + iklan) atau premium (online + tanpa iklan + multi-device). Dengan dukungan payment gateway Duitku dan tampilan UI/UX simple dan bersih, aplikasi ini menjadi solusi kasir digital yang efisien, fleksibel, dan layak untuk dikembangkan secara komersial.

### UI/UX Aplikasi POS Penjualan
1. **Loading, Login & Registrasi:** Tempat pengguna masuk dan membuat akun baru.  
2. **Dashboard Utama:** Menampilkan total penjualan harian dan menu utama.  
3. **Manajemen Produk:** Daftar produk, stok, harga, tombol tambah produk.  
4. **Transaksi Baru:** Pilih produk, input jumlah, dan cetak struk.  
5. **Cetak Struk:** Menampilkan hasil transaksi dalam bentuk struk digital/print.  
6. **Riwayat Transaksi:** Menampilkan transaksi sebelumnya dengan total harga dan tanggal.  
7. **Laporan Penjualan:** Grafik total penjualan, rata-rata transaksi, produk terjual.
