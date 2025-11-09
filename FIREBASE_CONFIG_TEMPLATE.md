# Template Konfigurasi Firebase

File-file yang perlu diupdate untuk setup Firebase.

## 1. android/settings.gradle.kts

**TAMBAHKAN** baris ini di bagian `plugins` (setelah line 22):

```kotlin
plugins {
    id("dev.flutter.flutter-plugin-loader") version "1.0.0"
    id("com.android.application") version "8.7.3" apply false
    id("org.jetbrains.kotlin.android") version "2.1.0" apply false
    id("com.google.gms.google-services") version "4.4.2" apply false  // ← TAMBAHKAN
}
```

## 2. android/app/build.gradle.kts

**TAMBAHKAN** baris ini di bagian `plugins` (setelah line 5):

```kotlin
plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")  // ← TAMBAHKAN
}
```

## 3. pubspec.yaml

**UNCOMMENT** baris ini (sekitar line 49-51):

```yaml
firebase_core: ^3.6.0
cloud_firestore: ^5.4.3
firebase_auth: ^5.3.1
```

## 4. lib/main.dart

**TAMBAHKAN** import dan initialize:

```dart
import 'package:firebase_core/firebase_core.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp();  // ← TAMBAHKAN
  
  runApp(const POSApp());
}
```

## 5. File google-services.json

**DOWNLOAD** dari Firebase Console dan **LETAKKAN** di:
```
android/app/google-services.json
```

---

**Ikuti langkah-langkah di FIREBASE_SETUP_STEPS.md untuk detail lengkapnya!**

