import 'package:shared_preferences/shared_preferences.dart';
import '../storage/user_pref.dart';

enum StartupDestination {
  dashboard,
  signIn,
}

class AppStartup {
  static Future<StartupDestination> getInitialDestination() async {
    final prefs = await SharedPreferences.getInstance();
    final userPref = UserPref(prefs);

    final token = userPref.getToken();
    if (token != null && token.isNotEmpty) {
      return StartupDestination.dashboard;
    }

    return StartupDestination.signIn;
  }
}
