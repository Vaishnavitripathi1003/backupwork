import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_as.dart';
import 'app_localizations_bn.dart';
import 'app_localizations_en.dart';
import 'app_localizations_gu.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_kn.dart';
import 'app_localizations_ml.dart';
import 'app_localizations_mr.dart';
import 'app_localizations_or.dart';
import 'app_localizations_pa.dart';
import 'app_localizations_ta.dart';
import 'app_localizations_te.dart';
import 'app_localizations_ur.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('as'),
    Locale('bn'),
    Locale('en'),
    Locale('gu'),
    Locale('hi'),
    Locale('kn'),
    Locale('ml'),
    Locale('mr'),
    Locale('or'),
    Locale('pa'),
    Locale('ta'),
    Locale('te'),
    Locale('ur')
  ];

  /// No description provided for @appName.
  ///
  /// In en, this message translates to:
  /// **'Daksh Student Pro'**
  String get appName;

  /// No description provided for @appVersion.
  ///
  /// In en, this message translates to:
  /// **'v2.4.0'**
  String get appVersion;

  /// No description provided for @appTagline.
  ///
  /// In en, this message translates to:
  /// **'AI DISC & Multi-Intelligence Comprehensive Battery'**
  String get appTagline;

  /// No description provided for @homeTitle.
  ///
  /// In en, this message translates to:
  /// **'DERMATOGLYPHICS PROTOCOL'**
  String get homeTitle;

  /// No description provided for @whyTakeDmit.
  ///
  /// In en, this message translates to:
  /// **'Why Take DMIT?'**
  String get whyTakeDmit;

  /// No description provided for @reportTitle.
  ///
  /// In en, this message translates to:
  /// **'Holistic Report'**
  String get reportTitle;

  /// No description provided for @reportSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Certified Assessment dossier'**
  String get reportSubtitle;

  /// No description provided for @candidateTitle.
  ///
  /// In en, this message translates to:
  /// **'Select Member to Analyze'**
  String get candidateTitle;

  /// No description provided for @activeCandidateLabel.
  ///
  /// In en, this message translates to:
  /// **'ACTIVE CANDIDATE PROFILE'**
  String get activeCandidateLabel;

  /// No description provided for @allCandidatesTitle.
  ///
  /// In en, this message translates to:
  /// **'All Candidates'**
  String get allCandidatesTitle;

  /// No description provided for @searchCandidatesHint.
  ///
  /// In en, this message translates to:
  /// **'Search by name or number'**
  String get searchCandidatesHint;

  /// No description provided for @adminProfileTitle.
  ///
  /// In en, this message translates to:
  /// **'Admin & Profile'**
  String get adminProfileTitle;

  /// No description provided for @familyPlan.
  ///
  /// In en, this message translates to:
  /// **'Family Plan'**
  String get familyPlan;

  /// No description provided for @candidateReportOverview.
  ///
  /// In en, this message translates to:
  /// **'Candidate report overview'**
  String get candidateReportOverview;

  /// No description provided for @scan10Fingers.
  ///
  /// In en, this message translates to:
  /// **'Start Analysis (Scan 10 Fingers)'**
  String get scan10Fingers;

  /// No description provided for @groupScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Group Mode (4-Fingers & Thumbs)'**
  String get groupScanTitle;

  /// No description provided for @individualScanTitle.
  ///
  /// In en, this message translates to:
  /// **'Single Fingertip Mode ⭐'**
  String get individualScanTitle;

  /// No description provided for @scanReady.
  ///
  /// In en, this message translates to:
  /// **'SCAN READY'**
  String get scanReady;

  /// No description provided for @reportGeneratingSoon.
  ///
  /// In en, this message translates to:
  /// **' Your Report is Generating Soon '**
  String get reportGeneratingSoon;

  /// No description provided for @fingerprintsUploadedSuccess.
  ///
  /// In en, this message translates to:
  /// **'Fingerprints uploaded successfully'**
  String get fingerprintsUploadedSuccess;

  /// No description provided for @reportAnalyzingFor.
  ///
  /// In en, this message translates to:
  /// **'Analyzing data for {name} and building your Report...'**
  String reportAnalyzingFor(String name);

  /// No description provided for @takesFewMoments.
  ///
  /// In en, this message translates to:
  /// **'This may take a few moments'**
  String get takesFewMoments;

  /// No description provided for @fiveSensesTitle.
  ///
  /// In en, this message translates to:
  /// **'5 Senses Sensory Modalities'**
  String get fiveSensesTitle;

  /// No description provided for @brainDominanceTitle.
  ///
  /// In en, this message translates to:
  /// **'Brain Dominance & Balance'**
  String get brainDominanceTitle;

  /// No description provided for @multiIntelligenceTitle.
  ///
  /// In en, this message translates to:
  /// **'8 Multiple Intelligences'**
  String get multiIntelligenceTitle;

  /// No description provided for @personalityBlendTitle.
  ///
  /// In en, this message translates to:
  /// **'DISC Personality Blend'**
  String get personalityBlendTitle;

  /// No description provided for @swotMatrixTitle.
  ///
  /// In en, this message translates to:
  /// **'SWOT Analysis & Matrix'**
  String get swotMatrixTitle;

  /// No description provided for @careerMatchTitle.
  ///
  /// In en, this message translates to:
  /// **'Precision Stream & Career Matches'**
  String get careerMatchTitle;

  /// No description provided for @addMember.
  ///
  /// In en, this message translates to:
  /// **'+ Add Member'**
  String get addMember;

  /// No description provided for @signOut.
  ///
  /// In en, this message translates to:
  /// **'Sign Out / Switch Account'**
  String get signOut;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @unlockAll.
  ///
  /// In en, this message translates to:
  /// **'Unlock All 👑'**
  String get unlockAll;

  /// No description provided for @exportLocked.
  ///
  /// In en, this message translates to:
  /// **'Export (Locked)'**
  String get exportLocked;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['as', 'bn', 'en', 'gu', 'hi', 'kn', 'ml', 'mr', 'or', 'pa', 'ta', 'te', 'ur'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'as': return AppLocalizationsAs();
    case 'bn': return AppLocalizationsBn();
    case 'en': return AppLocalizationsEn();
    case 'gu': return AppLocalizationsGu();
    case 'hi': return AppLocalizationsHi();
    case 'kn': return AppLocalizationsKn();
    case 'ml': return AppLocalizationsMl();
    case 'mr': return AppLocalizationsMr();
    case 'or': return AppLocalizationsOr();
    case 'pa': return AppLocalizationsPa();
    case 'ta': return AppLocalizationsTa();
    case 'te': return AppLocalizationsTe();
    case 'ur': return AppLocalizationsUr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
