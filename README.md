# POS Penjualan - Aplikasi Point of Sales dengan Monetisasi

Aplikasi POS (Point of Sales) berbasis Flutter untuk Android yang membantu pelaku UMKM mengelola penjualan, mencatat transaksi, dan mencetak struk otomatis. Aplikasi ini dilengkapi dengan sistem monetisasi (Gratis dan Premium) dengan fitur sinkronisasi online, multi-device login, dan integrasi payment gateway.

## 📋 Daftar Isi

- [Fitur Utama](#fitur-utama)
- [Fitur Premium](#fitur-premium)
- [Struktur Proyek](#struktur-proyek)
- [Teknologi yang Digunakan](#teknologi-yang-digunakan)
- [Instalasi](#instalasi)
- [Konfigurasi](#konfigurasi)
- [Arsitektur](#arsitektur)
- [Dokumentasi API](#dokumentasi-api)
- [Testing](#testing)
- [Deployment](#deployment)

## ✨ Fitur Utama

### Versi Gratis
- ✅ Login & Registrasi Multi-User
- ✅ Dashboard dengan Ringkasan Penjualan Harian
- ✅ CRUD Produk (Tambah, Ubah, Hapus, Stok)
- ✅ Transaksi Penjualan dengan Perhitungan Otomatis
- ✅ Cetak Struk via Bluetooth/Thermal Printer
- ✅ Riwayat Transaksi
- ✅ Laporan Penjualan dengan Grafik
- ✅ Iklan Banner (untuk monetisasi)
- ✅ Data Lokal (SQLite)

### Versi Premium (Berbayar)
- ✅ Semua fitur versi Gratis
- ✅ **Sinkronisasi Online Otomatis** (Firebase/Cloud)
- ✅ **Multi-Device Login** (maksimal 3 perangkat)
- ✅ **Tanpa Iklan**
- ✅ **Backup & Restore Otomatis**
- ✅ **Migrasi Data Otomatis** dari lokal ke cloud
- ✅ **Payment Gateway Duitku** untuk pembayaran

## 🏗️ Struktur Proyek

```
lib/
├── main.dart                          # Entry point aplikasi
├── models/                            # Data models
│   ├── user.dart                      # Model User dengan premium status
│   ├── product.dart                   # Model Product
│   ├── transaction.dart               # Model Transaction
│   ├── receipt_template.dart          # Model Receipt Template
│   └── device_session.dart            # Model Device Session
├── screens/                           # UI Screens
│   ├── login_screen.dart              # Login & Registrasi
│   ├── dashboard_screen.dart          # Dashboard utama
│   ├── products_screen.dart           # Manajemen produk
│   ├── sales_screen.dart              # Transaksi penjualan
│   ├── transaction_history_screen.dart # Riwayat transaksi
│   ├── advanced_reports_screen.dart   # Laporan lanjutan
│   ├── receipt_template_screen.dart   # Template struk
│   └── premium_upgrade_screen.dart    # Upgrade ke Premium
└── services/                          # Business Logic Services
    ├── auth_service.dart              # Autentikasi & Login
    ├── subscription_service.dart       # Manajemen Premium & Payment
    ├── device_session_service.dart     # Tracking Multi-Device
    ├── sync_service.dart              # Sinkronisasi Cloud
    ├── ad_service.dart                # Manajemen Iklan
    ├── database_service.dart          # SQLite Database
    ├── product_service.dart           # CRUD Produk
    ├── transaction_service.dart       # Manajemen Transaksi
    └── receipt_template_service.dart  # Template Struk
```

## 🛠️ Teknologi yang Digunakan

### Core Dependencies
- **Flutter SDK** ^3.8.1
- **Dart** ^3.8.1

### Storage & Database
- `sqflite` ^2.3.0 - SQLite database untuk data lokal
- `shared_preferences` ^2.2.2 - Penyimpanan key-value untuk user preferences

### UI & Visualization
- `fl_chart` ^0.66.2 - Grafik dan chart untuk laporan
- `intl` ^0.19.0 - Formatting tanggal dan angka

### Printing
- `printing` ^5.11.1 - Cetak struk
- `pdf` ^3.10.7 - Generate PDF untuk struk

### Security & Authentication
- `crypto` ^3.0.3 - Enkripsi password (SHA-256)

### Device & Platform
- `device_info_plus` ^10.1.0 - Informasi device untuk multi-device tracking

### Optional (Commented in pubspec.yaml)
- `firebase_core` - Firebase initialization
- `cloud_firestore` - Firebase Firestore untuk cloud database
- `firebase_auth` - Firebase Authentication
- `google_mobile_ads` - Google AdMob untuk iklan

## 📦 Instalasi

### Prerequisites
- Flutter SDK (^3.8.1)
- Dart SDK (^3.8.1)
- Android Studio / VS Code dengan Flutter extension
- Android SDK (untuk build Android)

### Steps

1. **Clone repository**
   ```bash
   git clone <repository-url>
   cd "POS PEMOGRAMAN MOBILE"
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run aplikasi**
   ```bash
   flutter run
   ```

## ⚙️ Konfigurasi

### 1. Firebase Setup (Untuk Premium Features)

Jika ingin menggunakan Firebase untuk sinkronisasi online:

1. Buat project di [Firebase Console](https://console.firebase.google.com/)
2. Download `google-services.json` untuk Android
3. Letakkan di `android/app/google-services.json`
4. Uncomment dependencies Firebase di `pubspec.yaml`
5. Update `sync_service.dart` untuk menggunakan Firebase Firestore

### 2. Payment Gateway Duitku

Untuk integrasi payment gateway Duitku yang sebenarnya:

1. Daftar di [Duitku](https://dashboard.duitku.com/)
2. Dapatkan API Key dan Merchant Code
3. Update `subscription_service.dart` dengan API Duitku yang sebenarnya
4. Implementasikan webhook untuk verifikasi pembayaran

### 3. Google AdMob (Untuk Iklan)

Untuk menampilkan iklan yang sebenarnya:

1. Daftar di [Google AdMob](https://admob.google.com/)
2. Buat Ad Unit ID untuk Banner dan Interstitial
3. Uncomment `google_mobile_ads` di `pubspec.yaml`
4. Update `ad_service.dart` dengan AdMob implementation

## 🏛️ Arsitektur

Aplikasi menggunakan arsitektur **MVC (Model-View-Controller)** dengan pemisahan yang jelas:

### Model Layer
- **Models**: Data structures (`User`, `Product`, `Transaction`, dll)
- **Services**: Business logic dan data access layer

### View Layer
- **Screens**: UI components dan user interactions

### Controller Layer
- **Services**: Mengatur logika bisnis, validasi, dan koordinasi antara Model dan View

### Key Services

#### AuthService
- Registrasi dan login user
- Validasi multi-device login
- Manajemen session

#### SubscriptionService
- Manajemen status premium
- Integrasi payment gateway Duitku (mock/simulasi)
- Tracking payment history

#### DeviceSessionService
- Tracking device yang login
- Validasi batas maksimal device (1 untuk gratis, 3 untuk premium)
- Manajemen device sessions

#### SyncService
- Sinkronisasi data lokal ke cloud
- Restore data dari cloud
- Auto-sync untuk premium users
- Migrasi data saat upgrade

#### AdService
- Menampilkan iklan untuk user gratis
- Tracking ad display count
- Hide iklan untuk premium users

## 📚 Dokumentasi API

### AuthService

#### `register(String username, String password)`
Registrasi user baru.
```dart
final result = await AuthService.register('username', 'password');
if (result['success']) {
  // Registrasi berhasil
}
```

#### `login(String username, String password)`
Login user dengan validasi multi-device.
```dart
final result = await AuthService.login('username', 'password');
if (result['success']) {
  // Login berhasil
  final isPremium = result['isPremium'];
}
```

#### `getCurrentUser()`
Mendapatkan user yang sedang login.
```dart
final user = await AuthService.getCurrentUser();
```

### SubscriptionService

#### `isPremiumActive(String username)`
Cek apakah user memiliki premium aktif.
```dart
final isPremium = await SubscriptionService.isPremiumActive('username');
```

#### `upgradeToPremium(String username, String paymentMethod)`
Upgrade user ke premium.
```dart
final result = await SubscriptionService.upgradeToPremium(
  'username',
  'Bank Transfer',
);
```

### DeviceSessionService

#### `registerDeviceSession(String username)`
Register device session untuk user.
```dart
final result = await DeviceSessionService.registerDeviceSession('username');
if (!result['success']) {
  // Device limit reached
  print(result['message']);
}
```

#### `getDeviceSessions(String username)`
Mendapatkan daftar device yang terdaftar.
```dart
final sessions = await DeviceSessionService.getDeviceSessions('username');
```

### SyncService

#### `syncToCloud(String username)`
Sinkronisasi data lokal ke cloud.
```dart
final result = await SyncService.syncToCloud('username');
```

#### `syncFromCloud(String username)`
Restore data dari cloud ke lokal.
```dart
final result = await SyncService.syncFromCloud('username');
```

## 🧪 Testing

### Unit Testing
```bash
flutter test
```

### Integration Testing
```bash
flutter test integration_test/
```

## 🚀 Deployment

### Build APK
```bash
flutter build apk --release
```

### Build App Bundle (untuk Google Play Store)
```bash
flutter build appbundle --release
```

## 📝 Catatan Penting

### Monetisasi
- **Versi Gratis**: Data lokal, dengan iklan, 1 device
- **Versi Premium**: Data cloud, tanpa iklan, 3 devices, Rp 50.000/bulan

### Multi-Device Login
- Versi Gratis: Maksimal 1 perangkat
- Versi Premium: Maksimal 3 perangkat
- Sistem otomatis mendeteksi device ID dan membatasi login

### Sinkronisasi Data
- Untuk user Premium, data otomatis di-sync ke cloud setiap 1 jam
- Saat upgrade ke Premium, data lokal otomatis di-migrate ke cloud
- User dapat manual sync melalui menu (jika ditambahkan)

### Payment Gateway
- Saat ini menggunakan simulasi/mock Duitku
- Untuk production, perlu integrasi dengan API Duitku yang sebenarnya
- Payment ID disimpan untuk tracking

## 👥 Tim Pengembang

1. Muhammad Dimas Arya Nugroho (221240001316)
2. Janziar Nanda Veranty (221240001321)

## 📄 Lisensi

Proyek ini dibuat untuk keperluan UTS Pemrograman Mobile Lanjut TIFB.

## 🔗 Referensi

- [Flutter Documentation](https://flutter.dev/docs)
- [Duitku API Documentation](https://docs.duitku.com/)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google AdMob Documentation](https://developers.google.com/admob)

---

**Versi**: 1.0.0  
**Update Terakhir**: 2024
