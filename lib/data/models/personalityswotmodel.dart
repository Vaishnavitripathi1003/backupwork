// Shared model: "personality" object
class Personality {
  final String primary;
  final String secondary;

  Personality({required this.primary, required this.secondary});

  factory Personality.fromJson(Map<String, dynamic> json) => Personality(
    primary: json['primary'] ?? '',
    secondary: json['secondary'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'primary': primary,
    'secondary': secondary,
  };
}

List<String> _toStringList(dynamic v) =>
    (v as List<dynamic>? ?? []).map((e) => e.toString()).toList();

// ---------------------------------------------------------------------------
// JSON 1: strategic recommendations
// ---------------------------------------------------------------------------

class StrategicRecommendations {
  final List<String> improveWeaknesses;
  final List<String> utilizeOpportunities;
  final List<String> reduceThreats;

  StrategicRecommendations({
    required this.improveWeaknesses,
    required this.utilizeOpportunities,
    required this.reduceThreats,
  });

  factory StrategicRecommendations.fromJson(Map<String, dynamic> json) =>
      StrategicRecommendations(
        improveWeaknesses: _toStringList(json['improve_weaknesses']),
        utilizeOpportunities: _toStringList(json['utilize_opportunities']),
        reduceThreats: _toStringList(json['reduce_threats']),
      );

  Map<String, dynamic> toJson() => {
    'improve_weaknesses': improveWeaknesses,
    'utilize_opportunities': utilizeOpportunities,
    'reduce_threats': reduceThreats,
  };
}

class RecommendationsData {
  final String combination;
  final String archetype;
  final StrategicRecommendations strategicRecommendations;

  RecommendationsData({
    required this.combination,
    required this.archetype,
    required this.strategicRecommendations,
  });

  factory RecommendationsData.fromJson(Map<String, dynamic> json) =>
      RecommendationsData(
        combination: json['combination'] ?? '',
        archetype: json['archetype'] ?? '',
        strategicRecommendations: StrategicRecommendations.fromJson(
            json['strategic_recommendations'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    'combination': combination,
    'archetype': archetype,
    'strategic_recommendations': strategicRecommendations.toJson(),
  };
}

class PersonalityRecommendationsResponse {
  final String message;
  final Personality personality;
  final RecommendationsData data;
  final DateTime? date;

  PersonalityRecommendationsResponse({
    required this.message,
    required this.personality,
    required this.data,
    this.date,
  });

  factory PersonalityRecommendationsResponse.fromJson(
      Map<String, dynamic> json) =>
      PersonalityRecommendationsResponse(
        message: json['message'] ?? '',
        personality: Personality.fromJson(json['personality'] ?? {}),
        data: RecommendationsData.fromJson(json['data'] ?? {}),
        date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      );

  Map<String, dynamic> toJson() => {
    'message': message,
    'personality': personality.toJson(),
    'data': data.toJson(),
    'date': date?.toIso8601String(),
  };
}

// ---------------------------------------------------------------------------
// JSON 2: SWOT analysis
// ---------------------------------------------------------------------------

class SwotPercentages {
  final int strengths;
  final int weaknesses;
  final int opportunities;
  final int threats;

  SwotPercentages({
    required this.strengths,
    required this.weaknesses,
    required this.opportunities,
    required this.threats,
  });

  factory SwotPercentages.fromJson(Map<String, dynamic> json) =>
      SwotPercentages(
        strengths: (json['strengths'] ?? 0).toInt(),
        weaknesses: (json['weaknesses'] ?? 0).toInt(),
        opportunities: (json['opportunities'] ?? 0).toInt(),
        threats: (json['threats'] ?? 0).toInt(),
      );

  Map<String, dynamic> toJson() => {
    'strengths': strengths,
    'weaknesses': weaknesses,
    'opportunities': opportunities,
    'threats': threats,
  };
}

class SwotData {
  final String combination;
  final String blendCode;
  final String archetype;
  final String primaryStyle;
  final SwotPercentages swotPercentages;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> opportunities;
  final List<String> threats;
  final String detailedStrengths;
  final String detailedWeaknesses;
  final String strategicOpportunities;
  final String potentialThreatsDerailers;

  SwotData({
    required this.combination,
    required this.blendCode,
    required this.archetype,
    required this.primaryStyle,
    required this.swotPercentages,
    required this.strengths,
    required this.weaknesses,
    required this.opportunities,
    required this.threats,
    required this.detailedStrengths,
    required this.detailedWeaknesses,
    required this.strategicOpportunities,
    required this.potentialThreatsDerailers,
  });

  factory SwotData.fromJson(Map<String, dynamic> json) => SwotData(
    combination: json['combination'] ?? '',
    blendCode: json['blend_code'] ?? '',
    archetype: json['archetype'] ?? '',
    primaryStyle: json['primary_style'] ?? '',
    swotPercentages:
    SwotPercentages.fromJson(json['swot_percentages'] ?? {}),
    strengths: _toStringList(json['strengths']),
    weaknesses: _toStringList(json['weaknesses']),
    opportunities: _toStringList(json['opportunities']),
    threats: _toStringList(json['threats']),
    detailedStrengths: json['detailed_strengths'] ?? '',
    detailedWeaknesses: json['detailed_weaknesses'] ?? '',
    strategicOpportunities: json['strategic_opportunities'] ?? '',
    potentialThreatsDerailers: json['potential_threats_derailers'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'combination': combination,
    'blend_code': blendCode,
    'archetype': archetype,
    'primary_style': primaryStyle,
    'swot_percentages': swotPercentages.toJson(),
    'strengths': strengths,
    'weaknesses': weaknesses,
    'opportunities': opportunities,
    'threats': threats,
    'detailed_strengths': detailedStrengths,
    'detailed_weaknesses': detailedWeaknesses,
    'strategic_opportunities': strategicOpportunities,
    'potential_threats_derailers': potentialThreatsDerailers,
  };
}

class PersonalitySwotResponse {
  final String message;
  final Personality personality;
  final SwotData data;
  final DateTime? date;

  PersonalitySwotResponse({
    required this.message,
    required this.personality,
    required this.data,
    this.date,
  });

  factory PersonalitySwotResponse.fromJson(Map<String, dynamic> json) =>
      PersonalitySwotResponse(
        message: json['message'] ?? '',
        personality: Personality.fromJson(json['personality'] ?? {}),
        data: SwotData.fromJson(json['data'] ?? {}),
        date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
      );

  Map<String, dynamic> toJson() => {
    'message': message,
    'personality': personality.toJson(),
    'data': data.toJson(),
    'date': date?.toIso8601String(),
  };
}