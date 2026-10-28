import 'package:flutter/material.dart';

class StudentProfile {
  final String id;
  final String name;
  final String role;
  final String avatar;
  final String gender;
  final String grade;
  final bool active;

  const StudentProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.avatar,
    required this.gender,
    required this.grade,
    this.active = false,
  });

  factory StudentProfile.fromJson(Map<String, dynamic> json) {
    return StudentProfile(
      id: json['id'] as String? ?? '1',
      name: json['name'] as String? ?? 'Student',
      role: json['role'] as String? ?? 'Learner',
      avatar: json['avatar'] as String? ?? '👦',
      gender: json['gender'] as String? ?? 'boy',
      grade: json['grade'] as String? ?? 'Grade 10',
      active: json['active'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'role': role,
    'avatar': avatar,
    'gender': gender,
    'grade': grade,
    'active': active,
  };
}

class IntelligenceScore {
  final String id;
  final String name;
  final String shortName;
  final double score; // 0 to 100
  final String ratingText;
  final Color color;
  final String description;
  final List<String> goodAt;
  final List<String> careers;
  final List<String> improvements;

  const IntelligenceScore({
    required this.id,
    required this.name,
    required this.shortName,
    required this.score,
    required this.ratingText,
    required this.color,
    required this.description,
    required this.goodAt,
    required this.careers,
    required this.improvements,
  });
}

class BrainDominanceData {
  final double leftBrainPercent;
  final double rightBrainPercent;
  final String dominantType;
  final String summary;
  final List<String> leftTraits;
  final List<String> rightTraits;

  const BrainDominanceData({
    required this.leftBrainPercent,
    required this.rightBrainPercent,
    required this.dominantType,
    required this.summary,
    required this.leftTraits,
    required this.rightTraits,
  });
}

class SwotQuadrant {
  final String type; // STRENGTHS, WEAKNESSES, OPPORTUNITIES, THREATS
  final Color color;
  final List<String> items;

  const SwotQuadrant({
    required this.type,
    required this.color,
    required this.items,
  });
}
