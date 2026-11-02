import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

class BiometricScanner {
  static const _channel = MethodChannel('com.daksh.app/scanner');

  static Future<bool> start10FingerScan({
    required String token,
    required String userDataId,
  }) async {
    try {
      final String? status = await _channel.invokeMethod('openBiometricScanner', {
        'userToken': token,
        'userDataId': userDataId,
      });
      return status == 'SUCCESS';
    } on PlatformException catch (e) {
      debugPrint("Biometric Scanner Error: ${e.message}");
      return false;
    }
  }

  static Future<bool> startGroupScan({
    required String token,
    required String userDataId,
  }) async {
    debugPrint("openGroupBiometricScanner clalled");
    try {
      final String? status = await _channel.invokeMethod('openGroupBiometricScanner', {
        'userToken': token,
        'userDataId': userDataId,
      });
      return status == 'SUCCESS';
    } on PlatformException catch (e) {
      debugPrint("Group Biometric Scanner Error: ${e.message}");
      return false;
    }
  }

  static Future<bool> startAtdScan({
    required String token,
    required String userDataId,
  }) async {
    debugPrint("openAtdScanner called");
    try {
      final String? status = await _channel.invokeMethod('openAtdScanner', {
        'userToken': token,
        'userDataId': userDataId,
      });
      debugPrint("ATD Scanner status: ${status}");
      return status == 'SUCCESS';
    } on PlatformException catch (e) {
      debugPrint("ATD Scanner Error: ${e.message}");
      return false;
    }
  }
}
