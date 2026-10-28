class PersonalityBlendResponse {
  final String message;
  final PersonalityBlendReport? report;
  final SwotAnalysis? swotAnalysis;
  final DateTime? date;

  const PersonalityBlendResponse({
    required this.message,
    this.report,
    this.swotAnalysis,
    this.date,
  });

  factory PersonalityBlendResponse.fromJson(Map<String, dynamic> json) {
    // Backend key is "Report" (capital R). Also accepts "report", and
    // takes the first item if the server ever sends a list.
    final raw = json['Report'] ?? json['report'];
    Map<String, dynamic>? reportMap;
    if (raw is Map<String, dynamic>) {
      reportMap = raw;
    } else if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
      reportMap = raw.first as Map<String, dynamic>;
    }

    final swot = json['swotAnalysis'];

    return PersonalityBlendResponse(
      message: json['message']?.toString() ?? '',
      report: reportMap != null ? PersonalityBlendReport.fromJson(reportMap) : null,
      swotAnalysis: swot is Map<String, dynamic> ? SwotAnalysis.fromJson(swot) : null,
      date: DateTime.tryParse(json['date']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'Report': report?.toJson(),
    'swotAnalysis': swotAnalysis?.toJson(),
    'date': date?.toIso8601String(),
  };
}

class PersonalityBlendReport {
  final String id;
  final PersonalityBlendData? personality;
  final DateTime? createdAt;

  const PersonalityBlendReport({
    required this.id,
    this.personality,
    this.createdAt,
  });

  factory PersonalityBlendReport.fromJson(Map<String, dynamic> json) {
    final p = json['personality'];
    return PersonalityBlendReport(
      id: json['_id']?.toString() ?? '',
      personality: p is Map<String, dynamic> ? PersonalityBlendData.fromJson(p) : null,
      createdAt: DateTime.tryParse(json['created_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() => {
    '_id': id,
    'personality': personality?.toJson(),
    'created_at': createdAt?.toIso8601String(),
  };
}

class PersonalityBlendData {
  final String primary;
  final String secondary;

  const PersonalityBlendData({required this.primary, required this.secondary});

  factory PersonalityBlendData.fromJson(Map<String, dynamic> json) {
    return PersonalityBlendData(
      primary: json['primary']?.toString() ?? '',
      secondary: json['secondary']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'primary': primary,
    'secondary': secondary,
  };
}

class SwotAnalysis {
  final String combination;
  final String primaryDimension;
  final double strengthsPct;
  final double weaknessesPct;
  final double opportunitiesPct;
  final double threatsPct;

  const SwotAnalysis({
    required this.combination,
    required this.primaryDimension,
    required this.strengthsPct,
    required this.weaknessesPct,
    required this.opportunitiesPct,
    required this.threatsPct,
  });

  factory SwotAnalysis.fromJson(Map<String, dynamic> json) {
    double toD(dynamic v) => (v is num) ? v.toDouble() : double.tryParse('$v') ?? 0;

    return SwotAnalysis(
      combination: json['combination']?.toString() ?? '',
      primaryDimension: json['primary_dimension']?.toString() ?? '',
      strengthsPct: toD(json['strengths_pct']),
      weaknessesPct: toD(json['weaknesses_pct']),
      opportunitiesPct: toD(json['opportunities_pct']),
      threatsPct: toD(json['threats_pct']),
    );
  }

  Map<String, dynamic> toJson() => {
    'combination': combination,
    'primary_dimension': primaryDimension,
    'strengths_pct': strengthsPct,
    'weaknesses_pct': weaknessesPct,
    'opportunities_pct': opportunitiesPct,
    'threats_pct': threatsPct,
  };
}