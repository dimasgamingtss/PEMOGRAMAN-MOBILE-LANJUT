# Contoh Implementasi Firebase di SyncService

Setelah Firebase berhasil di-setup, update `lib/services/sync_service.dart` dengan kode berikut.

## Update Import

Tambahkan di bagian atas file:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
```

## Update Method syncToCloud

Ganti method `syncToCloud` dengan implementasi Firebase yang sebenarnya:

```dart
static Future<Map<String, dynamic>> syncToCloud(String username) async {
  try {
    // Cek apakah user premium
    if (!await canSync(username)) {
      return {
        'success': false,
        'message': 'Fitur sinkronisasi hanya tersedia untuk akun Premium',
      };
    }

    // Ambil semua data lokal
    final products = await ProductService.getProducts(username);
    final transactions = await TransactionService.getTransactions(username);

    // Upload ke Firebase Firestore
    final firestore = FirebaseFirestore.instance;
    final userRef = firestore.collection('users').doc(username);

    // Simpan products
    final productsData = products.map((p) => p.toJson()).toList();
    
    // Simpan transactions
    final transactionsData = transactions.map((t) => t.toJson()).toList();

    // Update document di Firestore
    await userRef.set({
      'products': productsData,
      'transactions': transactionsData,
      'lastSync': FieldValue.serverTimestamp(),
      'username': username,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    // Update last sync time lokal
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _lastSyncKey + username,
      DateTime.now().toIso8601String(),
    );

    return {
      'success': true,
      'message': 'Data berhasil disinkronisasi ke cloud',
      'productsCount': products.length,
      'transactionsCount': transactions.length,
      'lastSync': DateTime.now().toIso8601String(),
    };
  } catch (e) {
    print('Error syncing to cloud: $e');
    return {
      'success': false,
      'message': 'Gagal sinkronisasi: $e',
    };
  }
}
```

## Update Method syncFromCloud

Ganti method `syncFromCloud` dengan implementasi Firebase:

```dart
static Future<Map<String, dynamic>> syncFromCloud(String username) async {
  try {
    if (!await canSync(username)) {
      return {
        'success': false,
        'message': 'Fitur sinkronisasi hanya tersedia untuk akun Premium',
      };
    }

    // Download dari Firebase Firestore
    final firestore = FirebaseFirestore.instance;
    final userDoc = await firestore.collection('users').doc(username).get();

    if (!userDoc.exists) {
      return {
        'success': false,
        'message': 'Tidak ada data di cloud untuk di-restore',
      };
    }

    final data = userDoc.data()!;
    final productsData = data['products'] as List<dynamic>? ?? [];
    final transactionsData = data['transactions'] as List<dynamic>? ?? [];

    // Restore products
    int productsRestored = 0;
    for (var productJson in productsData) {
      try {
        final product = Product.fromJson(productJson);
        final existingProducts = await ProductService.getProducts(username);
        if (!existingProducts.any((p) => p.id == product.id)) {
          await ProductService.addProduct(
            product.name,
            product.price,
            product.stock,
            username,
          );
          productsRestored++;
        }
      } catch (e) {
        print('Error restoring product: $e');
      }
    }

    // Restore transactions
    int transactionsRestored = 0;
    for (var transactionJson in transactionsData) {
      try {
        final transaction = Transaction.fromJson(transactionJson);
        final existingTransactions = await TransactionService.getTransactions(username);
        if (!existingTransactions.any((t) => t.id == transaction.id)) {
          // Restore transaction
          await TransactionService.createTransaction(
            transaction.items,
            username,
          );
          transactionsRestored++;
        }
      } catch (e) {
        print('Error restoring transaction: $e');
      }
    }

    return {
      'success': true,
      'message': 'Data berhasil di-restore dari cloud',
      'productsRestored': productsRestored,
      'transactionsRestored': transactionsRestored,
    };
  } catch (e) {
    print('Error syncing from cloud: $e');
    return {
      'success': false,
      'message': 'Gagal restore data: $e',
    };
  }
}
```

## Setup Firestore Database di Firebase Console

1. Buka Firebase Console → Firestore Database
2. Klik "Create database"
3. Pilih "Start in test mode" (untuk development)
4. Pilih location (pilih yang terdekat, misal: `asia-southeast2`)
5. Klik "Enable"

## Setup Security Rules (Penting!)

Buka Firestore → Rules dan update dengan:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection - hanya user yang login bisa akses data sendiri
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
  }
}
```

**Catatan:** Untuk production, gunakan rules yang lebih ketat!

---

**Setelah semua diupdate, test sinkronisasi data dari aplikasi!**

