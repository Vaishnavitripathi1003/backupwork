import 'package:shared_preferences/shared_preferences.dart';
import '../enums/subscription_level.dart';

class UserPref {
  final SharedPreferences _prefs;

  UserPref(this._prefs);

  static const String _keyToken = 'token';
  static const String _keyFirebaseToken = 'firebaseToken';
  static const String _keySubscription = 'subscription';
  static const String _keyHindiReport = 'hindiReport';
  static const String _keySelectedMemberId = 'selectedMemberId';
  static const String _keySelectedMemberName = 'selectedMemberName';

  Future<void> setToken(String? token) async {
    if (token == null) {
      await _prefs.remove(_keyToken);
    } else {
      await _prefs.setString(_keyToken, token);
    }
  }

  String? getToken() => _prefs.getString(_keyToken);

  Future<void> setFirebaseToken(String token) async {
    await _prefs.setString(_keyFirebaseToken, token);
  }

  String? getFirebaseToken() => _prefs.getString(_keyFirebaseToken);

  Future<void> setSubscription(SubscriptionLevel subscriptionLevel) async {
    await _prefs.setString(_keySubscription, subscriptionLevel.value);
  }

  SubscriptionLevel getSubscription() {
    final str = _prefs.getString(_keySubscription);
    return SubscriptionLevel.fromValue(str) ?? SubscriptionLevel.level1;
  }

  Future<void> setHindiReport(bool value) async {
    await _prefs.setBool(_keyHindiReport, value);
  }

  bool getHindiReport() => _prefs.getBool(_keyHindiReport) ?? false;

  Future<void> toggleLanguage() async {
    final current = getHindiReport();
    await setHindiReport(!current);
  }

  Future<void> setSelectedMember({required String id, required String name}) async {
    await _prefs.setString(_keySelectedMemberId, id);
    await _prefs.setString(_keySelectedMemberName, name);
  }

  String? getSelectedMemberId() => _prefs.getString(_keySelectedMemberId);
  String? getSelectedMemberName() => _prefs.getString(_keySelectedMemberName);

  Future<void> clearToken() async {
    await _prefs.clear();
  }
}
