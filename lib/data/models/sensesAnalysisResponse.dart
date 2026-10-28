/// Response of GET findReportByUserParam?user_param=senses_analysis
///
/// { message: Success,
///   Report: { senses: {taste, smell, touch, listen, see}, _id: ... } }
double _d(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

class SensesAnalysisResponse {
  final String message;
  final SensesAnalysisReport? report;

  const SensesAnalysisResponse({required this.message, this.report});

  factory SensesAnalysisResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['Report'] ?? json['report'];
    Map<String, dynamic>? reportMap;
    if (raw is Map<String, dynamic>) {
      reportMap = raw;
    } else if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
      reportMap = raw.first as Map<String, dynamic>;
    }

    return SensesAnalysisResponse(
      message: json['message']?.toString() ?? '',
      report: reportMap != null ? SensesAnalysisReport.fromJson(reportMap) : null,
    );
  }
}

class SensesAnalysisReport {
  final String id;
  final SensesData? senses;

  const SensesAnalysisReport({required this.id, this.senses});

  factory SensesAnalysisReport.fromJson(Map<String, dynamic> json) {
    final s = json['senses'];
    return SensesAnalysisReport(
      id: json['_id']?.toString() ?? '',
      senses: s is Map<String, dynamic> ? SensesData.fromJson(s) : null,
    );
  }
}

/// Values are shares (0..1) of the total.
class SensesData {
  final double taste;
  final double smell;
  final double touch;
  final double listen;
  final double see;

  const SensesData({
    required this.taste,
    required this.smell,
    required this.touch,
    required this.listen,
    required this.see,
  });

  factory SensesData.fromJson(Map<String, dynamic> json) {
    return SensesData(
      taste: _d(json['taste']),
      smell: _d(json['smell']),
      touch: _d(json['touch']),
      listen: _d(json['listen']),
      see: _d(json['see']),
    );
  }

  /// Handy for charts: label -> value (0..1).
  Map<String, double> get asMap => {
    'See': see,
    'Listen': listen,
    'Touch': touch,
    'Smell': smell,
    'Taste': taste,
  };

  /// Label of the strongest sense, e.g. "Listen".
  String get dominant {
    final entries = asMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return entries.first.key;
  }
}