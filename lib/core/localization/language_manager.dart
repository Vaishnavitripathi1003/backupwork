import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../storage/user_pref.dart';
import 'app_localizations.dart';

class LanguageManager {
  LanguageManager._internal();
  static final LanguageManager instance = LanguageManager._internal();

  /// Global Notifier for Language ('en' or 'hi'). Initial default is ALWAYS English ('en').
  final ValueNotifier<String> languageNotifier = ValueNotifier<String>('en');

  bool get isHindi => languageNotifier.value == 'hi';

  /// Get current screen translations helper
  AppLocalizations get strings => AppLocalizations(isHindi: isHindi);

  /// Initialize language manager, forcing initial language to English ('en')
  Future<void> init() async {
    languageNotifier.value = 'en'; // Force default initial language to English
    try {
      final prefs = await SharedPreferences.getInstance();
      final userPref = UserPref(prefs);
      // Reset any previously cached Hindi preference to false on startup
      await userPref.setHindiReport(false);
    } catch (e) {
      languageNotifier.value = 'en';
      debugPrint("LanguageManager init error: $e");
    }
  }

  /// Change language globally ('en' or 'hi')
  Future<void> setLanguage(String code) async {
    if (languageNotifier.value == code) return;
    languageNotifier.value = code;

    try {
      final prefs = await SharedPreferences.getInstance();
      final userPref = UserPref(prefs);
      await userPref.setHindiReport(code == 'hi');
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
