/// Interpretation data returned under `atd_report` by GET /api/admin/findAtdReportByUserDataId
class AtdCategoryInfo {
  final String key;
  final String profileName;
  final String label;
  final String description;
  final String cognitiveTrait;
  final String physicalTrait;
  final String learningRecommendations;
  final String rangeTag;
  final double angle;
  final List<String> strengths;

  const AtdCategoryInfo({
    required this.key,
    required this.profileName,
    required this.label,
    required this.description,
    required this.cognitiveTrait,
    required this.physicalTrait,
    required this.learningRecommendations,
    required this.rangeTag,
    required this.angle,
    required this.strengths,
  });

  factory AtdCategoryInfo.fromJson(Map<String, dynamic> json) {
    return AtdCategoryInfo(
      key: (json['key'] ?? '').toString(),
      profileName: (json['profileName'] ?? '').toString(),
      label: (json['label'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      cognitiveTrait: (json['cognitiveTrait'] ?? '').toString(),
      physicalTrait: (json['physicalTrait'] ?? '').toString(),
      learningRecommendations:
          (json['learningRecommendations'] ?? '').toString(),
      rangeTag: (json['rangeTag'] ?? '').toString(),
      angle: (json['angle'] as num?)?.toDouble() ?? 0.0,
      strengths: (json['strengths'] as List? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'key': key,
      'profileName': profileName,
      'label': label,
      'description': description,
      'cognitiveTrait': cognitiveTrait,
      'physicalTrait': physicalTrait,
      'learningRecommendations': learningRecommendations,
      'rangeTag': rangeTag,
      'angle': angle,
      'strengths': strengths,
    };
  }
}
