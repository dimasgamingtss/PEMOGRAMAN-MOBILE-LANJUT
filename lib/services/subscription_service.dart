import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';

/// Service untuk mengelola subscription premium dan payment gateway
class SubscriptionService {
  static const String _premiumUsersKey = 'premium_users';
  static const String _paymentHistoryKey = 'payment_history';

  /// Harga premium (dalam Rupiah)
  static const double premiumPrice = 50000.0; // Rp 50.000

  /// Durasi premium (dalam hari)
  static const int premiumDurationDays = 30;

  /// Cek apakah user memiliki premium aktif
  static Future<bool> isPremiumActive(String username) async {
    try {
      final user = await _getUserFromStorage(username);
      if (user == null) return false;
      return user.isPremiumActive;
    } catch (e) {
      print('Error checking premium status: $e');
      return false;
    }
  }

  /// Upgrade user ke premium (simulasi payment gateway Duitku)
  static Future<Map<String, dynamic>> upgradeToPremium(
    String username,
    String paymentMethod,
  ) async {
    try {
      // Simulasi proses payment gateway Duitku
      await Future.delayed(const Duration(seconds: 2)); // Simulasi delay payment

      // Generate payment ID (simulasi dari Duitku)
      final paymentId = 'DUITKU_${DateTime.now().millisecondsSinceEpoch}';

      // Simulasi response dari Duitku
      final paymentResponse = {
        'status': 'success',
        'paymentId': paymentId,
        'amount': premiumPrice,
        'method': paymentMethod,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Simpan payment history
      await _savePaymentHistory(username, paymentResponse);

      // Update user premium status
      await _updatePremiumStatus(username, paymentId);

      return {
        'success': true,
        'paymentId': paymentId,
        'message': 'Upgrade ke Premium berhasil!',
      };
    } catch (e) {
      print('Error upgrading to premium: $e');
      return {
        'success': false,
        'message': 'Gagal upgrade ke Premium: $e',
      };
    }
  }

  /// Simulasi payment gateway Duitku
  static Future<Map<String, dynamic>> processDuitkuPayment({
    required String username,
    required double amount,
    required String paymentMethod,
  }) async {
    try {
      // Simulasi API call ke Duitku
      await Future.delayed(const Duration(seconds: 2));

      // Mock response dari Duitku
      final response = {
        'status': 'success',
        'paymentId': 'DUITKU_${DateTime.now().millisecondsSinceEpoch}',
        'amount': amount,
        'method': paymentMethod,
        'timestamp': DateTime.now().toIso8601String(),
        'merchantCode': 'MOCK_MERCHANT',
        'reference': 'REF_${username}_${DateTime.now().millisecondsSinceEpoch}',
      };

      return response;
    } catch (e) {
      return {
        'status': 'failed',
        'message': 'Payment gateway error: $e',
      };
    }
  }

  /// Update status premium user
  static Future<void> _updatePremiumStatus(
    String username,
    String paymentId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final premiumUsersJson = prefs.getStringList(_premiumUsersKey) ?? [];

      // Cari dan update user
      bool found = false;
      for (int i = 0; i < premiumUsersJson.length; i++) {
        final userData = jsonDecode(premiumUsersJson[i]);
        if (userData['username'] == username) {
          userData['isPremium'] = true;
          userData['premiumExpiryDate'] = DateTime.now()
              .add(Duration(days: premiumDurationDays))
              .toIso8601String();
          userData['premiumPaymentId'] = paymentId;
          userData['upgradedAt'] = DateTime.now().toIso8601String();
          premiumUsersJson[i] = jsonEncode(userData);
          found = true;
          break;
        }
      }

      // Jika belum ada, tambahkan baru
      if (!found) {
        premiumUsersJson.add(jsonEncode({
          'username': username,
          'isPremium': true,
          'premiumExpiryDate': DateTime.now()
              .add(Duration(days: premiumDurationDays))
              .toIso8601String(),
          'premiumPaymentId': paymentId,
          'upgradedAt': DateTime.now().toIso8601String(),
        }));
      }

      await prefs.setStringList(_premiumUsersKey, premiumUsersJson);
    } catch (e) {
      print('Error updating premium status: $e');
      rethrow;
    }
  }

  /// Simpan payment history
  static Future<void> _savePaymentHistory(
    String username,
    Map<String, dynamic> paymentData,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_paymentHistoryKey) ?? [];
      historyJson.add(jsonEncode({
        'username': username,
        ...paymentData,
      }));
      await prefs.setStringList(_paymentHistoryKey, historyJson);
    } catch (e) {
      print('Error saving payment history: $e');
    }
  }

  /// Get user dari storage (helper method)
  static Future<User?> _getUserFromStorage(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList('users') ?? [];

      for (String userJson in usersJson) {
        final user = User.fromJson(jsonDecode(userJson));
        if (user.username == username) {
          // Cek premium status dari premium_users
          final premiumUsersJson = prefs.getStringList(_premiumUsersKey) ?? [];
          for (String premiumJson in premiumUsersJson) {
            final premiumData = jsonDecode(premiumJson);
            if (premiumData['username'] == username) {
              return user.copyWith(
                isPremium: premiumData['isPremium'] ?? false,
                premiumExpiryDate: premiumData['premiumExpiryDate'] != null
                    ? DateTime.parse(premiumData['premiumExpiryDate'])
                    : null,
                premiumPaymentId: premiumData['premiumPaymentId'],
              );
            }
          }
          return user;
        }
      }
      return null;
    } catch (e) {
      print('Error getting user from storage: $e');
      return null;
    }
  }

  /// Get payment history untuk user
  static Future<List<Map<String, dynamic>>> getPaymentHistory(
    String username,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final historyJson = prefs.getStringList(_paymentHistoryKey) ?? [];
      final userHistory = <Map<String, dynamic>>[];

      for (String historyItem in historyJson) {
        final data = jsonDecode(historyItem);
        if (data['username'] == username) {
          userHistory.add(data);
        }
      }

      return userHistory;
    } catch (e) {
      print('Error getting payment history: $e');
      return [];
    }
  }
}

