class AppLocalizations {
  final bool isHindi;

  AppLocalizations({this.isHindi = false});

  // ── HEADER & TOP BAR ──
  String get appTitle => isHindi ? 'दक्ष इंटेलिजेंस' : 'DAKSH INTELLIGENCE';
  String get appSubtitle => isHindi ? 'फिंगरप्रिंट बायोमेट्रिक प्लेटफॉर्म' : 'Fingerprint Biometric Platform';
  String get upgradePlan => isHindi ? 'अपग्रेड' : 'Upgrade';
  String get switchProfile => isHindi ? 'प्रोफ़ाइल बदलें' : 'Switch Profile';
  String get manageFamily => isHindi ? 'परिवार प्रबंधित करें' : 'Manage Family';
  String get selectCandidate => isHindi ? 'सदस्य का चयन करें' : 'Select Candidate';
  String get addMember => isHindi ? 'सदस्य जोड़ें' : 'Add Member';
  String get admin => isHindi ? 'एडमिन' : 'Admin';

  // ── GREETING & STATUS CARD ──
  String greetingName(String name) => isHindi ? 'नमस्ते, $name! 👋' : 'Hi, $name! 👋';
  String get fullSpectrumValidated => isHindi ? 'पूर्ण स्पेक्ट्रम सत्यापित' : 'Full Spectrum Validated';
  String get scanPending => isHindi ? 'स्कैन लंबित' : 'Scan Pending';

  // ── HERO SCAN CARD ──
  String get scanReady => isHindi ? 'स्कैन तैयार' : 'SCAN READY';
  String get startAnalysis => isHindi ? 'विश्लेषण शुरू करें' : 'Start Analysis';
  String scanSubtitle(String name) => isHindi
      ? 'सभी बौद्धिक क्षमताओं का विश्लेषण करने के लिए $name के 10 फिंगरप्रिंट स्कैन करें।'
      : 'Capture 10 fingerprints to calibrate $name\'s inborn neocortex lobes and unlock all intelligence dimensions.';
  String get startAnalysisBtn => isHindi ? 'विश्लेषण शुरू करें (10 फिंगरप्रिंट)' : 'Start Analysis (Scan 10 Fingers)';
  String get atdPalmScanBtn => isHindi ? 'ATD पाम स्कैन' : 'ATD Palm Scan';

  // ── LOADING CARD ──
  String get reportGenerating => isHindi ? 'रिपोर्ट तैयार हो रही है...' : 'Generating Report...';
  String get reportGeneratingSub => isHindi ? 'कृपया प्रतीक्षा करें, AI रिपोर्ट बना रहा है' : 'Please wait while AI generates your report';
  String get takesFewMoments => isHindi ? 'इसमें कुछ क्षण लग सकते हैं' : 'This may take a few moments';

  // ── SECTION 1: PERSONALITY BLEND (DISC) ──
  String get personalityBlendTitle => isHindi ? 'पर्सनालिटी ब्लेंड (DISC)' : 'Personality Blend (DISC)';
  String get personalityBlendSub => isHindi ? 'व्यवहार और व्यक्तित्व का विश्लेषण' : 'Behavioral & Personality Analysis';
  String get dominantType => isHindi ? 'प्रमुख प्रकार' : 'Dominant Type';
  String get primaryTrait => isHindi ? 'प्राथमिक विशेषता' : 'Primary Trait';
  String get secondaryTrait => isHindi ? 'द्वितीयक विशेषता' : 'Secondary Trait';

  // ── SECTION 2: MULTIPLE INTELLIGENCE ──
  String get multipleIntelligenceTitle => isHindi ? 'मल्टीपल इंटेलिजेंस' : 'Multiple Intelligence';
  String get multipleIntelligenceSub => isHindi ? '8 मुख्य बुद्धिमत्ता क्षमताएं' : '8 Core Intelligence Domains';
  String get topIntelligences => isHindi ? 'शीर्ष बुद्धिमत्ता क्षमताएं' : 'Top Intelligence Domains';

  // ── SECTION 3: BRAIN DOMINANCE ──
  String get brainDominanceTitle => isHindi ? 'मस्तिष्क प्रभुत्व' : 'Brain Dominance';
  String get brainDominanceSub => isHindi ? 'बायां बनाम दायां मस्तिष्क विश्लेषण' : 'Left vs Right Hemisphere Preference';
  String get leftBrain => isHindi ? 'बायां मस्तिष्क (तार्किक)' : 'Left Brain (Logical)';
  String get rightBrain => isHindi ? 'दायां मस्तिष्क (रचनात्मक)' : 'Right Brain (Creative)';

  // ── SECTION 4: SENSES ANALYSIS (VAK) ──
  String get sensesAnalysisTitle => isHindi ? 'इंद्रिय विश्लेषण (VAK)' : 'Senses Analysis (VAK)';
  String get sensesAnalysisSub => isHindi ? 'दृश्य, श्रव्य और गतिज सीखने की शैली' : 'Visual, Auditory & Kinesthetic Learning';
  String get visual => isHindi ? 'दृश्य (Visual)' : 'Visual';
  String get auditory => isHindi ? 'श्रव्य (Auditory)' : 'Auditory';
  String get kinesthetic => isHindi ? 'गतिज (Kinesthetic)' : 'Kinesthetic';

  // ── SECTION 5: CAREER MATCH ──
  String get careerMatchTitle => isHindi ? 'करियर मैच और सिफारिशें' : 'Career Match & Recommendations';
  String get careerMatchSub => isHindi ? 'शीर्ष अनुशंसित करियर क्षेत्र' : 'Top Recommended Career Domains';
  String get recommendedCareers => isHindi ? 'अनुशंसित करियर विकल्प' : 'Recommended Career Paths';

  // ── SECTION 6: ASK VAYO AI ──
  String get askVayoTitle => isHindi ? 'वायु एआई से पूछें' : 'Ask VAYO AI Assistant';
  String get askVayoSub => isHindi ? 'अपनी रिपोर्ट पर आधारित प्रश्नों के उत्तर पाएं' : 'Get answers based on your intelligence report';
  String get askQuestionHint => isHindi ? 'अपनी रिपोर्ट के बारे में कुछ भी पूछें...' : 'Ask anything about your report...';
  String get send => isHindi ? 'भेजें' : 'Send';

  // ── GENERAL & BUTTONS ──
  String get switchLanguage => isHindi ? 'English' : 'हिंदी';
  String get viewDetails => isHindi ? 'विवरण देखें' : 'View Details';
  String get retry => isHindi ? 'पुनः प्रयास करें' : 'Retry';
  String get close => isHindi ? 'बंद करें' : 'Close';
}
