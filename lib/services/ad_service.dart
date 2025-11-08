import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'subscription_service.dart';

/// Service untuk mengelola iklan (hanya untuk versi gratis)
class AdService {
  static const String _adDisplayCountKey = 'ad_display_count_';
  static const String _lastAdDisplayKey = 'last_ad_display_';

  /// Cek apakah harus menampilkan iklan (hanya untuk user gratis)
  static Future<bool> shouldShowAd(String username) async {
    try {
      // User premium tidak melihat iklan
      final isPremium = await SubscriptionService.isPremiumActive(username);
      if (isPremium) {
        return false;
      }

      // Untuk user gratis, tampilkan iklan setiap 5 aksi
      final prefs = await SharedPreferences.getInstance();
      final displayCount = prefs.getInt(_adDisplayCountKey + username) ?? 0;

      // Tampilkan iklan setiap 5 interaksi
      return displayCount % 5 == 0 && displayCount > 0;
    } catch (e) {
      print('Error checking ad display: $e');
      return false;
    }
  }

  /// Increment ad display counter (dipanggil setelah interaksi user)
  static Future<void> incrementAdCounter(String username) async {
    try {
      final isPremium = await SubscriptionService.isPremiumActive(username);
      if (isPremium) {
        return; // Premium users tidak perlu tracking iklan
      }

      final prefs = await SharedPreferences.getInstance();
      final currentCount = prefs.getInt(_adDisplayCountKey + username) ?? 0;
      await prefs.setInt(_adDisplayCountKey + username, currentCount + 1);
      await prefs.setString(
        _lastAdDisplayKey + username,
        DateTime.now().toIso8601String(),
      );
    } catch (e) {
      print('Error incrementing ad counter: $e');
    }
  }

  /// Reset ad counter (untuk testing)
  static Future<void> resetAdCounter(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_adDisplayCountKey + username);
      await prefs.remove(_lastAdDisplayKey + username);
    } catch (e) {
      print('Error resetting ad counter: $e');
    }
  }

  /// Get ad display count
  static Future<int> getAdDisplayCount(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getInt(_adDisplayCountKey + username) ?? 0;
    } catch (e) {
      return 0;
    }
  }

  /// Simulasi menampilkan iklan banner
  /// Di production, gunakan Google AdMob atau platform iklan lainnya
  static Future<void> showBannerAd() async {
    // Simulasi: di production, tampilkan banner ad dari AdMob
    print('Banner Ad Displayed (Simulation)');
  }

  /// Simulasi menampilkan iklan interstisial
  static Future<void> showInterstitialAd() async {
    // Simulasi: di production, tampilkan interstitial ad dari AdMob
    print('Interstitial Ad Displayed (Simulation)');
  }

  /// Widget untuk menampilkan banner ad (placeholder)
  /// Di production, ganti dengan AdMob Banner Widget
  static Widget getBannerAdWidget() {
    return Container(
      height: 50,
      color: Colors.grey[300],
      child: const Center(
        child: Text(
          'Iklan Banner (Simulasi)',
          style: TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ),
    );
  }
}

