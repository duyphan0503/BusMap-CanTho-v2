// lib/src/providers/localization_provider.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalizationProvider extends ChangeNotifier {
  // Phương thức để chuyển đổi ngôn ngữ
  Future<void> toggleLocale(BuildContext context) async {
    final currentLocale = context.locale;

    if (currentLocale.languageCode == 'vi') {
      await context.setLocale(Locale('en'));
    } else {
      await context.setLocale(Locale('vi'));
    }

    // Lưu ngôn ngữ đã chọn
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('locale', context.locale.languageCode);

    notifyListeners();
  }
}