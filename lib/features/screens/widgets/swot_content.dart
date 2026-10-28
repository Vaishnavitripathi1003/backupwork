enum DiscType { dominant, influential, steady, compliant }

class SwotContent {
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> opportunities;
  final List<String> threats;

  const SwotContent({
    required this.strengths,
    required this.weaknesses,
    required this.opportunities,
    required this.threats,
  });
}

const Map<DiscType, SwotContent> _swotByType = {
  DiscType.dominant: SwotContent(
    strengths: ['Goal oriented', 'Target centric', 'Decisive', 'Independent', 'Bold'],
    weaknesses: ['Aggressive', 'Egoistic', 'Rigid', 'My way or highway', 'Loose big picture'],
    opportunities: ['Visionary', "Can see what others aren't able to", 'Can lead', 'Can motivate others'],
    threats: ['Insensitive to others feelings', 'Ignore relationship', 'High risk taker', 'Isolation approach'],
  ),
  DiscType.influential: SwotContent(
    strengths: ['Enthusiasm', 'Energy', 'Attention seeker', 'Cheerfulness', 'Unlimited potential'],
    weaknesses: ['Need push', 'Time management', 'Organizing, planning', 'Talkative', 'Fear of loosing'],
    opportunities: ['Lively', 'Can encase the relationship', 'People like them', 'Centre of attention'],
    threats: ['Lack of management', 'Think from heart', 'Unable to foresee', 'They live in today'],
  ),
  DiscType.steady: SwotContent(
    strengths: ["People's people", 'Relationship oriented leadership style', 'Excellent team player', 'Flexible'],
    weaknesses: ['Emotional', 'Considering too much others', 'Lack of goal & aim', 'Avoid change'],
    opportunities: ['Can build team', 'Can bring & bind people together', 'Supportive', 'Can handle situation'],
    threats: ['Lack of management', 'Think from heart', 'Unable to foresee', 'They live in today'],
  ),
  DiscType.compliant: SwotContent(
    strengths: ['Analytical style', 'Observation skills', 'Perfectionist', 'Focus on accuracy', 'Logical thoughts'],
    weaknesses: ['Take longer time to take a decision', 'Dual thought', 'Consider even the minute fault'],
    opportunities: ['Perfectionist', 'Rational approach', 'Rule setter', 'Compliance officer', 'Can control the work'],
    threats: ['Fussy people', "Don't understand the situation", 'Doing job right, rather than doing right job'],
  ),
};

/// Keywords matched (case-insensitive) against the primary/secondary text.
const Map<DiscType, String> _keywords = {
  DiscType.dominant: 'domin',
  DiscType.influential: 'influen',
  DiscType.steady: 'stead',
  DiscType.compliant: 'complian',
};

/// Types mentioned in a text like "Dominant", "Dominant + Steady", "Influential-Steady".
List<DiscType> detectDiscTypes(String? text) {
  if (text == null || text.trim().isEmpty) return const [];
  final t = text.toLowerCase();
  return DiscType.values.where((d) => t.contains(_keywords[d]!)).toList();
}

/// Combined SWOT for primary + secondary (duplicates removed).
class SwotResult {
  final List<DiscType> types;
  final List<String> strengths;
  final List<String> weaknesses;
  final List<String> opportunities;
  final List<String> threats;

  const SwotResult({
    required this.types,
    required this.strengths,
    required this.weaknesses,
    required this.opportunities,
    required this.threats,
  });

  bool get isEmpty => types.isEmpty;

  factory SwotResult.from(String? primary, String? secondary) {
    final types = {
      ...detectDiscTypes(primary),
      ...detectDiscTypes(secondary),
    }.toList();

    List<String> merge(List<String> Function(SwotContent c) pick) =>
        {for (final t in types) ...pick(_swotByType[t]!)}.toList();

    return SwotResult(
      types: types,
      strengths: merge((c) => c.strengths),
      weaknesses: merge((c) => c.weaknesses),
      opportunities: merge((c) => c.opportunities),
      threats: merge((c) => c.threats),
    );
  }
}