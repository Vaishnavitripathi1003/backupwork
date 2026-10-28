/// Response of GET findReportByUserParam?user_param=brain_dominance
///
/// { message: Success,
///   Report: { brain_dominance: {left_brain, right_brain}, _id: ... } }
double _d(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

class BrainDominanceResponse {
  final String message;
  final BrainDominanceReport? report;

  const BrainDominanceResponse({required this.message, this.report});

  factory BrainDominanceResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['Report'] ?? json['report'];
    Map<String, dynamic>? reportMap;
    if (raw is Map<String, dynamic>) {
      reportMap = raw;
    } else if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
      reportMap = raw.first as Map<String, dynamic>;
    }

    return BrainDominanceResponse(
      message: json['message']?.toString() ?? '',
      report: reportMap != null ? BrainDominanceReport.fromJson(reportMap) : null,
    );
  }
}

class BrainDominanceReport {
  final String id;
  final BrainDominanceData? brainDominance;

  const BrainDominanceReport({required this.id, this.brainDominance});

  factory BrainDominanceReport.fromJson(Map<String, dynamic> json) {
    final b = json['brain_dominance'];
    return BrainDominanceReport(
      id: json['_id']?.toString() ?? '',
      brainDominance:
      b is Map<String, dynamic> ? BrainDominanceData.fromJson(b) : null,
    );
  }
}

/// Values are shares (0..1), left + right = 1.
class BrainDominanceData {
  final double leftBrain;
  final double rightBrain;

  const BrainDominanceData({required this.leftBrain, required this.rightBrain});

  factory BrainDominanceData.fromJson(Map<String, dynamic> json) {
    return BrainDominanceData(
      leftBrain: _d(json['left_brain']),
      rightBrain: _d(json['right_brain']),
    );
  }

  double get leftPercent => leftBrain * 100;
  double get rightPercent => rightBrain * 100;

  bool get isRightDominant => rightBrain >= leftBrain;

  /// e.g. "Right Brain Dominant (51%)"
  String get label => isRightDominant
      ? 'Right Brain Dominant (${rightPercent.toStringAsFixed(0)}%)'
      : 'Left Brain Dominant (${leftPercent.toStringAsFixed(0)}%)';
}