import 'dart:convert';
import 'package:flutter/services.dart';

class NativeScan {
  NativeScan._();

  // Must match CHANNEL in MainActivity.kt exactly
  static const _channel = MethodChannel('com.example.fingerprintworkdemo/native');

  static Future<bool> hasCameraPermission() async =>
      (await _channel.invokeMethod<bool>('hasCameraPermission')) ?? false;

  static Future<bool> requestCameraPermission() async =>
      (await _channel.invokeMethod<bool>('requestCameraPermission')) ?? false;

  /// mode: 'group' (Thumb + 4 fingers) or 'single' (10 fingertips).
  /// Returns the parsed results, or an empty list if the user cancelled.
  static Future<List<Map<String, dynamic>>> startScan({
    required String mode,
    List<String>? steps,
  }) async {
    if (!await hasCameraPermission()) {
      if (!await requestCameraPermission()) {
        throw PlatformException(
          code: 'PERMISSION_DENIED',
          message: 'Camera permission not granted',
        );
      }
    }

    /*final json = await _channel.invokeMethod<String>('startScan', {
      'mode': mode,
      if (steps != null) 'steps': steps,
    });*/
    final json = await _channel.invokeMethod<String>('startScan', {
      'mode': mode,        // "group" or "individual"
      if (steps != null) 'steps': steps,
    });
    if (json == null || json.isEmpty) return [];
    final decoded = jsonDecode(json) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }
}