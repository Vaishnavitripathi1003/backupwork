/// Response of GET findReportByUserParam?user_param=career_match
///
/// { message: Success,
///   Report: { career: { medical: {self, doctor, ...}, music: {...}, ... }, _id } }
double _d(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

/// Display only: "medical_officer" -> "Medical Officer". Spelling is untouched.
String _pretty(String key) => key
    .split('_')
    .where((w) => w.isNotEmpty)
    .map((w) => '${w[0].toUpperCase()}${w.substring(1)}')
    .join(' ');

class CareerMatchResponse {
  final String message;
  final CareerMatchReport? report;

  const CareerMatchResponse({required this.message, this.report});

  factory CareerMatchResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['Report'] ?? json['report'];
    Map<String, dynamic>? reportMap;
    if (raw is Map<String, dynamic>) {
      reportMap = raw;
    } else if (raw is List &&
        raw.isNotEmpty &&
        raw.first is Map<String, dynamic>) {
      reportMap = raw.first as Map<String, dynamic>;
    }

    return CareerMatchResponse(
      message: json['message']?.toString() ?? '',
      report: reportMap != null ? CareerMatchReport.fromJson(reportMap) : null,
    );
  }
}

class CareerMatchReport {
  final String id;
  final CareerData? career;

  const CareerMatchReport({required this.id, this.career});

  factory CareerMatchReport.fromJson(Map<String, dynamic> json) {
    final c = json['career'];
    return CareerMatchReport(
      id: json['_id']?.toString() ?? '',
      career: c is Map<String, dynamic> ? CareerData.fromJson(c) : null,
    );
  }
}

/// All categories (medical, engineering, music, ...) in the API's order.
class CareerData {
  final Map<String, CareerCategory> categories;

  const CareerData({required this.categories});

  factory CareerData.fromJson(Map<String, dynamic> json) {
    final map = <String, CareerCategory>{};
    json.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        map[key] = CareerCategory.fromJson(key, value);
      }
    });
    return CareerData(categories: map);
  }

  /// Categories sorted by `self`, highest first (a sorted copy; original untouched).
  List<CareerCategory> get sortedCategories {
    final list = categories.values.toList()
      ..sort((a, b) => b.self.compareTo(a.self));
    return list;
  }

  CareerCategory? get topCategory {
    final s = sortedCategories;
    return s.isEmpty ? null : s.first;
  }

  /// Highest-scoring careers across all categories, exactly as returned
  /// (no de-duplication, no filtering).
  List<CareerScore> topCareers([int n = 5]) {
    final all = categories.values.expand((c) => c.careers).toList()
      ..sort((a, b) => b.score.compareTo(a.score));
    return all.take(n).toList();
  }
}

class CareerCategory {
  final String key; // raw API key
  final double self; // category-level score
  final List<CareerScore> careers; // `self` excluded

  const CareerCategory({
    required this.key,
    required this.self,
    required this.careers,
  });

  String get name => _pretty(key);

  factory CareerCategory.fromJson(String key, Map<String, dynamic> json) {
    final list = <CareerScore>[];
    json.forEach((k, v) {
      if (k == 'self') return;
      list.add(CareerScore(key: k, category: key, score: _d(v)));
    });
    return CareerCategory(key: key, self: _d(json['self']), careers: list);
  }
}

class CareerScore {
  final String key; // raw API key, e.g. "pathology_reseacher"
  final String category; // raw category key
  final double score; // raw value from API

  const CareerScore({
    required this.key,
    required this.category,
    required this.score,
  });

  String get name => _pretty(key);
  String get categoryName => _pretty(category);

  /// 0..1 value shown as a percent, e.g. 0.213 -> "21%".
  String get percent => '${(score * 100).round()}%';
}