# Panduan Setup Firebase untuk Aplikasi POS

Panduan lengkap untuk mengintegrasikan Firebase ke aplikasi POS Penjualan.

## 📋 Daftar Isi

1. [Membuat Firebase Project](#1-membuat-firebase-project)
2. [Menambahkan Android App ke Firebase](#2-menambahkan-android-app-ke-firebase)
3. [Download google-services.json](#3-download-google-servicesjson)
4. [Setup Dependencies](#4-setup-dependencies)
5. [Konfigurasi Android](#5-konfigurasi-android)
6. [Update Kode Aplikasi](#6-update-kode-aplikasi)
7. [Testing](#7-testing)

---

## 1. Membuat Firebase Project

### Langkah-langkah:

1. **Buka Firebase Console**
   - Kunjungi: https://console.firebase.google.com/
   - Login dengan akun Google Anda

2. **Buat Project Baru**
   - Klik "Add project" atau "Tambah project"
   - Masukkan nama project: `POS Penjualan` (atau nama lain)
   - Klik "Continue"

3. **Setup Google Analytics (Opsional)**
   - Pilih apakah ingin mengaktifkan Google Analytics
   - Jika ya, pilih atau buat Google Analytics account
   - Klik "Create project"

4. **Tunggu Firebase menyiapkan project**
   - Proses ini memakan waktu beberapa detik
   - Klik "Continue" setelah selesai

---

## 2. Menambahkan Android App ke Firebase

### Langkah-langkah:

1. **Buka Project Settings**
   - Di Firebase Console, klik ikon ⚙️ (Settings)
   - Pilih "Project settings"

2. **Tambahkan Android App**
   - Scroll ke bawah ke bagian "Your apps"
   - Klik ikon Android (🟢)
   - Atau klik "Add app" → pilih Android

3. **Isi Informasi Android App**
   
   **Android package name:**
   - Buka file: `android/app/build.gradle.kts`
   - Cari `applicationId` (biasanya di `android` block)
   - Copy nilai `applicationId` (contoh: `com.example.pos_app`)
   - Paste ke Firebase Console

   **App nickname (opsional):**
   - Masukkan: `POS Penjualan Android`
   
   **Debug signing certificate SHA-1 (opsional untuk sekarang):**
   - Bisa dikosongkan dulu
   - Akan diperlukan nanti untuk fitur seperti Authentication

4. **Klik "Register app"**

---

## 3. Download google-services.json

### Langkah-langkah:

1. **Download File**
   - Setelah register app, Firebase akan menampilkan tombol "Download google-services.json"
   - Klik tombol tersebut

2. **Tempatkan File**
   - File yang didownload: `google-services.json`
   - **PENTING:** Letakkan file ini di:
     ```
     android/app/google-services.json
     ```
   - Pastikan file berada di folder `android/app/` (sama level dengan `build.gradle.kts`)

3. **Verifikasi Lokasi File**
   ```
   POS PEMOGRAMAN MOBILE/
   └── android/
       └── app/
           ├── google-services.json  ← File ini harus ada di sini
           ├── build.gradle.kts
           └── src/
   ```

---

## 4. Setup Dependencies

### Langkah-langkah:

1. **Buka `pubspec.yaml`**

2. **Uncomment Dependencies Firebase**
   
   Cari baris ini (sekitar line 47-50):
   ```yaml
   # Firebase dependencies (uncomment when ready to use Firebase)
   # firebase_core: ^3.6.0
   # cloud_firestore: ^5.4.3
   # firebase_auth: ^5.3.1
   ```
   
   Ubah menjadi:
   ```yaml
   # Firebase dependencies
   firebase_core: ^3.6.0
   cloud_firestore: ^5.4.3
   firebase_auth: ^5.3.1
   ```

3. **Install Dependencies**
   ```bash
   flutter pub get
   ```

---

## 5. Konfigurasi Android

### Langkah-langkah:

1. **Update `android/build.gradle.kts` (Project Level)**
   
   Buka file: `android/build.gradle.kts`
   
   Tambahkan di bagian `buildscript` → `dependencies`:
   ```kotlin
   buildscript {
       dependencies {
           // ... dependencies yang sudah ada
           classpath("com.google.gms:google-services:4.4.2")
       }
   }
   ```

2. **Update `android/app/build.gradle.kts` (App Level)**
   
   Buka file: `android/app/build.gradle.kts`
   
   **Di bagian paling atas file**, tambahkan:
   ```kotlin
   plugins {
       id("com.android.application")
       id("kotlin-android")
       id("dev.flutter.flutter-gradle-plugin")
       id("com.google.gms.google-services")  // ← Tambahkan ini
   }
   ```
   
   **Atau jika menggunakan format lama**, tambahkan di bagian bawah file:
   ```kotlin
   apply plugin: 'com.google.gms.google-services'
   ```

3. **Verifikasi `minSdkVersion`**
   
   Pastikan `minSdkVersion` minimal 21:
   ```kotlin
   android {
       defaultConfig {
           minSdk = 21  // Minimal 21 untuk Firebase
       }
   }
   ```

---

## 6. Update Kode Aplikasi

### 6.1. Initialize Firebase di `main.dart`

Buka `lib/main.dart` dan update:

```dart
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';  // ← Tambahkan
import 'services/auth_service.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();  // ← Tambahkan ini
  
  runApp(const POSApp());
}
```

### 6.2. Update `sync_service.dart` untuk menggunakan Firebase

File sudah disiapkan dengan komentar untuk implementasi Firebase. Update bagian yang menggunakan simulasi dengan kode Firebase yang sebenarnya.

---

## 7. Testing

### Langkah-langkah:

1. **Clean Build**
   ```bash
   flutter clean
   flutter pub get
   ```

2. **Build dan Run**
   ```bash
   flutter run
   ```

3. **Cek Log**
   - Jika Firebase berhasil diinisialisasi, tidak akan ada error
   - Jika ada error, cek:
     - Apakah `google-services.json` sudah di tempat yang benar?
     - Apakah dependencies sudah di-install?
     - Apakah konfigurasi Android sudah benar?

---

## 🔧 Troubleshooting

### Error: "google-services.json not found"
- **Solusi:** Pastikan file `google-services.json` berada di `android/app/`
- Verifikasi nama file tepat: `google-services.json` (bukan `google-services (1).json`)

### Error: "Plugin with id 'com.google.gms.google-services' not found"
- **Solusi:** Pastikan classpath Google Services sudah ditambahkan di `android/build.gradle.kts`

### Error: "minSdkVersion terlalu rendah"
- **Solusi:** Update `minSdk` menjadi minimal 21 di `android/app/build.gradle.kts`

### Error: "FirebaseApp not initialized"
- **Solusi:** Pastikan `Firebase.initializeApp()` dipanggil sebelum `runApp()`

---

## 📝 Checklist Setup Firebase

- [ ] Firebase project sudah dibuat
- [ ] Android app sudah ditambahkan ke Firebase
- [ ] `google-services.json` sudah didownload dan diletakkan di `android/app/`
- [ ] Dependencies Firebase sudah di-uncomment di `pubspec.yaml`
- [ ] `flutter pub get` sudah dijalankan
- [ ] Google Services plugin sudah ditambahkan di `android/build.gradle.kts`
- [ ] Google Services plugin sudah diapply di `android/app/build.gradle.kts`
- [ ] `minSdkVersion` minimal 21
- [ ] `Firebase.initializeApp()` sudah ditambahkan di `main.dart`
- [ ] Aplikasi berhasil di-build tanpa error

---

## 🚀 Langkah Selanjutnya

Setelah Firebase berhasil di-setup:

1. **Update SyncService** untuk menggunakan Firestore
2. **Setup Firestore Database** di Firebase Console
3. **Setup Security Rules** untuk Firestore
4. **Test sinkronisasi data** dari aplikasi

---

**Catatan:** 
- Pastikan koneksi internet aktif saat testing
- Firebase memerlukan koneksi internet untuk berfungsi
- Untuk development, gunakan Firebase Emulator (opsional)

