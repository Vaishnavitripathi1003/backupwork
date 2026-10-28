import 'dart:convert';

import 'package:daksh/core/models/user.dart';

/// Root Response Model for FingerScan Response API
class FingerScanResponse {
  final String? message;
  final int? statusCode;
  final User? data;

  FingerScanResponse({
    this.message,
    this.statusCode,
    this.data,
  });

  factory FingerScanResponse.fromJson(Map<String, dynamic> json) {
    return FingerScanResponse(
      message: json['message'] as String?,
      statusCode: json['status_code'] as int?,
      data: json['data'] != null ? User.fromJson(json['data']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'status_code': statusCode,
      'data': data?.toJson(),
    };
  }

  static FingerScanResponse fromRawJson(String str) =>
      FingerScanResponse.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());
}

