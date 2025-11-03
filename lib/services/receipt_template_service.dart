import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/receipt_template.dart';

class ReceiptTemplateService {
  static const String _key = 'receipt_template';

  static Future<ReceiptTemplate> getTemplate() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString(_key);
    if (jsonString != null) {
      return ReceiptTemplate.fromJson(jsonDecode(jsonString));
    } else {
      // Default template
      return ReceiptTemplate(
        storeName: 'POS APP',
        description: 'Aplikasi Point of Sales',
        address: 'Jl. Soekarno-Hatta No. 123, Jepara',
        phone: '(021) 1234-5678',
        footer1: 'Terima Kasih',
        footer2: 'Atas Kunjungan Anda',
      );
    }
  }

  static Future<void> saveTemplate(ReceiptTemplate template) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(template.toJson()));
  }
} 