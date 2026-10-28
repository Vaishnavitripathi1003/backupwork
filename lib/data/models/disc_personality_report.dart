// daksh_personality_full_report.dart
// Plain Dart models (no code generation needed).
// Usage:
//   final model = DakshPersonalityFullReport.fromJson(jsonDecode(responseBody));

class DakshPersonalityFullReport {
  final String message;
  final Personality personality;
  final PersonalityData data;
  final DateTime? date;

  DakshPersonalityFullReport({
    required this.message,
    required this.personality,
    required this.data,
    this.date,
  });

  factory DakshPersonalityFullReport.fromJson(Map<String, dynamic> json) {
    return DakshPersonalityFullReport(
      message: json['message'] ?? '',
      personality: Personality.fromJson(json['personality'] ?? {}),
      data: PersonalityData.fromJson(json['data'] ?? {}),
      date: json['date'] != null ? DateTime.tryParse(json['date']) : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'message': message,
    'personality': personality.toJson(),
    'data': data.toJson(),
    'date': date?.toIso8601String(),
  };
}

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

class PersonalityData {
  final String combination;
  final String archetype;
  final String cluster;
  final List<BehavioralIntensityMeter> behavioralIntensityMeters;
  final DiscQuadrantPlacement discQuadrantPlacement;
  final LifeStages lifeStages;
  final GuidanceForParentsMentors guidanceForParentsMentors;
  final KeyMotivatorsPreferences keyMotivatorsPreferences;

  PersonalityData({
    required this.combination,
    required this.archetype,
    required this.cluster,
    required this.behavioralIntensityMeters,
    required this.discQuadrantPlacement,
    required this.lifeStages,
    required this.guidanceForParentsMentors,
    required this.keyMotivatorsPreferences,
  });

  factory PersonalityData.fromJson(Map<String, dynamic> json) {
    return PersonalityData(
      combination: json['combination'] ?? '',
      archetype: json['archetype'] ?? '',
      cluster: json['cluster'] ?? '',
      behavioralIntensityMeters:
      (json['behavioral_intensity_meters'] as List<dynamic>? ?? [])
          .map((e) => BehavioralIntensityMeter.fromJson(e))
          .toList(),
      discQuadrantPlacement:
      DiscQuadrantPlacement.fromJson(json['disc_quadrant_placement'] ?? {}),
      lifeStages: LifeStages.fromJson(json['life_stages'] ?? {}),
      guidanceForParentsMentors: GuidanceForParentsMentors.fromJson(
          json['guidance_for_parents_mentors'] ?? {}),
      keyMotivatorsPreferences: KeyMotivatorsPreferences.fromJson(
          json['key_motivators_preferences'] ?? {}),
    );
  }

  Map<String, dynamic> toJson() => {
    'combination': combination,
    'archetype': archetype,
    'cluster': cluster,
    'behavioral_intensity_meters':
    behavioralIntensityMeters.map((e) => e.toJson()).toList(),
    'disc_quadrant_placement': discQuadrantPlacement.toJson(),
    'life_stages': lifeStages.toJson(),
    'guidance_for_parents_mentors': guidanceForParentsMentors.toJson(),
    'key_motivators_preferences': keyMotivatorsPreferences.toJson(),
  };
}

class BehavioralIntensityMeter {
  final String metric;
  final int percentage;
  final String label;

  BehavioralIntensityMeter({
    required this.metric,
    required this.percentage,
    required this.label,
  });

  factory BehavioralIntensityMeter.fromJson(Map<String, dynamic> json) =>
      BehavioralIntensityMeter(
        metric: json['metric'] ?? '',
        percentage: (json['percentage'] as num?)?.toInt() ?? 0,
        label: json['label'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'metric': metric,
    'percentage': percentage,
    'label': label,
  };
}

class DiscQuadrantPlacement {
  final DiscDimension primary;
  final DiscDimension secondary;

  DiscQuadrantPlacement({required this.primary, required this.secondary});

  factory DiscQuadrantPlacement.fromJson(Map<String, dynamic> json) =>
      DiscQuadrantPlacement(
        primary: DiscDimension.fromJson(json['primary'] ?? {}),
        secondary: DiscDimension.fromJson(json['secondary'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    'primary': primary.toJson(),
    'secondary': secondary.toJson(),
  };
}

class DiscDimension {
  final int percentage;
  final String dimension;
  final String description;

  DiscDimension({
    required this.percentage,
    required this.dimension,
    required this.description,
  });

  factory DiscDimension.fromJson(Map<String, dynamic> json) => DiscDimension(
    percentage: (json['percentage'] as num?)?.toInt() ?? 0,
    dimension: json['dimension'] ?? '',
    description: json['description'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'percentage': percentage,
    'dimension': dimension,
    'description': description,
  };
}

class LifeStages {
  final StudentProfile studentProfile;
  final WorkingProfessionalProfile workingProfessionalProfile;
  final PersonalEverydayLife personalEverydayLife;

  LifeStages({
    required this.studentProfile,
    required this.workingProfessionalProfile,
    required this.personalEverydayLife,
  });

  factory LifeStages.fromJson(Map<String, dynamic> json) => LifeStages(
    studentProfile: StudentProfile.fromJson(json['student_profile'] ?? {}),
    workingProfessionalProfile: WorkingProfessionalProfile.fromJson(
        json['working_professional_profile'] ?? {}),
    personalEverydayLife:
    PersonalEverydayLife.fromJson(json['personal_everyday_life'] ?? {}),
  );

  Map<String, dynamic> toJson() => {
    'student_profile': studentProfile.toJson(),
    'working_professional_profile': workingProfessionalProfile.toJson(),
    'personal_everyday_life': personalEverydayLife.toJson(),
  };
}

class StudentProfile {
  final String groupProjects;
  final String academicPressure;
  final String communication;
  final String optimalLearningEnvironment;

  StudentProfile({
    required this.groupProjects,
    required this.academicPressure,
    required this.communication,
    required this.optimalLearningEnvironment,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) => StudentProfile(
    groupProjects: json['group_projects'] ?? '',
    academicPressure: json['academic_pressure'] ?? '',
    communication: json['communication'] ?? '',
    optimalLearningEnvironment: json['optimal_learning_environment'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'group_projects': groupProjects,
    'academic_pressure': academicPressure,
    'communication': communication,
    'optimal_learning_environment': optimalLearningEnvironment,
  };
}

class WorkingProfessionalProfile {
  final String workplaceExecution;
  final String leadershipManagement;
  final String stressResponse;
  final List<String> idealRoles;

  WorkingProfessionalProfile({
    required this.workplaceExecution,
    required this.leadershipManagement,
    required this.stressResponse,
    required this.idealRoles,
  });

  factory WorkingProfessionalProfile.fromJson(Map<String, dynamic> json) =>
      WorkingProfessionalProfile(
        workplaceExecution: json['workplace_execution'] ?? '',
        leadershipManagement: json['leadership_management'] ?? '',
        stressResponse: json['stress_response'] ?? '',
        idealRoles: List<String>.from(json['ideal_roles'] ?? []),
      );

  Map<String, dynamic> toJson() => {
    'workplace_execution': workplaceExecution,
    'leadership_management': leadershipManagement,
    'stress_response': stressResponse,
    'ideal_roles': idealRoles,
  };
}

class PersonalEverydayLife {
  final String householdDynamics;
  final String everydayRelationships;
  final String conflictResolution;

  PersonalEverydayLife({
    required this.householdDynamics,
    required this.everydayRelationships,
    required this.conflictResolution,
  });

  factory PersonalEverydayLife.fromJson(Map<String, dynamic> json) =>
      PersonalEverydayLife(
        householdDynamics: json['household_dynamics'] ?? '',
        everydayRelationships: json['everyday_relationships'] ?? '',
        conflictResolution: json['conflict_resolution'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'household_dynamics': householdDynamics,
    'everyday_relationships': everydayRelationships,
    'conflict_resolution': conflictResolution,
  };
}

class GuidanceForParentsMentors {
  final String mentorshipGuideline;
  final String communicationKey;
  final GrowthExercise growthExercise;

  GuidanceForParentsMentors({
    required this.mentorshipGuideline,
    required this.communicationKey,
    required this.growthExercise,
  });

  factory GuidanceForParentsMentors.fromJson(Map<String, dynamic> json) =>
      GuidanceForParentsMentors(
        mentorshipGuideline: json['mentorship_guideline'] ?? '',
        communicationKey: json['communication_key'] ?? '',
        growthExercise: GrowthExercise.fromJson(json['growth_exercise'] ?? {}),
      );

  Map<String, dynamic> toJson() => {
    'mentorship_guideline': mentorshipGuideline,
    'communication_key': communicationKey,
    'growth_exercise': growthExercise.toJson(),
  };
}

class GrowthExercise {
  final String title;
  final String description;

  GrowthExercise({required this.title, required this.description});

  factory GrowthExercise.fromJson(Map<String, dynamic> json) => GrowthExercise(
    title: json['title'] ?? '',
    description: json['description'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'title': title,
    'description': description,
  };
}

class KeyMotivatorsPreferences {
  final String whatFuelsTheEngine;
  final String whatDrainsEnergy;

  KeyMotivatorsPreferences({
    required this.whatFuelsTheEngine,
    required this.whatDrainsEnergy,
  });

  factory KeyMotivatorsPreferences.fromJson(Map<String, dynamic> json) =>
      KeyMotivatorsPreferences(
        whatFuelsTheEngine: json['what_fuels_the_engine'] ?? '',
        whatDrainsEnergy: json['what_drains_energy'] ?? '',
      );

  Map<String, dynamic> toJson() => {
    'what_fuels_the_engine': whatFuelsTheEngine,
    'what_drains_energy': whatDrainsEnergy,
  };
}