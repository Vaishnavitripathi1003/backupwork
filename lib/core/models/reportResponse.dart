import 'dart:convert';

// ============================================================================
// ReportResponse Wrapper
// ============================================================================
class ReportResponse {
  final String message;
  final List<ReportModel> report;

  ReportResponse({
    required this.message,
    required this.report,
  });

  factory ReportResponse.fromJson(Map<String, dynamic> json) {
    return ReportResponse(
      message: json['message'] as String? ?? '',
      report: json['Report'] != null
          ? (json['Report'] as List<dynamic>)
              .map((e) => ReportModel.fromJson(e as Map<String, dynamic>))
              .toList()
          : [],
    );
  }

  Map<String, dynamic> toJson() => {
        'message': message,
        'Report': report.map((e) => e.toJson()).toList(),
      };
}

// ============================================================================
// Report Model
// ============================================================================
class ReportModel {
  String? id;
  Personality? personality;
  AcquiringMethods? acquiringMethods;
  BrainDominance? brainDominance;
  MultipleIntelligence? multipleIntelligence;
  Senses? senses;
  ThoughtProcess? thoughtProcess;
  ObjectConcept? objectConcept;
  ExecutorThinker? executorThinker;
  Quotients? quotients;
  LearningStyle? learningStyle;
  LeadershipStyle? leadershipStyle;
  HollandTheory? hollandTheory;
  MckenzieTheory? mckenzieTheory;
  ExtraCurricularActivities? extraCurricularActivities;
  StreamSelection? streamSelection;
  int? tfrc;
  String? url;
  String? updatedAt;

  ReportModel({
    this.id,
    this.personality,
    this.acquiringMethods,
    this.brainDominance,
    this.multipleIntelligence,
    this.senses,
    this.thoughtProcess,
    this.objectConcept,
    this.executorThinker,
    this.quotients,
    this.learningStyle,
    this.leadershipStyle,
    this.hollandTheory,
    this.mckenzieTheory,
    this.extraCurricularActivities,
    this.streamSelection,
    this.tfrc,
    this.url,
    this.updatedAt,
  });

  factory ReportModel.fromJson(Map<String, dynamic> json) {
    return ReportModel(
      id: json['_id'] as String?,
      personality: json['personality'] != null
          ? Personality.fromJson(json['personality'])
          : null,
      acquiringMethods: json['acquiring_methods'] != null
          ? AcquiringMethods.fromJson(json['acquiring_methods'])
          : null,
      brainDominance: json['brain_dominance'] != null
          ? BrainDominance.fromJson(json['brain_dominance'])
          : null,
      multipleIntelligence: json['multiple_intelligence'] != null
          ? MultipleIntelligence.fromJson(json['multiple_intelligence'])
          : null,
      senses: json['senses'] != null ? Senses.fromJson(json['senses']) : null,
      thoughtProcess: json['thought_process'] != null
          ? ThoughtProcess.fromJson(json['thought_process'])
          : null,
      objectConcept: json['object_concept'] != null
          ? ObjectConcept.fromJson(json['object_concept'])
          : null,
      executorThinker: json['executor_thinker'] != null
          ? ExecutorThinker.fromJson(json['executor_thinker'])
          : null,
      quotients: json['quotients'] != null
          ? Quotients.fromJson(json['quotients'])
          : null,
      learningStyle: json['learning_style'] != null
          ? LearningStyle.fromJson(json['learning_style'])
          : null,
      leadershipStyle: json['leadership_style'] != null
          ? LeadershipStyle.fromJson(json['leadership_style'])
          : null,
      hollandTheory: json['holland_theory'] != null
          ? HollandTheory.fromJson(json['holland_theory'])
          : null,
      mckenzieTheory: json['mckenzie_theory'] != null
          ? MckenzieTheory.fromJson(json['mckenzie_theory'])
          : null,
      extraCurricularActivities: json['extra_curricular_activities'] != null
          ? ExtraCurricularActivities.fromJson(
              json['extra_curricular_activities'])
          : null,
      streamSelection: json['stream_selection'] != null
          ? StreamSelection.fromJson(json['stream_selection'])
          : null,
      tfrc: json['tfrc'] as int?,
      url: json['url'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        '_id': id,
        'personality': personality?.toJson(),
        'acquiring_methods': acquiringMethods?.toJson(),
        'brain_dominance': brainDominance?.toJson(),
        'multiple_intelligence': multipleIntelligence?.toJson(),
        'senses': senses?.toJson(),
        'thought_process': thoughtProcess?.toJson(),
        'object_concept': objectConcept?.toJson(),
        'executor_thinker': executorThinker?.toJson(),
        'quotients': quotients?.toJson(),
        'learning_style': learningStyle?.toJson(),
        'leadership_style': leadershipStyle?.toJson(),
        'holland_theory': hollandTheory?.toJson(),
        'mckenzie_theory': mckenzieTheory?.toJson(),
        'extra_curricular_activities': extraCurricularActivities?.toJson(),
        'stream_selection': streamSelection?.toJson(),
        'tfrc': tfrc,
        'url': url,
        'updated_at': updatedAt,
      };
}

// Helper to safely parse double numbers from JSON
double _toDouble(dynamic val) => (val as num?)?.toDouble() ?? 0.0;

// ============================================================================
// Sub Models
// ============================================================================

class AcquiringMethods {
  final double selfCognitive;
  final double affective;
  final double reverse;
  final double reflective;

  AcquiringMethods({
    required this.selfCognitive,
    required this.affective,
    required this.reverse,
    required this.reflective,
  });

  factory AcquiringMethods.fromJson(Map<String, dynamic> json) =>
      AcquiringMethods(
        selfCognitive: _toDouble(json['self_cognitive']),
        affective: _toDouble(json['affective']),
        reverse: _toDouble(json['reverse']),
        reflective: _toDouble(json['reflective']),
      );

  Map<String, dynamic> toJson() => {
        'self_cognitive': selfCognitive,
        'affective': affective,
        'reverse': reverse,
        'reflective': reflective,
      };
}

class Personality {
  final String primary;
  final String secondary;

  Personality({required this.primary, required this.secondary});

  factory Personality.fromJson(Map<String, dynamic> json) => Personality(
        primary: json['primary'] as String? ?? '',
        secondary: json['secondary'] as String? ?? '',
      );

  Map<String, dynamic> toJson() => {
        'primary': primary,
        'secondary': secondary,
      };
}

class MultipleIntelligence {
  final Intrapersonal intrapersonal;
  final LogicalMathematical logicalMathematical;
  final Linguistic linguistic;
  final Naturalist naturalist;
  final Interpersonal interpersonal;
  final Visual visual;
  final Musical musical;
  final Kinesthetic kinesthetic;

  MultipleIntelligence({
    required this.intrapersonal,
    required this.logicalMathematical,
    required this.linguistic,
    required this.naturalist,
    required this.interpersonal,
    required this.visual,
    required this.musical,
    required this.kinesthetic,
  });

  factory MultipleIntelligence.fromJson(Map<String, dynamic> json) =>
      MultipleIntelligence(
        intrapersonal: Intrapersonal.fromJson(json['intrapersonal'] ?? {}),
        logicalMathematical:
            LogicalMathematical.fromJson(json['logical_mathematical'] ?? {}),
        linguistic: Linguistic.fromJson(json['linguistic'] ?? {}),
        naturalist: Naturalist.fromJson(json['naturalist'] ?? {}),
        interpersonal: Interpersonal.fromJson(json['interpersonal'] ?? {}),
        visual: Visual.fromJson(json['visual'] ?? {}),
        musical: Musical.fromJson(json['musical'] ?? {}),
        kinesthetic: Kinesthetic.fromJson(json['kinesthetic'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
        'intrapersonal': intrapersonal.toJson(),
        'logical_mathematical': logicalMathematical.toJson(),
        'linguistic': linguistic.toJson(),
        'naturalist': naturalist.toJson(),
        'interpersonal': interpersonal.toJson(),
        'visual': visual.toJson(),
        'musical': musical.toJson(),
        'kinesthetic': kinesthetic.toJson(),
      };
}

class Intrapersonal {
  final double self, planning, emotion;
  Intrapersonal(
      {required this.self, required this.planning, required this.emotion});
  factory Intrapersonal.fromJson(Map<String, dynamic> json) => Intrapersonal(
        self: _toDouble(json['self']),
        planning: _toDouble(json['planning']),
        emotion: _toDouble(json['emotion']),
      );
  Map<String, dynamic> toJson() =>
      {'self': self, 'planning': planning, 'emotion': emotion};
}

class LogicalMathematical {
  final double self, reasoning, numerical, geometry;
  LogicalMathematical(
      {required this.self,
      required this.reasoning,
      required this.numerical,
      required this.geometry});
  factory LogicalMathematical.fromJson(Map<String, dynamic> json) =>
      LogicalMathematical(
        self: _toDouble(json['self']),
        reasoning: _toDouble(json['reasoning']),
        numerical: _toDouble(json['numerical']),
        geometry: _toDouble(json['geometry']),
      );
  Map<String, dynamic> toJson() => {
        'self': self,
        'reasoning': reasoning,
        'numerical': numerical,
        'geometry': geometry
      };
}

class Linguistic {
  final double self, nonVerbal, verbal, writing;
  Linguistic(
      {required this.self,
      required this.nonVerbal,
      required this.verbal,
      required this.writing});
  factory Linguistic.fromJson(Map<String, dynamic> json) => Linguistic(
        self: _toDouble(json['self']),
        nonVerbal: _toDouble(json['nonVerbal']),
        verbal: _toDouble(json['verbal']),
        writing: _toDouble(json['writing']),
      );
  Map<String, dynamic> toJson() => {
        'self': self,
        'nonVerbal': nonVerbal,
        'verbal': verbal,
        'writing': writing
      };
}

class Naturalist {
  final double self, observation, senses;
  Naturalist(
      {required this.self, required this.observation, required this.senses});
  factory Naturalist.fromJson(Map<String, dynamic> json) => Naturalist(
        self: _toDouble(json['self']),
        observation: _toDouble(json['observation']),
        senses: _toDouble(json['senses']),
      );
  Map<String, dynamic> toJson() =>
      {'self': self, 'observation': observation, 'senses': senses};
}

class Interpersonal {
  final double self, social, motivation;
  Interpersonal(
      {required this.self, required this.social, required this.motivation});
  factory Interpersonal.fromJson(Map<String, dynamic> json) => Interpersonal(
        self: _toDouble(json['self']),
        social: _toDouble(json['social']),
        motivation: _toDouble(json['motivation']),
      );
  Map<String, dynamic> toJson() =>
      {'self': self, 'social': social, 'motivation': motivation};
}

class Visual {
  final double self, ideas, sprituals;
  Visual({required this.self, required this.ideas, required this.sprituals});
  factory Visual.fromJson(Map<String, dynamic> json) => Visual(
        self: _toDouble(json['self']),
        ideas: _toDouble(json['ideas']),
        sprituals: _toDouble(json['sprituals']),
      );
  Map<String, dynamic> toJson() =>
      {'self': self, 'ideas': ideas, 'sprituals': sprituals};
}

class Musical {
  final double self, voiceTone, processing, auditory;
  Musical(
      {required this.self,
      required this.voiceTone,
      required this.processing,
      required this.auditory});
  factory Musical.fromJson(Map<String, dynamic> json) => Musical(
        self: _toDouble(json['self']),
        voiceTone: _toDouble(json['voiceTone']),
        processing: _toDouble(json['processing']),
        auditory: _toDouble(json['auditory']),
      );
  Map<String, dynamic> toJson() => {
        'self': self,
        'voiceTone': voiceTone,
        'processing': processing,
        'auditory': auditory
      };
}

class Kinesthetic {
  final double self, fineMotor, vGrossMotor;
  Kinesthetic(
      {required this.self,
      required this.fineMotor,
      required this.vGrossMotor});
  factory Kinesthetic.fromJson(Map<String, dynamic> json) => Kinesthetic(
        self: _toDouble(json['self']),
        fineMotor: _toDouble(json['fineMotor']),
        vGrossMotor: _toDouble(json['vGrossMotor']),
      );
  Map<String, dynamic> toJson() =>
      {'self': self, 'fineMotor': fineMotor, 'vGrossMotor': vGrossMotor};
}

class Senses {
  final double taste, smell, touch, listen, see;
  Senses(
      {required this.taste,
      required this.smell,
      required this.touch,
      required this.listen,
      required this.see});
  factory Senses.fromJson(Map<String, dynamic> json) => Senses(
        taste: _toDouble(json['taste']),
        smell: _toDouble(json['smell']),
        touch: _toDouble(json['touch']),
        listen: _toDouble(json['listen']),
        see: _toDouble(json['see']),
      );
  Map<String, dynamic> toJson() => {
        'taste': taste,
        'smell': smell,
        'touch': touch,
        'listen': listen,
        'see': see
      };
}

class ThoughtProcess {
  final double action, thinking, tactile, auditory, visual;
  ThoughtProcess(
      {required this.action,
      required this.thinking,
      required this.tactile,
      required this.auditory,
      required this.visual});
  factory ThoughtProcess.fromJson(Map<String, dynamic> json) => ThoughtProcess(
        action: _toDouble(json['action']),
        thinking: _toDouble(json['thinking']),
        tactile: _toDouble(json['tactile']),
        auditory: _toDouble(json['auditory']),
        visual: _toDouble(json['visual']),
      );
  Map<String, dynamic> toJson() => {
        'action': action,
        'thinking': thinking,
        'tactile': tactile,
        'auditory': auditory,
        'visual': visual
      };
}

class ObjectConcept {
  final double objectDriven, conceptDriven;
  ObjectConcept({required this.objectDriven, required this.conceptDriven});
  factory ObjectConcept.fromJson(Map<String, dynamic> json) => ObjectConcept(
        objectDriven: _toDouble(json['object_driven']),
        conceptDriven: _toDouble(json['concept_driven']),
      );
  Map<String, dynamic> toJson() =>
      {'object_driven': objectDriven, 'concept_driven': conceptDriven};
}

class ExecutorThinker {
  final double executor, thinker;
  ExecutorThinker({required this.executor, required this.thinker});
  factory ExecutorThinker.fromJson(Map<String, dynamic> json) => ExecutorThinker(
        executor: _toDouble(json['executor']),
        thinker: _toDouble(json['thinker']),
      );
  Map<String, dynamic> toJson() =>
      {'executor': executor, 'thinker': thinker};
}

class Quotients {
  final double iq, eq, cq, aq;
  Quotients(
      {required this.iq, required this.eq, required this.cq, required this.aq});
  factory Quotients.fromJson(Map<String, dynamic> json) => Quotients(
        iq: _toDouble(json['iq']),
        eq: _toDouble(json['eq']),
        cq: _toDouble(json['cq']),
        aq: _toDouble(json['aq']),
      );
  Map<String, dynamic> toJson() =>
      {'iq': iq, 'eq': eq, 'cq': cq, 'aq': aq};
}

class LearningStyle {
  final double kinesthetic, auditory, visual;
  LearningStyle(
      {required this.kinesthetic,
      required this.auditory,
      required this.visual});
  factory LearningStyle.fromJson(Map<String, dynamic> json) => LearningStyle(
        kinesthetic: _toDouble(json['kinesthetic']),
        auditory: _toDouble(json['auditory']),
        visual: _toDouble(json['visual']),
      );
  Map<String, dynamic> toJson() => {
        'kinesthetic': kinesthetic,
        'auditory': auditory,
        'visual': visual
      };
}

class LeadershipStyle {
  final double taskOriented, relationshipOriented;
  LeadershipStyle(
      {required this.taskOriented, required this.relationshipOriented});
  factory LeadershipStyle.fromJson(Map<String, dynamic> json) =>
      LeadershipStyle(
        taskOriented: _toDouble(json['task_oriented']),
        relationshipOriented: _toDouble(json['relationship_oriented']),
      );
  Map<String, dynamic> toJson() => {
        'task_oriented': taskOriented,
        'relationship_oriented': relationshipOriented
      };
}

class HollandTheory {
  final double realistic,
      investigative,
      conventional,
      artistic,
      enterprising,
      social;
  HollandTheory({
    required this.realistic,
    required this.investigative,
    required this.conventional,
    required this.artistic,
    required this.enterprising,
    required this.social,
  });
  factory HollandTheory.fromJson(Map<String, dynamic> json) => HollandTheory(
        realistic: _toDouble(json['realistic']),
        investigative: _toDouble(json['investigative']),
        conventional: _toDouble(json['conventional']),
        artistic: _toDouble(json['artistic']),
        enterprising: _toDouble(json['enterprising']),
        social: _toDouble(json['social']),
      );
  Map<String, dynamic> toJson() => {
        'realistic': realistic,
        'investigative': investigative,
        'conventional': conventional,
        'artistic': artistic,
        'enterprising': enterprising,
        'social': social,
      };
}

class MckenzieTheory {
  final double analytic, introspective, interactive;
  MckenzieTheory(
      {required this.analytic,
      required this.introspective,
      required this.interactive});
  factory MckenzieTheory.fromJson(Map<String, dynamic> json) => MckenzieTheory(
        analytic: _toDouble(json['analytic']),
        introspective: _toDouble(json['introspective']),
        interactive: _toDouble(json['interactive']),
      );
  Map<String, dynamic> toJson() => {
        'analytic': analytic,
        'introspective': introspective,
        'interactive': interactive
      };
}

class ExtraCurricularActivities {
  final double dance,
      instrumentalMusic,
      singing,
      acting,
      swimming,
      horseRiding,
      chess,
      snooker,
      foreignLanguage,
      painting;
  ExtraCurricularActivities({
    required this.dance,
    required this.instrumentalMusic,
    required this.singing,
    required this.acting,
    required this.swimming,
    required this.horseRiding,
    required this.chess,
    required this.snooker,
    required this.foreignLanguage,
    required this.painting,
  });
  factory ExtraCurricularActivities.fromJson(Map<String, dynamic> json) =>
      ExtraCurricularActivities(
        dance: _toDouble(json['dance']),
        instrumentalMusic: _toDouble(json['instrumental_music']),
        singing: _toDouble(json['singing']),
        acting: _toDouble(json['acting']),
        swimming: _toDouble(json['swimming']),
        horseRiding: _toDouble(json['horse_riding']),
        chess: _toDouble(json['chess']),
        snooker: _toDouble(json['snooker']),
        foreignLanguage: _toDouble(json['foreign_language']),
        painting: _toDouble(json['painting']),
      );
  Map<String, dynamic> toJson() => {
        'dance': dance,
        'instrumental_music': instrumentalMusic,
        'singing': singing,
        'acting': acting,
        'swimming': swimming,
        'horse_riding': horseRiding,
        'chess': chess,
        'snooker': snooker,
        'foreign_language': foreignLanguage,
        'painting': painting,
      };
}

class StreamSelection {
  final double science, commerce, arts;
  StreamSelection(
      {required this.science, required this.commerce, required this.arts});
  factory StreamSelection.fromJson(Map<String, dynamic> json) =>
      StreamSelection(
        science: _toDouble(json['science']),
        commerce: _toDouble(json['commerce']),
        arts: _toDouble(json['arts']),
      );
  Map<String, dynamic> toJson() =>
      {'science': science, 'commerce': commerce, 'arts': arts};
}

class BrainDominance {
  final double leftBrain, rightBrain;
  BrainDominance({required this.leftBrain, required this.rightBrain});
  factory BrainDominance.fromJson(Map<String, dynamic> json) => BrainDominance(
        leftBrain: _toDouble(json['left_brain']),
        rightBrain: _toDouble(json['right_brain']),
      );
  Map<String, dynamic> toJson() =>
      {'left_brain': leftBrain, 'right_brain': rightBrain};
}

class Medical {
  final double self,
      doctor,
      nutritionist,
      medicalOfficer,
      chemist,
      pharmacist,
      drugOfficer,
      surgeon,
      foodInspector;
  Medical({
    required this.self,
    required this.doctor,
    required this.nutritionist,
    required this.medicalOfficer,
    required this.chemist,
    required this.pharmacist,
    required this.drugOfficer,
    required this.surgeon,
    required this.foodInspector,
  });

  factory Medical.fromJson(Map<String, dynamic> json) => Medical(
        self: _toDouble(json['self']),
        doctor: _toDouble(json['doctor']),
        nutritionist: _toDouble(json['nutritionist']),
        medicalOfficer: _toDouble(json['medical_officer']),
        chemist: _toDouble(json['chemist']),
        pharmacist: _toDouble(json['pharmacist']),
        drugOfficer: _toDouble(json['drug_officer']),
        surgeon: _toDouble(json['surgeon']),
        foodInspector: _toDouble(json['food_inspector']),
      );

  Map<String, dynamic> toJson() => {
        'self': self,
        'doctor': doctor,
        'nutritionist': nutritionist,
        'medical_officer': medicalOfficer,
        'chemist': chemist,
        'pharmacist': pharmacist,
        'drug_officer': drugOfficer,
        'surgeon': surgeon,
        'food_inspector': foodInspector,
      };

  List<MapEntry<String, double>> toList() => [
        MapEntry("Doctor", doctor),
        MapEntry("Nutritionist", nutritionist),
        MapEntry("Medical Officer", medicalOfficer),
        MapEntry("Chemist", chemist),
        MapEntry("Pharmacist", pharmacist),
        MapEntry("Drug Officer", drugOfficer),
        MapEntry("Surgeon", surgeon),
        MapEntry("Food Inspector", foodInspector),
      ];
}

class Engineering {
  final double self,
      chemicalEngineering,
      electronicalEngineering,
      electricalEngineering,
      aviationEngineering,
      mechanicalEngineering,
      computerEngineering,
      productionEngineering,
      soundEngineering;
  Engineering({
    required this.self,
    required this.chemicalEngineering,
    required this.electronicalEngineering,
    required this.electricalEngineering,
    required this.aviationEngineering,
    required this.mechanicalEngineering,
    required this.computerEngineering,
    required this.productionEngineering,
    required this.soundEngineering,
  });

  factory Engineering.fromJson(Map<String, dynamic> json) => Engineering(
        self: _toDouble(json['self']),
        chemicalEngineering: _toDouble(json['chemical_engineering']),
        electronicalEngineering: _toDouble(json['electronical_engineering']),
        electricalEngineering: _toDouble(json['electrical_engineering']),
        aviationEngineering: _toDouble(json['aviation_engineering']),
        mechanicalEngineering: _toDouble(json['mechanical_engineering']),
        computerEngineering: _toDouble(json['computer_engineering']),
        productionEngineering: _toDouble(json['production_engineering']),
        soundEngineering: _toDouble(json['sound_engineering']),
      );

  Map<String, dynamic> toJson() => {
        'self': self,
        'chemical_engineering': chemicalEngineering,
        'electronical_engineering': electronicalEngineering,
        'electrical_engineering': electricalEngineering,
        'aviation_engineering': aviationEngineering,
        'mechanical_engineering': mechanicalEngineering,
        'computer_engineering': computerEngineering,
        'production_engineering': productionEngineering,
        'sound_engineering': soundEngineering,
      };
}
