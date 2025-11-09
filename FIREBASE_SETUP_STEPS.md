# 🚀 Setup Firebase - Langkah Praktis

Panduan cepat setup Firebase untuk aplikasi POS.

## ⚡ Quick Start

### Step 1: Buat Firebase Project
1. Buka https://console.firebase.google.com/
2. Klik "Add project"
3. Nama project: `POS Penjualan`
4. Ikuti wizard sampai selesai

### Step 2: Tambahkan Android App
1. Di Firebase Console → Project Settings
2. Scroll ke "Your apps" → Klik ikon Android 🟢
3. **Package name:** `com.example.pos_app` (cek di `android/app/build.gradle.kts` line 24)
4. App nickname: `POS Android`
5. Klik "Register app"

### Step 3: Download google-services.json
1. Klik "Download google-services.json"
2. **PENTING:** Letakkan file di:
   ```
   android/app/google-services.json
   ```
3. Pastikan file ada di folder `android/app/` (sama level dengan `build.gradle.kts`)

### Step 4: Update Dependencies

**Buka `pubspec.yaml`** dan uncomment baris ini (sekitar line 49-51):

```yaml
firebase_core: ^3.6.0
cloud_firestore: ^5.4.3
firebase_auth: ^5.3.1
```

Lalu jalankan:
```bash
flutter pub get
```

### Step 5: Update Android Configuration

#### A. Update `android/settings.gradle.kts`

Tambahkan di bagian `plugins` (sekitar line 19-23):

```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false  // ← TAMBAHKAN INI
}
```

#### B. Update `android/app/build.gradle.kts`

Tambahkan plugin di bagian `plugins` (sekitar line 1-6):

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ← TAMBAHKAN INI
}
```

### Step 6: Update main.dart

Buka `lib/main.dart` dan tambahkan:

```dart
import 'package:firebase_core/firebase_core.dart';  // ← Tambahkan import

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();  // ← Tambahkan ini
  
  runApp(const POSApp());
}
```

### Step 7: Clean & Build

```bash
flutter clean
flutter pub get
flutter run
```

---

## ✅ Checklist

- [ ] Firebase project dibuat
- [ ] Android app ditambahkan (package: `com.example.pos_app`)
- [ ] `google-services.json` di-download dan diletakkan di `android/app/`
- [ ] Dependencies Firebase di-uncomment di `pubspec.yaml`
- [ ] `flutter pub get` dijalankan
- [ ] Google Services plugin ditambahkan di `settings.gradle.kts`
- [ ] Google Services plugin ditambahkan di `app/build.gradle.kts`
- [ ] `Firebase.initializeApp()` ditambahkan di `main.dart`
- [ ] Aplikasi berhasil di-build

---

## 🔍 Verifikasi

Setelah setup, cek apakah Firebase sudah terhubung:

1. Jalankan aplikasi
2. Cek console/log - tidak ada error Firebase
3. Jika ada error, cek:
   - Apakah `google-services.json` sudah benar?
   - Apakah semua dependencies sudah terinstall?
   - Apakah konfigurasi Android sudah benar?

---

## 📝 Catatan Penting

1. **Package Name:** Pastikan package name di Firebase Console sama dengan di `android/app/build.gradle.kts` (line 24: `applicationId`)

2. **File Location:** `google-services.json` HARUS di `android/app/` (bukan di `android/`)

3. **Min SDK:** Sudah OK (minSdk = 21) ✅

4. **Internet:** Firebase memerlukan koneksi internet

---

## 🆘 Troubleshooting

### Error: "google-services.json not found"
→ Pastikan file ada di `android/app/google-services.json`

### Error: "Plugin not found"
→ Pastikan Google Services plugin sudah ditambahkan di `settings.gradle.kts`

### Error: "FirebaseApp not initialized"
→ Pastikan `Firebase.initializeApp()` dipanggil di `main.dart`

---

**Setelah setup selesai, lanjutkan ke update SyncService untuk menggunakan Firestore!**

