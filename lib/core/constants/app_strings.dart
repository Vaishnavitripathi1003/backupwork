import '../localization/language_manager.dart';

/// Centralized App Strings repository containing 100% of all titles, banners, button labels,
/// error messages, dialog texts, and assessment descriptions used across the DAKSH Flutter application.
/// 
/// All string getters dynamically return English or Hindi translations based on [LanguageManager.instance.isHindi].
class AppStrings {
  AppStrings._();

  static bool get isHindi => LanguageManager.instance.isHindi;

  // ── APP INFO & BRANDING ──
  static String get appName => isHindi ? 'दक्ष स्टूडेंट प्रो' : 'Daksh Student Pro';
  static String get appVersion => 'v2.4.0';
  static String get appTagline => isHindi
      ? 'AI DISC और मल्टी-इंटेलिजेंस संपूर्ण मूल्यांकन बैटरी'
      : 'AI DISC & Multi-Intelligence Comprehensive Battery';

  // ── DASHBOARD & HEADERS ──
  static String get homeTitle => isHindi ? 'डर्माटोग्लिफिक्स प्रोटोकॉल' : 'DERMATOGLYPHICS PROTOCOL';
  static String get whyTakeDmit => isHindi ? 'DMIT क्यों लें?' : 'Why Take DMIT?';
  static String get reportTitle => isHindi ? 'समग्र रिपोर्ट' : 'Holistic Report';
  static String get reportSubtitle => isHindi ? 'प्रमाणित मूल्यांकन डोजियर' : 'Certified Assessment dossier';
  static String get candidateTitle => isHindi ? 'विश्लेषण के लिए सदस्य चुनें' : 'Select Member to Analyze';
  static String get drawerHeaderTitle => isHindi ? 'दक्ष बुद्धिमत्ता मेनू' : 'DAKSH INTELLIGENCE MENU';
  static String get activeCandidateLabel => isHindi ? 'सक्रिय उम्मीदवार प्रोफ़ाइल' : 'ACTIVE CANDIDATE PROFILE';
  static String get allCandidatesTitle => isHindi ? 'सभी उम्मीदवार' : 'All Candidates';
  static String get searchCandidatesHint => isHindi ? 'नाम या नंबर से खोजें' : 'Search by name or number';
  static String get adminProfileTitle => isHindi ? 'एडमिन और प्रोफ़ाइल' : 'Admin & Profile';
  static String get familyPlan => isHindi ? 'फैमिली प्लान' : 'Family Plan';
  static String get candidateReportOverview => isHindi ? 'उम्मीदवार रिपोर्ट अवलोकन' : 'Candidate report overview';

  // ── BIOMETRIC SCANNER & PROTOCOL ──
  static String get scan10Fingers => isHindi ? 'विश्लेषण शुरू करें (10 उंगलियां स्कैन करें)' : 'Start Analysis (Scan 10 Fingers)';
  static String get groupScanTitle => isHindi ? 'ग्रुप मोड (4 उंगलियां और अंगूठे)' : 'Group Mode (4-Fingers & Thumbs)';
  static String get groupScanSubtitle => isHindi
      ? '4 उंगलियां एक साथ + दोनों अंगूठे स्कैन करें (सबसे तेज़ AI स्कैन)'
      : 'Scan 4 fingers together + both thumbs (Fastest AI Scan)';
  static String get groupScanAccuracy => isHindi ? '98.2% उच्च सटीकता' : '98.2% High Accuracy';
  static String get groupScanTime => isHindi ? 'अनुमानित ~1 मिनट में पूरा' : 'Est. ~1 min completion time';
  static String get individualScanTitle => isHindi ? 'सिंगल फ़िंगरप्रिंट मोड ⭐' : 'Single Fingertip Mode ⭐';
  static String get individualScanTagline => isHindi ? 'अनुशंसित' : 'RECOMMENDED';
  static String get individualScanSubtitle => isHindi
      ? '10 चरणबद्ध स्टेप्स (प्रत्येक उंगली अलग से स्कैन)'
      : '10 Guided Steps (Each Finger Scanned Separately)';
  static String get individualScanAccuracy => isHindi ? '99.8% अधिकतम बायोमेट्रिक सटीकता' : '99.8% Maximum Biometric Accuracy';
  static String get individualScanTime => isHindi ? 'अनुमानित ~2.5 मिनट में पूरा' : 'Est. ~2.5 mins completion time';
  static String get scanReady => isHindi ? 'स्कैन तैयार' : 'SCAN READY';
  static String get reviewFingerprintTitle => isHindi ? 'फ़िंगरप्रिंट की समीक्षा करें' : 'REVIEW FINGERPRINT';
  static String get acceptAndBind => isHindi ? 'स्वीकार करें और बाइंड करें' : 'Accept & Bind';
  static String get rejectRetake => isHindi ? 'अस्वीकार करें' : 'Reject';
  static String get zeroRawStorageTitle => isHindi ? 'शून्य कच्चा बायोमेट्रिक स्टोरेज' : 'Zero Raw Biometric Storage';
  static String get zeroRawStorageDesc => isHindi
      ? 'फ़िंगरप्रिंट पैटर्न तुरंत गणितीय रिज काउंट (TRC और ATD कोण) में बदल जाते हैं। कोई फ़िंगरप्रिंट छवि कभी संग्रहीत नहीं होती।'
      : 'Fingerprint patterns are immediately converted into mathematical ridge counts (TRC & ATD angles). No fingerprint images are ever stored or transmitted.';
  static String get uploadSuccessMessage => isHindi ? '✓ सभी 10 फ़िंगरप्रिंट सर्वर पर अपलोड हो गए!' : '✓ All 10 Fingerprints Uploaded to Server!';
  static String get reportLoadingText => isHindi ? 'रिपोर्ट लोड हो रही है, कृपया प्रतीक्षा करें...' : 'Report Loading, Please Wait...';
  static String get reportGeneratingText => isHindi
      ? 'फ़िंगरप्रिंट सफलतापूर्वक सर्वर पर अपलोड हो गए! AI न्यूरोकोर्टेक्स रिपोर्ट तैयार हो रही है...'
      : 'Fingerprints uploaded successfully to server! Generating AI Biometric Neocortex Report...';

  // ── SCIENTIFIC NOTICES & ADVANTAGES ──
  static String get scientificNoticeTitle => isHindi ? 'वैज्ञानिक आधार' : 'SCIENTIFIC FOUNDATION';
  static String get scientificNoticeDesc => isHindi
      ? 'चिकित्सा तंत्रिका विज्ञान साबित करता है कि फ़िंगरप्रिंट एपिडर्मल रिज गर्भावस्था के 13वें से 19वें सप्ताह के दौरान मस्तिष्क के साथ समानांतर रूप से बनते हैं।'
      : 'Medical neuroscience proves that fingerprint epidermal ridges form synchronously with the cerebral neocortex during the 13th to 19th week of intrauterine gestation.';
  static String get advantage1Title => isHindi ? 'जन्मजात क्षमता बनाम अर्जित कौशल' : 'Inborn Strengths vs Acquired Skills';
  static String get advantage1Desc => isHindi
      ? 'प्राकृतिक आनुवंशिक क्षमता और जन्मजात संज्ञानात्मक ताकतों को समझें जो जीवन भर स्थिर रहती हैं।'
      : 'Decode natural genetic potential and innate cognitive strengths that remain stable throughout life.';
  static String get advantage2Title => isHindi ? 'सर्वश्रेष्ठ सीखने की शैली (VAK)' : 'Optimal Sensory Learning Style (VAK)';
  static String get advantage2Desc => isHindi
      ? 'पहचानें कि आप विज़ुअल (चित्र), ऑडिटरी (सुनकर), या काइनेस्थेटिक (करके) कैसे बेहतर सीखते हैं।'
      : 'Identify whether you retain best through Visual (charts), Auditory (lectures), or Kinesthetic (hands-on tactile doing).';
  static String get advantage3Title => isHindi ? 'मस्तिष्क की प्रधानता (Left vs Right Brain)' : 'Hemispheric Brain Dominance';
  static String get advantage3Desc => isHindi
      ? 'बायां दिमाग (तर्क और गणित) बनाम दायां दिमाग (रचनात्मक कल्पना) का संतुलन खोजें।'
      : 'Discover Left Brain (sequential logic & math) vs Right Brain (creative spatial imagination) balance.';
  static String get advantage4Title => isHindi ? 'सटीक विषय और करियर रोडमैपिंग' : 'Precision Stream & Career Roadmapping';
  static String get advantage4Desc => isHindi
      ? 'कक्षा 9-11 में भ्रम से बचें; PCM, PCB, कॉमर्स या ह्यूमैनिटीज के लिए सही संरेखण पहचानें।'
      : 'Avoid costly trial-and-error in Class 9–11; pinpoint alignment for PCM, PCB, Commerce, or Humanities.';
  static String get advantage5Title => isHindi ? 'EQ, IQ, AQ और CQ प्रोफाइलिंग' : 'EQ, IQ, AQ & CQ Quotient Profiling';
  static String get advantage5Desc => isHindi
      ? 'भावनात्मक, बौद्धिक, विपरीत परिस्थिति (धैर्य) और रचनात्मक गुणांकों को मापें।'
      : 'Measure Emotional, Intellectual, Adversity (grit & resilience), and Creative quotients.';
  static String get advantage6Title => isHindi ? 'तनाव में कमी और पारिवारिक सामंजस्य' : 'Stress Reduction & Parent Harmony';
  static String get advantage6Desc => isHindi
      ? 'अभिभावकीय दबाव को वैज्ञानिक स्पष्टता से बदलें, जिससे परीक्षा की थकान और तनाव से बचाव हो।'
      : 'Replace parental expectations with scientific clarity, preventing exam fatigue and student burnout.';

  // ── FREEMIUM & UPGRADE PAYWALL ──
  static String get freemiumTagline => isHindi ? 'फ्रीमियम योजना संरचना' : 'Freemium Plan Architecture';
  static String get unlockFullSuiteTitle => isHindi ? 'पूर्ण संज्ञानात्मक सुइट अनलॉक करें' : 'Unlock Full Cognitive Suite';
  static String get unlockFullSuiteSubtitle => isHindi
      ? 'मुफ्त योजना में पर्सनालिटी टाइप शामिल है। सभी 8 बुद्धिमत्ता और मस्तिष्क संतुलन अनलॉक करने के लिए अपग्रेड करें।'
      : 'Free plan includes full Personality Type. Unlock all 8 Intelligences, 5 Senses, Brain Dominance & Live Sessions.';
  static String get currentFreemiumBreakdown => isHindi ? 'वर्तमान फ्रीमियम विवरण' : 'CURRENT FREEMIUM BREAKDOWN';
  static String get basicFreeTier => isHindi ? 'बेसिक फ्री टियर' : 'BASIC FREE TIER';
  static String get freeForever => isHindi ? 'हमेशा मुफ़्त' : 'Free Forever';
  static String get unlocksOnPay => isHindi ? 'भुगतान पर अनलॉक' : 'Unlocks on Pay';
  static String get familyVipPackTitle => isHindi ? 'फैमिली वीआईपी पैक (अनुशंसित)' : 'Family VIP Pack (Recommended)';
  static String get familyVipPackSubtitle => isHindi ? '5 परिवार के सदस्यों तक • सभी रिपोर्ट + लाइव काउंसलर स्लॉट' : 'Up to 5 Family Members • All reports + Live Counselor slot';
  static String get familyVipPrice => '₹999';
  static String get familyVipOriginalPrice => '₹2,999';
  static String get singleStudentPassTitle => isHindi ? 'सिंगल स्टूडेंट पास' : 'Single Student Pass';
  static String get singleStudentPassSubtitle => isHindi ? '1 छात्र के लिए सभी रिपोर्ट का आजीवन एक्सेस' : '1 Student lifetime access to all unlocked reports';
  static String get singleStudentPrice => '₹499';
  static String get singleStudentOriginalPrice => '₹1,499';
  static String get payAndUnlockNow => isHindi ? 'अभी भुगतान करें और सब कुछ अनलॉक करें ✨' : 'Pay & Unlock Everything Now ✨';
  static String get bestValueBadge => isHindi ? 'सबसे अच्छा मूल्य' : 'Best Value';
  static String get freeTierPreviewActive => isHindi ? 'फ्री टियर पूर्वावलोकन सक्रिय' : 'Free Tier Preview Active';
  static String get freeTierPreviewSubtitle => isHindi
      ? 'पर्सनालिटी टाइप 100% अनलॉक है। पूर्ण पीडीएफ निर्यात प्रीमियम तक लॉक रहेगा।'
      : 'Personality Type is 100% unlocked. Full PDF export & multi-intelligence drilldowns lock until Premium.';

  // ── COGNITIVE ASSESSMENTS ──
  static String get multiIntelligenceTitle => isHindi ? '8 बहु-बुद्धिमत्ता (Multiple Intelligences)' : '8 Multiple Intelligences';
  static String get brainDominanceTitle => isHindi ? 'मस्तिष्क प्रधानता और संतुलन' : 'Brain Dominance & Balance';
  static String get fiveSensesTitle => isHindi ? '5 इंद्रियां सीखने की शैली (VAK)' : '5 Senses Sensory Modalities';
  static String get personalityBlendTitle => isHindi ? 'DISC पर्सनालिटी मिश्रण' : 'DISC Personality Blend';
  static String get swotMatrixTitle => isHindi ? 'SWOT विश्लेषण और मैट्रिक्स' : 'SWOT Analysis & Matrix';
  static String get careerMatchTitle => isHindi ? 'सटीक संकाय और करियर मैच' : 'Precision Stream & Career Matches';
  static String get unlockPersonalizedRecommendations => isHindi ? 'व्यक्तिगत अनुशंसाएं अनलॉक करें 👑' : 'Unlock Personalized Recommendations 👑';

  // ── DIALOGS & MESSAGES ──
  static String get addMemberTitle => isHindi ? 'परिवार के सदस्य को जोड़ें' : 'Add Family Member';
  static String get candidateMembers => isHindi ? 'उम्मीदवार सदस्य' : 'Candidate Members';
  static String get noMembersYet => isHindi ? 'अभी कोई सदस्य नहीं हैं' : 'No members yet';
  static String get nameInputLabel => isHindi ? 'पूरा नाम' : 'Full Name';
  static String get classInputLabel => isHindi ? 'कक्षा / ग्रेड' : 'Grade / Class';
  static String get mobileInputLabel => isHindi ? 'मोबाइल नंबर' : 'Mobile Number';
  static String get signOutTitle => isHindi ? 'साइन आउट' : 'Sign Out';
  static String get signOutConfirm => isHindi ? 'क्या आप साइन आउट करना और खाता बदलना चाहते हैं?' : 'Are you sure you want to sign out and switch accounts?';
  static String get noReportFoundTitle => isHindi ? 'कोई रिपोर्ट नहीं मिली' : 'No Report Found';
  static String get noReportFoundDesc => isHindi
      ? 'इस सदस्य के लिए अभी तक कोई बायोमेट्रिक रिपोर्ट तैयार नहीं की गई है। कृपया रिपोर्ट तैयार करने के लिए 10-उंगली स्कैन पूरा करें।'
      : 'No biometric report has been generated yet for this member. Please complete the 10-finger scan to generate the certified assessment report.';
  static String get preferencesAndSupport => isHindi ? 'प्राथमिकताएं और सहायता' : 'Preferences & Support';
  static String get dailyReminders => isHindi ? 'दैनिक AI परामर्शदाता रिमाइंडर' : 'Daily AI Counselor Reminders';
  static String get dataPrivacy => isHindi ? 'मूल्यांकन डेटा गोपनीयता' : 'Assessment Data Privacy';
  static String get mentorshipHotline => isHindi ? 'सहायता और छात्र मार्गदर्शन हॉटलाइन' : 'Help & Student Mentorship Hotline';
  static String get supportText => isHindi ? 'सहायता →' : 'Support →';
  static String get activeText => isHindi ? 'सक्रिय' : 'Active';
  static String get adminRole => isHindi ? 'एडमिन' : 'Admin';
  static String get lockedTag => isHindi ? 'लॉक' : 'Locked';

  // ── BUTTONS & ACTIONS ──
  static String get unlockAll => isHindi ? 'सभी अनलॉक करें 👑' : 'Unlock All 👑';
  static String get viewMore => isHindi ? 'और देखें' : 'View More';
  static String get addMember => isHindi ? '+ सदस्य जोड़ें' : '+ Add Member';
  static String get signOut => isHindi ? 'साइन आउट / खाता बदलें' : 'Sign Out / Switch Account';
  static String get cancel => isHindi ? 'रद्द करें' : 'Cancel';
  static String get retry => isHindi ? 'पुनः प्रयास करें' : 'Retry';
  static String get close => isHindi ? 'बंद करें' : 'Close';
  static String get proceedToScan => isHindi ? '10-उंगली बायोमेट्रिक स्कैन पर आगे बढ़ें' : 'Proceed to 10–Finger Biometric Scan';
  static String get exportLocked => isHindi ? 'निर्यात (लॉक)' : 'Export (Locked)';
}
