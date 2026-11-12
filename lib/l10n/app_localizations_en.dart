// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Daksh Student Pro';

  @override
  String get appVersion => 'v2.4.0';

  @override
  String get appTagline => 'AI DISC & Multi-Intelligence Comprehensive Battery';

  @override
  String get homeTitle => 'DERMATOGLYPHICS PROTOCOL';

  @override
  String get whyTakeDmit => 'Why Take DMIT?';

  @override
  String get reportTitle => 'Holistic Report';

  @override
  String get reportSubtitle => 'Certified Assessment dossier';

  @override
  String get candidateTitle => 'Select Member to Analyze';

  @override
  String get activeCandidateLabel => 'ACTIVE CANDIDATE PROFILE';

  @override
  String get allCandidatesTitle => 'All Candidates';

  @override
  String get searchCandidatesHint => 'Search by name or number';

  @override
  String get adminProfileTitle => 'Admin & Profile';

  @override
  String get familyPlan => 'Family Plan';

  @override
  String get candidateReportOverview => 'Candidate report overview';

  @override
  String get scan10Fingers => 'Start Analysis (Scan 10 Fingers)';

  @override
  String get groupScanTitle => 'Group Mode (4-Fingers & Thumbs)';

  @override
  String get individualScanTitle => 'Single Fingertip Mode ⭐';

  @override
  String get scanReady => 'SCAN READY';

  @override
  String get reportGeneratingSoon => ' Your Report is Generating Soon ';

  @override
  String get fingerprintsUploadedSuccess => 'Fingerprints uploaded successfully';

  @override
  String reportAnalyzingFor(String name) {
    return 'Analyzing data for $name and building your Report...';
  }

  @override
  String get takesFewMoments => 'This may take a few moments';

  @override
  String get fiveSensesTitle => '5 Senses Sensory Modalities';

  @override
  String get brainDominanceTitle => 'Brain Dominance & Balance';

  @override
  String get multiIntelligenceTitle => '8 Multiple Intelligences';

  @override
  String get personalityBlendTitle => 'DISC Personality Blend';

  @override
  String get swotMatrixTitle => 'SWOT Analysis & Matrix';

  @override
  String get careerMatchTitle => 'Precision Stream & Career Matches';

  @override
  String get addMember => '+ Add Member';

  @override
  String get signOut => 'Sign Out / Switch Account';

  @override
  String get cancel => 'Cancel';

  @override
  String get retry => 'Retry';

  @override
  String get close => 'Close';

  @override
  String get unlockAll => 'Unlock All 👑';

  @override
  String get exportLocked => 'Export (Locked)';
}
