/// Centralized App Strings repository containing 100% of all titles, banners, button labels,
/// error messages, dialog texts, and assessment descriptions used across the DAKSH Flutter application.
class AppStrings {
  AppStrings._();

  // ── APP INFO & BRANDING ──
  static const String appName = 'Daksh Student Pro';
  static const String appVersion = 'v2.4.0';
  static const String appTagline = 'AI DISC & Multi-Intelligence Comprehensive Battery';

  // ── DASHBOARD & HEADERS ──
  static const String homeTitle = 'DERMATOGLYPHICS PROTOCOL';
  static const String whyTakeDmit = 'Why Take DMIT?';
  static const String reportTitle = 'Holistic Report';
  static const String reportSubtitle = 'Certified Assessment dossier';
  static const String candidateTitle = 'Select Member to Analyze';
  static const String drawerHeaderTitle = 'DAKSH INTELLIGENCE MENU';
  static const String activeCandidateLabel = 'ACTIVE CANDIDATE PROFILE';
  static const String allCandidatesTitle = 'All Candidates';
  static const String searchCandidatesHint = 'Search by name or number';

  // ── BIOMETRIC SCANNER & PROTOCOL ──
  static const String scan10Fingers = 'Start Analysis (Scan 10 Fingers)';
  static const String groupScanTitle = 'Group Mode (4-Fingers & Thumbs)';
  static const String groupScanSubtitle = 'Scan 4 fingers together + both thumbs (Fastest AI Scan)';
  static const String groupScanAccuracy = '98.2% High Accuracy';
  static const String groupScanTime = 'Est. ~1 min completion time';
  static const String individualScanTitle = 'Single Fingertip Mode ⭐';
  static const String individualScanTagline = 'RECOMMENDED';
  static const String individualScanSubtitle = '10 Guided Steps (Each Finger Scanned Separately)';
  static const String individualScanAccuracy = '99.8% Maximum Biometric Accuracy';
  static const String individualScanTime = 'Est. ~2.5 mins completion time';
  static const String scanReady = 'SCAN READY';
  static const String reviewFingerprintTitle = 'REVIEW FINGERPRINT';
  static const String acceptAndBind = 'Accept & Bind';
  static const String rejectRetake = 'Reject';
  static const String zeroRawStorageTitle = 'Zero Raw Biometric Storage';
  static const String zeroRawStorageDesc =
      'Fingerprint patterns are immediately converted into mathematical ridge counts (TRC & ATD angles). No fingerprint images are ever stored or transmitted.';
  static const String uploadSuccessMessage = '✓ All 10 Fingerprints Uploaded to Server!';
  static const String reportLoadingText = 'Report Loading, Please Wait...';
  static const String reportGeneratingText =
      'Fingerprints uploaded successfully to server! Generating AI Biometric Neocortex Report...';

  // ── SCIENTIFIC NOTICES & ADVANTAGES ──
  static const String scientificNoticeTitle = 'SCIENTIFIC FOUNDATION';
  static const String scientificNoticeDesc =
      'Medical neuroscience proves that fingerprint epidermal ridges form synchronously with the cerebral neocortex during the 13th to 19th week of intrauterine gestation.';
  static const String advantage1Title = 'Inborn Strengths vs Acquired Skills';
  static const String advantage1Desc =
      'Decode natural genetic potential and innate cognitive strengths that remain stable throughout life.';
  static const String advantage2Title = 'Optimal Sensory Learning Style (VAK)';
  static const String advantage2Desc =
      'Identify whether you retain best through Visual (charts), Auditory (lectures), or Kinesthetic (hands-on tactile doing).';
  static const String advantage3Title = 'Hemispheric Brain Dominance';
  static const String advantage3Desc =
      'Discover Left Brain (sequential logic & math) vs Right Brain (creative spatial imagination) balance.';
  static const String advantage4Title = 'Precision Stream & Career Roadmapping';
  static const String advantage4Desc =
      'Avoid costly trial-and-error in Class 9–11; pinpoint alignment for PCM, PCB, Commerce, or Humanities.';
  static const String advantage5Title = 'EQ, IQ, AQ & CQ Quotient Profiling';
  static const String advantage5Desc =
      'Measure Emotional, Intellectual, Adversity (grit & resilience), and Creative quotients.';
  static const String advantage6Title = 'Stress Reduction & Parent Harmony';
  static const String advantage6Desc =
      'Replace parental expectations with scientific clarity, preventing exam fatigue and student burnout.';

  // ── FREEMIUM & UPGRADE PAYWALL ──
  static const String freemiumTagline = 'Freemium Plan Architecture';
  static const String unlockFullSuiteTitle = 'Unlock Full Cognitive Suite';
  static const String unlockFullSuiteSubtitle =
      'Free plan includes full Personality Type. Unlock all 8 Intelligences, 5 Senses, Brain Dominance & Live Sessions.';
  static const String currentFreemiumBreakdown = 'CURRENT FREEMIUM BREAKDOWN';
  static const String basicFreeTier = 'BASIC FREE TIER';
  static const String freeForever = 'Free Forever';
  static const String unlocksOnPay = 'Unlocks on Pay';
  static const String familyVipPackTitle = 'Family VIP Pack (Recommended)';
  static const String familyVipPackSubtitle = 'Up to 5 Family Members • All reports + Live Counselor slot';
  static const String familyVipPrice = '₹999';
  static const String familyVipOriginalPrice = '₹2,999';
  static const String singleStudentPassTitle = 'Single Student Pass';
  static const String singleStudentPassSubtitle = '1 Student lifetime access to all unlocked reports';
  static const String singleStudentPrice = '₹499';
  static const String singleStudentOriginalPrice = '₹1,499';
  static const String payAndUnlockNow = 'Pay & Unlock Everything Now ✨';
  static const String bestValueBadge = 'Best Value';
  static const String freeTierPreviewActive = 'Free Tier Preview Active';
  static const String freeTierPreviewSubtitle =
      'Personality Type is 100% unlocked. Full PDF export & multi-intelligence drilldowns lock until Premium.';

  // ── COGNITIVE ASSESSMENTS ──
  static const String multiIntelligenceTitle = '8 Multiple Intelligences';
  static const String brainDominanceTitle = 'Brain Dominance & Balance';
  static const String fiveSensesTitle = '5 Senses Sensory Modalities';
  static const String personalityBlendTitle = 'DISC Personality Blend';
  static const String swotMatrixTitle = 'SWOT Analysis & Matrix';
  static const String careerMatchTitle = 'Precision Stream & Career Matches';

  // ── DIALOGS & MESSAGES ──
  static const String addMemberTitle = 'Add Family Member';
  static const String nameInputLabel = 'Full Name';
  static const String classInputLabel = 'Grade / Class';
  static const String mobileInputLabel = 'Mobile Number';
  static const String signOutTitle = 'Sign Out';
  static const String signOutConfirm = 'Are you sure you want to sign out and switch accounts?';
  static const String noReportFoundTitle = 'No Report Found';
  static const String noReportFoundDesc =
      'No biometric report has been generated yet for this member. Please complete the 10-finger scan to generate the certified assessment report.';

  // ── BUTTONS & ACTIONS ──
  static const String unlockAll = 'Unlock All 👑';
  static const String viewMore = 'View More';
  static const String addMember = '+ Add Member';
  static const String signOut = 'Sign Out / Switch Account';
  static const String cancel = 'Cancel';
  static const String retry = 'Retry';
  static const String close = 'Close';
  static const String proceedToScan = 'Proceed to 10–Finger Biometric Scan';
  static const String exportLocked = 'Export (Locked)';
}
