import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app_localizations.dart';

class LanguageManager {
  LanguageManager._internal();
  static final LanguageManager instance = LanguageManager._internal();

  static const String _prefLanguageKey = 'app_selected_language_code';

  /// Global Notifier for Language code ('en', 'hi', 'ta', 'te', 'gu', 'mr', etc.)
  final ValueNotifier<String> languageNotifier = ValueNotifier<String>('en');

  String get currentLanguageCode => languageNotifier.value;
  bool get isHindi => languageNotifier.value == 'hi';

  /// Get current screen translations helper initialized with active language code
  AppLocalizations get strings => AppLocalizations(languageCode: currentLanguageCode);

  /// Load language from SharedPreferences on app startup
  Future<void> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedCode = prefs.getString(_prefLanguageKey);
      if (savedCode != null && savedCode.isNotEmpty) {
        languageNotifier.value = savedCode;
      } else {
        languageNotifier.value = 'en';
      }
    } catch (e) {
      languageNotifier.value = 'en';
      debugPrint("LanguageManager init error: $e");
    }
  }

  /// Change language globally to any language code ('en', 'hi', 'ta', 'te', 'gu', 'mr', 'bn', etc.)
  Future<void> setLanguage(String code) async {
    if (languageNotifier.value == code) return;
    languageNotifier.value = code;

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefLanguageKey, code);
    } catch (e) {
      debugPrint("LanguageManager setLanguage error: $e");
    }
  }

  /// Toggle language between English and Hindi
  Future<void> toggleLanguage() async {
    final next = isHindi ? 'en' : 'hi';
    await setLanguage(next);
  }
}
