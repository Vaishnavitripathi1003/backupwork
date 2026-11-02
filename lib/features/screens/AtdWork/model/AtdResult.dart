import 'AtdCategoryInfo.dart';

/// Response wrapper for GET /api/admin/findAtdReportByUserDataId?userDataId={id}
class AtdResultResponse {
  final String message;
  final AtdCategoryInfo? atdReport;

  const AtdResultResponse({
    required this.message,
    this.atdReport,
  });

  factory AtdResultResponse.fromJson(Map<String, dynamic> json) {
    return AtdResultResponse(
      message: (json['message'] ?? '').toString(),
      atdReport: json['atd_report'] != null && json['atd_report'] is Map<String, dynamic>
          ? AtdCategoryInfo.fromJson(json['atd_report'] as Map<String, dynamic>)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'atd_report': atdReport?.toJson(),
    };
  }
}

/// ATD Result model storing angles and category details
class AtdResult {
  final double finalAngle;
  final double leftAngle;
  final double rightAngle;
  final AtdCategoryInfo? category;

  const AtdResult({
    required this.finalAngle,
    required this.leftAngle,
    required this.rightAngle,
    this.category,
  });

  factory AtdResult.fromJson(Map<String, dynamic> json) {
    double num_(dynamic v) => (v as num?)?.toDouble() ?? 0.0;

    final cat = json['atd_report'] ?? json['category'];
    return AtdResult(
      finalAngle: num_(json['atd_avg_hand'] ?? json['angle']),
      leftAngle: num_(json['atd_left_hand']),
      rightAngle: num_(json['atd_right_hand']),
      category: cat is Map<String, dynamic> ? AtdCategoryInfo.fromJson(cat) : null,
    );
  }
}
