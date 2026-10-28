
class MultipleIntelligenceResponse {
  final String message;
  final MultipleIntelligenceReport? report;

  const MultipleIntelligenceResponse({required this.message, this.report});

  factory MultipleIntelligenceResponse.fromJson(Map<String, dynamic> json) {
    final raw = json['Report'] ?? json['report'];
    Map<String, dynamic>? reportMap;
    if (raw is Map<String, dynamic>) {
      reportMap = raw;
    } else if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
      reportMap = raw.first as Map<String, dynamic>;
    }

    return MultipleIntelligenceResponse(
      message: json['message']?.toString() ?? '',
      report: reportMap != null
          ? MultipleIntelligenceReport.fromJson(reportMap)
          : null,
    );
  }
}

class MultipleIntelligenceReport {
  final String id;
  final MultipleIntelligence? multipleIntelligence;

  const MultipleIntelligenceReport({required this.id, this.multipleIntelligence});

  factory MultipleIntelligenceReport.fromJson(Map<String, dynamic> json) {
    final mi = json['multiple_intelligence'];
    return MultipleIntelligenceReport(
      id: json['_id']?.toString() ?? '',
      multipleIntelligence: mi is Map<String, dynamic>
          ? MultipleIntelligence.fromJson(mi)
          : null,
    );
  }
}

/// The 8 intelligences.
class MultipleIntelligence {
  final Intrapersonal intrapersonal;
  final LogicalMathematical logicalMathematical;
  final Linguistic linguistic;
  final Naturalist naturalist;
  final Interpersonal interpersonal;
  final Visual visual;
  final Musical musical;
  final Kinesthetic kinesthetic;

  const MultipleIntelligence({
    required this.intrapersonal,
    required this.logicalMathematical,
    required this.linguistic,
    required this.naturalist,
    required this.interpersonal,
    required this.visual,
    required this.musical,
    required this.kinesthetic,
  });

  factory MultipleIntelligence.fromJson(Map<String, dynamic> json) {
    return MultipleIntelligence(
      intrapersonal: Intrapersonal.fromJson(_m(json['intrapersonal'])),
      logicalMathematical:
      LogicalMathematical.fromJson(_m(json['logical_mathematical'])),
      linguistic: Linguistic.fromJson(_m(json['linguistic'])),
      naturalist: Naturalist.fromJson(_m(json['naturalist'])),
      interpersonal: Interpersonal.fromJson(_m(json['interpersonal'])),
      visual: Visual.fromJson(_m(json['visual'])),
      musical: Musical.fromJson(_m(json['musical'])),
      kinesthetic: Kinesthetic.fromJson(_m(json['kinesthetic'])),
    );
  }

  /// Handy for charts: label -> overall "self" score (0..1).
  Map<String, double> get selfScores => {
    'Intrapersonal': intrapersonal.self,
    'Logical-Mathematical': logicalMathematical.self,
    'Linguistic': linguistic.self,
    'Naturalist': naturalist.self,
    'Interpersonal': interpersonal.self,
    'Visual': visual.self,
    'Musical': musical.self,
    'Kinesthetic': kinesthetic.self,
  };
}

class Intrapersonal {
  final double self, planning, emotion;
  const Intrapersonal(
      {required this.self, required this.planning, required this.emotion});

  factory Intrapersonal.fromJson(Map<String, dynamic> j) => Intrapersonal(
    self: _d(j['self']),
    planning: _d(j['planning']),
    emotion: _d(j['emotion']),
  );
}

class LogicalMathematical {
  final double self, reasoning, numerical, geometry;
  const LogicalMathematical({
    required this.self,
    required this.reasoning,
    required this.numerical,
    required this.geometry,
  });

  factory LogicalMathematical.fromJson(Map<String, dynamic> j) =>
      LogicalMathematical(
        self: _d(j['self']),
        reasoning: _d(j['reasoning']),
        numerical: _d(j['numerical']),
        geometry: _d(j['geometry']),
      );
}

class Linguistic {
  final double self, nonVerbal, verbal, writing;
  const Linguistic({
    required this.self,
    required this.nonVerbal,
    required this.verbal,
    required this.writing,
  });

  factory Linguistic.fromJson(Map<String, dynamic> j) => Linguistic(
    self: _d(j['self']),
    nonVerbal: _d(j['nonVerbal']),
    verbal: _d(j['verbal']),
    writing: _d(j['writing']),
  );
}

class Naturalist {
  final double self, observation, senses;
  const Naturalist(
      {required this.self, required this.observation, required this.senses});

  factory Naturalist.fromJson(Map<String, dynamic> j) => Naturalist(
    self: _d(j['self']),
    observation: _d(j['observation']),
    senses: _d(j['senses']),
  );
}

class Interpersonal {
  final double self, social, motivation;
  const Interpersonal(
      {required this.self, required this.social, required this.motivation});

  factory Interpersonal.fromJson(Map<String, dynamic> j) => Interpersonal(
    self: _d(j['self']),
    social: _d(j['social']),
    motivation: _d(j['motivation']),
  );
}

class Visual {
  final double self, ideas;

  final double sprituals;
  const Visual(
      {required this.self, required this.ideas, required this.sprituals});

  factory Visual.fromJson(Map<String, dynamic> j) => Visual(
    self: _d(j['self']),
    ideas: _d(j['ideas']),
    sprituals: _d(j['sprituals']),
  );
}

class Musical {
  final double self, voiceTone, processing, auditory;
  const Musical({
    required this.self,
    required this.voiceTone,
    required this.processing,
    required this.auditory,
  });

  factory Musical.fromJson(Map<String, dynamic> j) => Musical(
    self: _d(j['self']),
    voiceTone: _d(j['voiceTone']),
    processing: _d(j['processing']),
    auditory: _d(j['auditory']),
  );
}

class Kinesthetic {
  final double self, fineMotor, vGrossMotor;
  const Kinesthetic(
      {required this.self, required this.fineMotor, required this.vGrossMotor});

  factory Kinesthetic.fromJson(Map<String, dynamic> j) => Kinesthetic(
    self: _d(j['self']),
    fineMotor: _d(j['fineMotor']),
    vGrossMotor: _d(j['vGrossMotor']),
  );
}
double _d(dynamic v) {
  if (v is num) return v.toDouble();
  if (v is String) return double.tryParse(v) ?? 0.0;
  return 0.0;
}

Map<String, dynamic> _m(dynamic v) =>
    v is Map<String, dynamic> ? v : <String, dynamic>{};