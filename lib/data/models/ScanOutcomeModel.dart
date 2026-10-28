class ScanOutcome {
  final String status; // SUCCESS | FAILED | CANCELLED
  final String userDataId;
  final String? message;
  final int uploadedCount;

  const ScanOutcome({
    required this.status,
    required this.userDataId,
    this.message,
    this.uploadedCount = 0,
  });

  bool get isSuccess => status == 'SUCCESS';
  bool get isCancelled => status == 'CANCELLED';

  factory ScanOutcome.fromMap(Map<dynamic, dynamic>? m) => ScanOutcome(
    status: (m?['status'] as String?) ?? 'CANCELLED',
    userDataId: (m?['userDataId'] as String?) ?? '',
    message: m?['message'] as String?,
    uploadedCount: (m?['uploadedCount'] as int?) ?? 0,
  );
}
