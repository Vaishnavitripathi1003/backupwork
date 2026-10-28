import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/services.dart';

import '../../features/model/scan_models.dart';



class FingerChannelException implements Exception {
  FingerChannelException(this.code, this.message);
  final String code;
  final String? message;

  bool get isPermissionDenied => code == 'PERMISSION_DENIED';

  @override
  String toString() => 'FingerChannelException($code): $message';
}

/// Thin, typed wrapper around the native channel implemented in
/// `android/.../MainActivity.kt`. Keep ALL channel strings in this file.
class FingerChannel {
  FingerChannel._();

  static const MethodChannel _channel = MethodChannel('com.example.finger/native');

  /// The native scanner only exists on Android in this project.
  static bool get isSupported => Platform.isAndroid;

  static Future<T?> _invoke<T>(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on PlatformException catch (e) {
      throw FingerChannelException(e.code, e.message);
    } on MissingPluginException {
      throw FingerChannelException(
          'UNAVAILABLE', 'Native scanner is not available on this platform.');
    }
  }

  static Future<bool> hasCameraPermission() async =>
      await _invoke<bool>('hasCameraPermission') ?? false;

  static Future<bool> requestCameraPermission() async =>
      await _invoke<bool>('requestCameraPermission') ?? false;

  static Future<List<ScanStepInfo>> getScanSteps(ScanMode mode) async {
    final raw = await _invoke<List<dynamic>>(
        'getScanSteps', {'mode': mode.channelValue});
    return (raw ?? const [])
        .map((e) => ScanStepInfo.fromMap(e as Map<dynamic, dynamic>))
        .toList();
  }

  /// Opens the native camera flow. Returns every finger captured before the
  /// user finished/closed the screen (empty list = nothing captured).
  /// Pass [steps] (Kotlin enum names) to scan specific fingers only.
  static Future<List<ScanResult>> startScan({
    required ScanMode mode,
    List<String>? steps,
  }) async {
    final json = await _invoke<String>('startScan', {
      'mode': mode.channelValue,
      if (steps != null) 'steps': steps,
    });
    final list = jsonDecode(json ?? '[]') as List<dynamic>;
    return list
        .map((e) => ScanResult.fromJson(Map<String, dynamic>.from(e as Map)))
        .toList();
  }

  /// Runs the native enhancer + classifier on an existing image file
  /// (e.g. from a gallery picker).
  static Future<ScanResult> classifyImage({
    required String path,
    required String stepName,
  }) async {
    final json = await _invoke<String>(
        'classifyImage', {'path': path, 'step': stepName});
    return ScanResult.fromJson(
        Map<String, dynamic>.from(jsonDecode(json!) as Map));
  }

  /// Deletes all saved scan images. Returns number of files removed.
  static Future<int> clearScanCache() async =>
      await _invoke<int>('clearScanCache') ?? 0;
}
