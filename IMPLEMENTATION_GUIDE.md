# Panduan Implementasi - Fitur Monetisasi & Premium

Dokumen ini menjelaskan cara menggunakan fitur-fitur baru yang telah ditambahkan ke aplikasi POS.

## 🎯 Fitur yang Telah Diimplementasikan

### 1. Sistem Monetisasi (Gratis & Premium)

#### User Model
- Model `User` telah diperbarui dengan field:
  - `isPremium`: Status premium user
  - `premiumExpiryDate`: Tanggal kedaluwarsa premium
  - `premiumPaymentId`: ID pembayaran dari Duitku
  - `lastSyncDate`: Tanggal sinkronisasi terakhir

#### SubscriptionService
Service untuk mengelola subscription premium:
- `isPremiumActive(username)`: Cek status premium
- `upgradeToPremium(username, paymentMethod)`: Upgrade ke premium
- `processDuitkuPayment(...)`: Simulasi payment gateway

**Penggunaan:**
```dart
// Cek status premium
final isPremium = await SubscriptionService.isPremiumActive('username');

// Upgrade ke premium
final result = await SubscriptionService.upgradeToPremium(
  'username',
  'Bank Transfer',
);
```

### 2. Multi-Device Login

#### DeviceSessionService
Service untuk tracking dan membatasi login multi-device:
- Versi Gratis: Maksimal 1 perangkat
- Versi Premium: Maksimal 3 perangkat

**Cara Kerja:**
1. Saat login, device ID otomatis dideteksi
2. Sistem mengecek jumlah device yang sudah terdaftar
3. Jika melebihi batas, login ditolak dengan pesan yang jelas

**Penggunaan:**
```dart
// Register device session (otomatis dipanggil saat login)
final result = await DeviceSessionService.registerDeviceSession('username');

// Get daftar device
final sessions = await DeviceSessionService.getDeviceSessions('username');
```

### 3. Sinkronisasi Online

#### SyncService
Service untuk sinkronisasi data lokal ke cloud:
- Hanya tersedia untuk user Premium
- Auto-sync setiap 1 jam
- Manual sync saat upgrade

**Penggunaan:**
```dart
// Sync ke cloud
final result = await SyncService.syncToCloud('username');

// Restore dari cloud
final result = await SyncService.syncFromCloud('username');

// Migrasi data saat upgrade
final result = await SyncService.migrateToCloud('username');
```

### 4. Sistem Iklan

#### AdService
Service untuk menampilkan iklan (hanya untuk user gratis):
- Iklan ditampilkan setiap 5 interaksi
- Premium users tidak melihat iklan

**Penggunaan:**
```dart
// Cek apakah harus menampilkan iklan
final shouldShow = await AdService.shouldShowAd('username');

// Increment counter setelah interaksi
await AdService.incrementAdCounter('username');

// Widget banner ad
AdService.getBannerAdWidget()
```

### 5. Premium Upgrade Screen

Screen baru untuk proses upgrade ke Premium:
- Menampilkan fitur premium
- Pilihan metode pembayaran
- Proses payment via Duitku (simulasi)
- Migrasi data otomatis setelah upgrade

**Akses:**
- Dari Dashboard, klik icon bintang (⭐) di header
- Atau navigasi langsung ke `PremiumUpgradeScreen`

## 🔄 Alur Upgrade ke Premium

1. User klik tombol "Upgrade" di Dashboard
2. User memilih metode pembayaran
3. Sistem memproses payment via Duitku (simulasi)
4. Jika berhasil, user di-upgrade ke Premium
5. Data lokal otomatis di-migrate ke cloud
6. User sekarang memiliki akses ke semua fitur Premium

## 🔐 Alur Login Multi-Device

1. User login dengan username/password
2. Sistem mendeteksi device ID
3. Cek jumlah device yang sudah terdaftar:
   - Jika device sudah terdaftar: Update session, login berhasil
   - Jika device baru:
     - Gratis: Cek apakah sudah ada 1 device → Jika ya, tolak
     - Premium: Cek apakah sudah ada 3 device → Jika ya, tolak
4. Jika belum mencapai batas: Register device baru, login berhasil

## 📱 Integrasi dengan Screen yang Ada

### DashboardScreen
- Menampilkan badge "Premium" jika user premium
- Tombol upgrade (icon bintang) untuk user gratis
- Auto-sync untuk premium users saat load

### LoginScreen
- Sudah terintegrasi dengan device session validation
- Menampilkan pesan jika device limit reached

## 🛠️ Konfigurasi untuk Production

### 1. Firebase Setup
Untuk menggunakan sinkronisasi cloud yang sebenarnya:

1. Uncomment dependencies Firebase di `pubspec.yaml`
2. Setup Firebase project
3. Update `sync_service.dart`:
   ```dart
   // Ganti simulasi dengan Firebase Firestore
   await FirebaseFirestore.instance
       .collection('users')
       .doc(username)
       .set({
     'products': products.map((p) => p.toJson()).toList(),
     'transactions': transactions.map((t) => t.toJson()).toList(),
     'lastSync': FieldValue.serverTimestamp(),
   });
   ```

### 2. Duitku Payment Gateway
Untuk payment gateway yang sebenarnya:

1. Daftar di Duitku dan dapatkan API credentials
2. Update `subscription_service.dart`:
   ```dart
   // Ganti simulasi dengan API call yang sebenarnya
   final response = await http.post(
     Uri.parse('https://api.duitku.com/api/merchant/v1/inquiry'),
     headers: {'Content-Type': 'application/json'},
     body: jsonEncode({
       'merchantCode': 'YOUR_MERCHANT_CODE',
       'paymentAmount': amount,
       'paymentMethod': paymentMethod,
       // ... other parameters
     }),
   );
   ```

### 3. Google AdMob
Untuk iklan yang sebenarnya:

1. Setup AdMob account
2. Uncomment `google_mobile_ads` di `pubspec.yaml`
3. Update `ad_service.dart`:
   ```dart
   // Ganti simulasi dengan AdMob widget
   BannerAd(
     adUnitId: 'YOUR_BANNER_AD_UNIT_ID',
     size: AdSize.banner,
     request: AdRequest(),
     listener: BannerAdListener(),
   )
   ```

## 🧪 Testing

### Test Premium Upgrade
1. Login sebagai user gratis
2. Klik icon bintang di Dashboard
3. Pilih metode pembayaran
4. Klik "Upgrade Sekarang"
5. Verifikasi status premium berubah

### Test Multi-Device
1. Login dari device pertama (berhasil)
2. Login dari device kedua (gratis: gagal, premium: berhasil)
3. Login dari device ketiga (premium: berhasil)
4. Login dari device keempat (premium: gagal)

### Test Sinkronisasi
1. Upgrade ke premium
2. Buat beberapa produk dan transaksi
3. Sync ke cloud (otomatis atau manual)
4. Verifikasi data tersimpan di cloud

## 📝 Catatan Penting

1. **Device ID**: Menggunakan Android ID untuk Android, IdentifierForVendor untuk iOS
2. **Premium Expiry**: Default 30 hari, bisa disesuaikan di `SubscriptionService.premiumDurationDays`
3. **Auto Sync**: Berjalan di background setiap 1 jam untuk premium users
4. **Payment Simulation**: Saat ini menggunakan simulasi, perlu diganti dengan API sebenarnya untuk production

## 🐛 Troubleshooting

### Device limit error meskipun belum mencapai batas
- Pastikan device ID terdeteksi dengan benar
- Cek `DeviceSessionService.getDeviceId()` mengembalikan nilai yang valid

### Premium status tidak update
- Pastikan `SubscriptionService.isPremiumActive()` dipanggil setelah upgrade
- Refresh user data dengan `AuthService.getCurrentUser()`

### Sync gagal
- Pastikan user memiliki status premium aktif
- Cek koneksi internet
- Verifikasi Firebase configuration (jika menggunakan Firebase)

---

**Dibuat untuk**: UTS Pemrograman Mobile Lanjut TIFB  
**Versi**: 1.0.0

