import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'device_session_service.dart';
import 'subscription_service.dart';

class AuthService {
  static const String _usersKey = 'users';
  static const String _currentUserKey = 'current_user';

  // Hash password menggunakan SHA-256
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Registrasi pengguna baru
  static Future<Map<String, dynamic>> register(
    String username,
    String password,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      
      // Cek apakah username sudah ada
      for (String userJson in usersJson) {
        final user = User.fromJson(jsonDecode(userJson));
        if (user.username == username) {
          return {
            'success': false,
            'message': 'Username sudah digunakan',
          };
        }
      }

      // Buat user baru (default: gratis)
      final newUser = User(
        username: username,
        passwordHash: _hashPassword(password),
        isPremium: false,
      );

      usersJson.add(jsonEncode(newUser.toJson()));
      await prefs.setStringList(_usersKey, usersJson);
      
      // Register device session untuk user baru
      await DeviceSessionService.registerDeviceSession(username);
      
      return {
        'success': true,
        'message': 'Registrasi berhasil',
      };
    } catch (e) {
      print('Error during registration: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Login pengguna dengan validasi multi-device
  static Future<Map<String, dynamic>> login(
    String username,
    String password,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      
      final passwordHash = _hashPassword(password);
      User? foundUser;
      
      for (String userJson in usersJson) {
        final user = User.fromJson(jsonDecode(userJson));
        if (user.username == username && user.passwordHash == passwordHash) {
          foundUser = user;
          break;
        }
      }

      if (foundUser == null) {
        return {
          'success': false,
          'message': 'Username atau password salah',
        };
      }

      // Cek premium status dari subscription service
      final isPremium = await SubscriptionService.isPremiumActive(username);
      final updatedUser = foundUser.copyWith(isPremium: isPremium);

      // Validasi device session (multi-device check)
      final deviceResult =
          await DeviceSessionService.registerDeviceSession(username);
      
      if (!deviceResult['success']) {
        return {
          'success': false,
          'message': deviceResult['message'],
          'deviceLimitReached': true,
        };
      }

      // Simpan user yang sedang login dengan premium status terbaru
      await prefs.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));
      
      return {
        'success': true,
        'message': 'Login berhasil',
        'isPremium': isPremium,
      };
    } catch (e) {
      print('Error during login: $e');
      return {
        'success': false,
        'message': 'Error: $e',
      };
    }
  }

  // Logout pengguna
  static Future<void> logout(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_currentUserKey);
      
      // Hapus device session untuk device saat ini
      final deviceId = await DeviceSessionService.getDeviceId();
      await DeviceSessionService.removeDeviceSession(username, deviceId);
    } catch (e) {
      print('Error during logout: $e');
    }
  }

  // Dapatkan user yang sedang login dengan premium status terbaru
  static Future<User?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJson = prefs.getString(_currentUserKey);
      
      if (userJson != null) {
        final user = User.fromJson(jsonDecode(userJson));
        
        // Update premium status dari subscription service
        final isPremium =
            await SubscriptionService.isPremiumActive(user.username);
        
        return user.copyWith(isPremium: isPremium);
      }
      
      return null;
    } catch (e) {
      print('Error getting current user: $e');
      return null;
    }
  }

  // Cek apakah user sudah login
  static Future<bool> isLoggedIn() async {
    final currentUser = await getCurrentUser();
    return currentUser != null;
  }

  // Update user data (untuk update premium status, dll)
  static Future<bool> updateUser(User updatedUser) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final usersJson = prefs.getStringList(_usersKey) ?? [];
      
      for (int i = 0; i < usersJson.length; i++) {
        final user = User.fromJson(jsonDecode(usersJson[i]));
        if (user.username == updatedUser.username) {
          usersJson[i] = jsonEncode(updatedUser.toJson());
          await prefs.setStringList(_usersKey, usersJson);
          
          // Update current user jika sedang login
          final currentUser = await getCurrentUser();
          if (currentUser?.username == updatedUser.username) {
            await prefs.setString(_currentUserKey, jsonEncode(updatedUser.toJson()));
          }
          
          return true;
        }
      }
      
      return false;
    } catch (e) {
      print('Error updating user: $e');
      return false;
    }
  }
} 