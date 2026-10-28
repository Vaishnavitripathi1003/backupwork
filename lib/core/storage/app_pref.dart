import 'package:shared_preferences/shared_preferences.dart';

class AppPref {
  final SharedPreferences _prefs;

  AppPref(this._prefs);

  static const String _keyOnboarding = 'onBoarding';

  Future<void> setOnboarding(bool value) async {
    await _prefs.setBool(_keyOnboarding, value);
  }

  bool getOnboarding() => _prefs.getBool(_keyOnboarding) ?? false;

  Future<void> clearToken() async {
    await _prefs.clear();
  }
}
