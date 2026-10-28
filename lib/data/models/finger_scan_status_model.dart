import 'dart:convert';

class FingerScanStatusModel {
  String userId;
  String fingerScanStatus;
  String? createdAt;

  FingerScanStatusModel({
    this.userId = '',
    this.fingerScanStatus = '0',
    this.createdAt,
  });

  factory FingerScanStatusModel.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['fingerScanStatus'] ??
        json['isFingerScanned'] ??
        json['is_finger_scanned'] ??
        '0';

    return FingerScanStatusModel(
      userId: (json['userId'] ?? json['user_id'] ?? '').toString(),

      fingerScanStatus: rawStatus == true
          ? '1'
          : rawStatus == false
          ? '0'
          : rawStatus.toString(),

      createdAt: json['createdAt']?.toString() ??
          json['scannedAt']?.toString() ??
          json['scanned_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'fingerScanStatus': fingerScanStatus,
      'createdAt': createdAt ?? DateTime.now().toIso8601String(),
    };
  }

  static FingerScanStatusModel fromRawJson(String str) =>
      FingerScanStatusModel.fromJson(json.decode(str));

  String toRawJson() => json.encode(toJson());

  // Check whether fingerprint scanning is completed
  bool get isFingerScanned => fingerScanStatus == '1';
}