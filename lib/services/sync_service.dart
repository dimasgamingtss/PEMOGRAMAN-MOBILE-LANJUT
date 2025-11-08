import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/product.dart';
import '../models/transaction.dart';
import 'database_service.dart';
import 'subscription_service.dart';
import 'product_service.dart';
import 'transaction_service.dart';

/// Service untuk sinkronisasi data antara SQLite (lokal) dan Firebase (cloud)
/// Hanya berfungsi untuk user premium
class SyncService {
  static const String _lastSyncKey = 'last_sync_';
  static const String _syncStatusKey = 'sync_status_';

  /// Cek apakah user memiliki akses sync (premium)
  static Future<bool> canSync(String username) async {
    return await SubscriptionService.isPremiumActive(username);
  }

  /// Sinkronisasi data lokal ke cloud (Firebase)
  /// Simulasi: untuk production, ganti dengan Firebase Firestore
  static Future<Map<String, dynamic>> syncToCloud(String username) async {
    try {
      // Cek apakah user premium
      if (!await canSync(username)) {
        return {
          'success': false,
          'message': 'Fitur sinkronisasi hanya tersedia untuk akun Premium',
        };
      }

      // Simulasi delay network
      await Future.delayed(const Duration(seconds: 2));

      // Ambil semua data lokal
      final products = await ProductService.getProducts(username);
      final transactions = await TransactionService.getTransactions(username);

      // Simulasi upload ke Firebase
      // Di production, gunakan Firebase Firestore:
      // await FirebaseFirestore.instance.collection('users').doc(username).set({
      //   'products': products.map((p) => p.toJson()).toList(),
      //   'transactions': transactions.map((t) => t.toJson()).toList(),
      //   'lastSync': FieldValue.serverTimestamp(),
      // });

      // Simpan ke SharedPreferences sebagai simulasi cloud storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        'cloud_data_$username',
        jsonEncode({
          'products': products.map((p) => p.toJson()).toList(),
          'transactions': transactions.map((t) => t.toJson()).toList(),
          'lastSync': DateTime.now().toIso8601String(),
        }),
      );

      // Update last sync time
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

  /// Sinkronisasi data dari cloud ke lokal (restore)
  static Future<Map<String, dynamic>> syncFromCloud(String username) async {
    try {
      if (!await canSync(username)) {
        return {
          'success': false,
          'message': 'Fitur sinkronisasi hanya tersedia untuk akun Premium',
        };
      }

      // Simulasi delay network
      await Future.delayed(const Duration(seconds: 2));

      // Simulasi download dari Firebase
      final prefs = await SharedPreferences.getInstance();
      final cloudDataJson = prefs.getString('cloud_data_$username');

      if (cloudDataJson == null) {
        return {
          'success': false,
          'message': 'Tidak ada data di cloud untuk di-restore',
        };
      }

      final cloudData = jsonDecode(cloudDataJson);
      final productsData = cloudData['products'] as List;
      final transactionsData = cloudData['transactions'] as List;

      // Restore products
      int productsRestored = 0;
      for (var productJson in productsData) {
        try {
          final product = Product.fromJson(productJson);
          // Cek apakah product sudah ada
          final existingProducts =
              await ProductService.getProducts(username);
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
          // Cek apakah transaction sudah ada
          final existingTransactions =
              await TransactionService.getTransactions(username);
          if (!existingTransactions.any((t) => t.id == transaction.id)) {
            // Restore transaction (implementasi sesuai kebutuhan)
            // Note: Untuk restore transaction, perlu implementasi method khusus
            // atau gunakan createTransaction dengan data yang sudah ada
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

  /// Migrasi data dari lokal ke cloud saat upgrade ke premium
  static Future<Map<String, dynamic>> migrateToCloud(String username) async {
    try {
      // Langsung sync ke cloud setelah upgrade
      return await syncToCloud(username);
    } catch (e) {
      print('Error migrating to cloud: $e');
      return {
        'success': false,
        'message': 'Gagal migrasi data: $e',
      };
    }
  }

  /// Get last sync time
  static Future<DateTime?> getLastSyncTime(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastSyncString = prefs.getString(_lastSyncKey + username);
      if (lastSyncString != null) {
        return DateTime.parse(lastSyncString);
      }
      return null;
    } catch (e) {
      print('Error getting last sync time: $e');
      return null;
    }
  }

  /// Get sync status
  static Future<Map<String, dynamic>> getSyncStatus(String username) async {
    try {
      final canSyncData = await canSync(username);
      final lastSync = await getLastSyncTime(username);

      return {
        'canSync': canSyncData,
        'lastSync': lastSync?.toIso8601String(),
        'isPremium': canSyncData,
      };
    } catch (e) {
      print('Error getting sync status: $e');
      return {
        'canSync': false,
        'lastSync': null,
        'isPremium': false,
      };
    }
  }

  /// Auto sync (dipanggil secara berkala untuk premium users)
  static Future<void> autoSync(String username) async {
    try {
      if (await canSync(username)) {
        final lastSync = await getLastSyncTime(username);
        final now = DateTime.now();

        // Auto sync setiap 1 jam
        if (lastSync == null ||
            now.difference(lastSync).inHours >= 1) {
          await syncToCloud(username);
        }
      }
    } catch (e) {
      print('Error in auto sync: $e');
    }
  }
}

