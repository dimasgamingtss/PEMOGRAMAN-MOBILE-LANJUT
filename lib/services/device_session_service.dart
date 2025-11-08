import 'dart:convert';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart' show TargetPlatform;
import '../models/device_session.dart';
import 'subscription_service.dart';

/// Service untuk mengelola device sessions dan membatasi login multi-device
class DeviceSessionService {
  static const String _sessionsKey = 'device_sessions';
  static const String _deviceIdKey = 'device_id'; // Untuk menyimpan device ID di web
  static const int maxDevicesFree = 1; // Versi gratis hanya 1 device
  static const int maxDevicesPremium = 3; // Versi premium maksimal 3 devices

  /// Get device ID unik untuk perangkat ini
  static Future<String> getDeviceId() async {
    try {
      // Untuk web, gunakan localStorage untuk menyimpan device ID yang konsisten
      if (kIsWeb) {
        final prefs = await SharedPreferences.getInstance();
        String? deviceId = prefs.getString(_deviceIdKey);
        
        if (deviceId == null || deviceId.isEmpty) {
          // Generate device ID baru untuk web (berdasarkan timestamp + random)
          deviceId = 'web_${DateTime.now().millisecondsSinceEpoch}_${DateTime.now().hashCode}';
          await prefs.setString(_deviceIdKey, deviceId);
        }
        
        return deviceId;
      }

      // Untuk mobile (Android/iOS)
      final deviceInfo = DeviceInfoPlugin();
      String deviceId;

      try {
        if (defaultTargetPlatform == TargetPlatform.android) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceId = androidInfo.id; // Android ID
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceId = iosInfo.identifierForVendor ?? 'ios_unknown';
        } else {
          // Fallback untuk platform lain
          final prefs = await SharedPreferences.getInstance();
          String? savedDeviceId = prefs.getString(_deviceIdKey);
          if (savedDeviceId == null || savedDeviceId.isEmpty) {
            deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
            await prefs.setString(_deviceIdKey, deviceId);
          } else {
            deviceId = savedDeviceId;
          }
        }
      } catch (e) {
        // Jika device_info_plus gagal, gunakan fallback
        print('Error getting device info: $e');
        final prefs = await SharedPreferences.getInstance();
        String? savedDeviceId = prefs.getString(_deviceIdKey);
        if (savedDeviceId == null || savedDeviceId.isEmpty) {
          deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
          await prefs.setString(_deviceIdKey, deviceId);
        } else {
          deviceId = savedDeviceId;
        }
      }

      return deviceId;
    } catch (e) {
      print('Error getting device ID: $e');
      // Fallback: generate device ID berdasarkan timestamp
      final prefs = await SharedPreferences.getInstance();
      String? savedDeviceId = prefs.getString(_deviceIdKey);
      if (savedDeviceId == null || savedDeviceId.isEmpty) {
        final deviceId = 'device_${DateTime.now().millisecondsSinceEpoch}';
        await prefs.setString(_deviceIdKey, deviceId);
        return deviceId;
      }
      return savedDeviceId;
    }
  }

  /// Get device name
  static Future<String> getDeviceName() async {
    try {
      // Untuk web
      if (kIsWeb) {
        return 'Web Browser (Chrome/Edge/Firefox)';
      }

      // Untuk mobile
      final deviceInfo = DeviceInfoPlugin();
      String deviceName;

      try {
        if (defaultTargetPlatform == TargetPlatform.android) {
          final androidInfo = await deviceInfo.androidInfo;
          deviceName = '${androidInfo.brand} ${androidInfo.model}';
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          final iosInfo = await deviceInfo.iosInfo;
          deviceName = '${iosInfo.name} (${iosInfo.model})';
        } else {
          deviceName = 'Unknown Device';
        }
      } catch (e) {
        print('Error getting device name: $e');
        deviceName = 'Unknown Device';
      }

      return deviceName;
    } catch (e) {
      print('Error getting device name: $e');
      return 'Unknown Device';
    }
  }

  /// Register device session untuk user
  static Future<Map<String, dynamic>> registerDeviceSession(
    String username,
  ) async {
    try {
      final deviceId = await getDeviceId();
      final deviceName = await getDeviceName();
      final isPremium = await SubscriptionService.isPremiumActive(username);

      // Cek jumlah device yang sudah terdaftar
      final existingSessions = await getDeviceSessions(username);
      final maxDevices = isPremium ? maxDevicesPremium : maxDevicesFree;

      // Cek apakah device ini sudah terdaftar
      final existingSession = existingSessions.firstWhere(
        (session) => session.deviceId == deviceId,
        orElse: () => DeviceSession(
          deviceId: '',
          deviceName: '',
          loginTime: DateTime.now(),
        ),
      );

      if (existingSession.deviceId.isNotEmpty) {
        // Device sudah terdaftar, update login time
        await _updateSession(username, deviceId);
        return {
          'success': true,
          'message': 'Device session updated',
          'isNewDevice': false,
        };
      }

      // Cek apakah sudah mencapai batas maksimal
      if (existingSessions.length >= maxDevices) {
        return {
          'success': false,
          'message': isPremium
              ? 'Maksimal 3 perangkat untuk akun Premium. Silakan logout dari salah satu perangkat terlebih dahulu.'
              : 'Versi gratis hanya mendukung 1 perangkat. Upgrade ke Premium untuk menggunakan hingga 3 perangkat.',
          'maxDevices': maxDevices,
          'currentDevices': existingSessions.length,
        };
      }

      // Register device baru
      final newSession = DeviceSession(
        deviceId: deviceId,
        deviceName: deviceName,
        loginTime: DateTime.now(),
      );

      await _saveSession(username, newSession);

      return {
        'success': true,
        'message': 'Device registered successfully',
        'isNewDevice': true,
        'deviceName': deviceName,
      };
    } catch (e) {
      print('Error registering device session: $e');
      return {
        'success': false,
        'message': 'Error registering device: $e',
      };
    }
  }

  /// Get semua device sessions untuk user
  static Future<List<DeviceSession>> getDeviceSessions(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList(_sessionsKey) ?? [];
      final userSessions = <DeviceSession>[];

      for (String sessionJson in sessionsJson) {
        final data = jsonDecode(sessionJson);
        if (data['username'] == username) {
          userSessions.add(DeviceSession.fromJson(data['session']));
        }
      }

      return userSessions;
    } catch (e) {
      print('Error getting device sessions: $e');
      return [];
    }
  }

  /// Cek apakah device saat ini sudah terdaftar
  static Future<bool> isCurrentDeviceRegistered(String username) async {
    try {
      final deviceId = await getDeviceId();
      final sessions = await getDeviceSessions(username);
      return sessions.any((session) => session.deviceId == deviceId);
    } catch (e) {
      print('Error checking device registration: $e');
      return false;
    }
  }

  /// Hapus device session (untuk logout dari device tertentu)
  static Future<bool> removeDeviceSession(
    String username,
    String deviceId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList(_sessionsKey) ?? [];
      final updatedSessions = <String>[];

      for (String sessionJson in sessionsJson) {
        final data = jsonDecode(sessionJson);
        if (data['username'] == username &&
            data['session']['deviceId'] != deviceId) {
          updatedSessions.add(sessionJson);
        }
      }

      await prefs.setStringList(_sessionsKey, updatedSessions);
      return true;
    } catch (e) {
      print('Error removing device session: $e');
      return false;
    }
  }

  /// Hapus semua device sessions untuk user (untuk reset)
  static Future<bool> removeAllDeviceSessions(String username) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList(_sessionsKey) ?? [];
      final updatedSessions = <String>[];

      for (String sessionJson in sessionsJson) {
        final data = jsonDecode(sessionJson);
        if (data['username'] != username) {
          updatedSessions.add(sessionJson);
        }
      }

      await prefs.setStringList(_sessionsKey, updatedSessions);
      return true;
    } catch (e) {
      print('Error removing all device sessions: $e');
      return false;
    }
  }

  /// Simpan session ke storage
  static Future<void> _saveSession(
    String username,
    DeviceSession session,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList(_sessionsKey) ?? [];
      sessionsJson.add(jsonEncode({
        'username': username,
        'session': session.toJson(),
      }));
      await prefs.setStringList(_sessionsKey, sessionsJson);
    } catch (e) {
      print('Error saving session: $e');
      rethrow;
    }
  }

  /// Update session (update login time)
  static Future<void> _updateSession(
    String username,
    String deviceId,
  ) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final sessionsJson = prefs.getStringList(_sessionsKey) ?? [];
      final updatedSessions = <String>[];

      for (String sessionJson in sessionsJson) {
        final data = jsonDecode(sessionJson);
        if (data['username'] == username &&
            data['session']['deviceId'] == deviceId) {
          data['session']['loginTime'] = DateTime.now().toIso8601String();
          updatedSessions.add(jsonEncode(data));
        } else {
          updatedSessions.add(sessionJson);
        }
      }

      await prefs.setStringList(_sessionsKey, updatedSessions);
    } catch (e) {
      print('Error updating session: $e');
      rethrow;
    }
  }
}

