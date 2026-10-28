class UserProfile {
  final String id;
  final String name;
  final String role;
  final String emoji;
  final String studentId;
  final String archetype;
  final String personalityPrimary;
  final String personalitySecondary;
  final int primaryPercent;
  final int secondaryPercent;
  final int strengthsCount;
  final int weaknessesCount;
  final String brainDominance;
  final String sensoryPreference;
  final String topCareerMatch;
  final int careerMatchPercent;

  const UserProfile({
    required this.id,
    required this.name,
    required this.role,
    required this.emoji,
    required this.studentId,
    required this.archetype,
    required this.personalityPrimary,
    required this.personalitySecondary,
    required this.primaryPercent,
    required this.secondaryPercent,
    required this.strengthsCount,
    required this.weaknessesCount,
    required this.brainDominance,
    required this.sensoryPreference,
    required this.topCareerMatch,
    required this.careerMatchPercent,
  });

  static const List<UserProfile> mockProfiles = [
    UserProfile(
      id: '1',
      name: 'Aarav',
      role: 'Class 8',
      emoji: '👦',
      studentId: '#DK-9842',
      archetype: 'Visual–Kinesthetic Leader (High Logical Fluency)',
      personalityPrimary: 'Dominate',
      personalitySecondary: 'Influential',
      primaryPercent: 65,
      secondaryPercent: 35,
      strengthsCount: 12,
      weaknessesCount: 5,
      brainDominance: 'Right Brain Dominant (65%)',
      sensoryPreference: 'Vision (88%) & Touch (82%)',
      topCareerMatch: 'Software Engineer',
      careerMatchPercent: 94,
    ),
    UserProfile(
      id: '2',
      name: 'Ananya',
      role: 'Class 11',
      emoji: '👧',
      studentId: '#DK-9843',
      archetype: 'Analytical–Logical Thinker (High Math Fluency)',
      personalityPrimary: 'Influential',
      personalitySecondary: 'Steadiness',
      primaryPercent: 60,
      secondaryPercent: 40,
      strengthsCount: 15,
      weaknessesCount: 3,
      brainDominance: 'Left Brain Dominant (72%)',
      sensoryPreference: 'Vision (92%) & Hearing (78%)',
      topCareerMatch: 'Data Scientist / AI Engineer',
      careerMatchPercent: 96,
    ),
    UserProfile(
      id: '3',
      name: 'Rahul',
      role: 'Father',
      emoji: '👨',
      studentId: '#DK-9844',
      archetype: 'Strategic Mentor (High Interpersonal Fluency)',
      personalityPrimary: 'Steadiness',
      personalitySecondary: 'Conscientiousness',
      primaryPercent: 70,
      secondaryPercent: 30,
      strengthsCount: 18,
      weaknessesCount: 4,
      brainDominance: 'Balanced Brain (50% / 50%)',
      sensoryPreference: 'Hearing (85%) & Touch (80%)',
      topCareerMatch: 'Product Director',
      careerMatchPercent: 95,
    ),
    UserProfile(
      id: '4',
      name: 'Priya',
      role: 'Mother',
      emoji: '👩',
      studentId: '#DK-9845',
      archetype: 'Empathetic Facilitator (High Linguistic)',
      personalityPrimary: 'Compliance',
      personalitySecondary: 'Influential',
      primaryPercent: 65,
      secondaryPercent: 35,
      strengthsCount: 16,
      weaknessesCount: 2,
      brainDominance: 'Right Brain Dominant (60%)',
      sensoryPreference: 'Vision (85%) & Hearing (82%)',
      topCareerMatch: 'Counselor / Psychologist',
      careerMatchPercent: 97,
    ),
  ];
}
