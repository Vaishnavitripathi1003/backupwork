import 'dart:convert';
import 'dart:developer' as dev;

import 'package:daksh/data/models/multipleintellegenceResponse.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/brainDominanceResponse.dart';
import '../../data/models/careerMatchResponse.dart';
import '../../data/models/personalityblenResponse.dart';
import '../../data/models/sensesAnalysisResponse.dart';
import '../network/api_service.dart';
import '../storage/user_pref.dart';

/// Helper to log full report data in log without any cuts or truncation.
/// 1. Uses [dev.log] from `dart:developer` (no character length limit in DevTools/IDE console).
/// 2. Splits string into 800-character chunks for [debugPrint] (prevents Android Logcat line cutoff).
void logFullReportData(String tag, dynamic data) {
  try {
    final String str = data is String
        ? data
        : const JsonEncoder.withIndent('  ').convert(data);

    dev.log('========== $tag START (FULL REPORT DATA) ==========\n$str\n========== $tag END ($tag) ==========');

    const int chunkSize = 800;
    final int totalChunks = (str.length / chunkSize).ceil();
    for (int i = 0; i < str.length; i += chunkSize) {
      final end = (i + chunkSize < str.length) ? i + chunkSize : str.length;
      final currentChunk = (i / chunkSize).floor() + 1;
      debugPrint('[$tag CHUNK $currentChunk/$totalChunks] ${str.substring(i, end)}');
    }
  } catch (e) {
    debugPrint('[$tag LOG_ERROR] $e | Raw data: $data');
  }
}

class ReportService {
  /// Handle the common backend representations of the generation flag.
  /// Never infer readiness from a scan-upload response or from SQLite.
 /* static bool isReportGenerated(dynamic response) {
    if (response is! Map) return false;
    final dynamic field = response['isReportGenerated'] ??
        (response['data'] is Map ? response['data']['isReportGenerated'] : null);
    return field == true || field == 1 ||
        field?.toString().toLowerCase() == 'true' ||
        field?.toString() == '1';
  }*/
  static bool isReportGenerated(dynamic response) {
    debugPrint(
      'isReportGenerated INPUT -> type=${response.runtimeType}, value=$response',
    );

    if (response is! Map) {
      debugPrint('isReportGenerated RESULT -> false (response is not a Map)');
      return false;
    }

    final dynamic field = response['isReportGenerated'] ??
        (response['data'] is Map ? response['data']['isReportGenerated'] : null);

    final bool result = field == true ||
        field == 1 ||
        field?.toString().toLowerCase() == 'true' ||
        field?.toString() == '1';

    debugPrint(
      'isReportGenerated FIELD -> type=${field.runtimeType}, value=$field | RESULT -> $result',
    );

    return result;
  }

  final ApiService _apiService;

  ReportService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  // ---- user_param values sent to findReportByUserParam ----
  static const String personalityBlend = 'personality_blend';
  static const String multipleIntelligence = 'multiple_intelligence';
  static const String sensesAnalysis = 'senses_analysis';
  static const String brainDominance = 'brain_dominance';
  static const String careerMatch = 'career_match';

  /// Order in which the sections are requested (one by one).
  static const List<String> allParams = [
    personalityBlend,
    multipleIntelligence,
    sensesAnalysis,
    brainDominance,
    careerMatch,
  ];

  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return UserPref(prefs).getToken() ?? '';
  }

  // ==========================================
  // Core: ONE param -> raw response data (or null)
  // ==========================================
  Future<dynamic> fetchByParam({
    required String userParam,
    required String userDataId,
  }) async {
    final token = await _token();
    if (token.isEmpty || userDataId.isEmpty) {
      debugPrint('ReportService: token or userDataId missing');
      return null;
    }

    try {
      final response = await _apiService.findReportByUserParam(
        auth: token,
        userParam: userParam,
        userDataId: userDataId,
      );

      if (response.statusCode == 200 && response.data != null) {
        logFullReportData('ReportService [$userParam]', response.data);
        return response.data;
      }
      debugPrint('ReportService [$userParam] Failed: ${response.data}');
      return null;
    } catch (e) {
      debugPrint('ReportService [$userParam] Error: $e');
      return null;
    }
  }

  // ==========================================
  // Personality blend -> typed model
  // ==========================================
  Future<PersonalityBlendResponse?> fetchPersonalityBlend({
    required String userDataId,
  }) async {
    final data = await fetchByParam(
      userParam: personalityBlend,
      userDataId: userDataId,
    );
    if (data is Map<String, dynamic>) {
      try {
        logFullReportData('personality_blend', data);
        return PersonalityBlendResponse.fromJson(data);
      } catch (e) {
        debugPrint('personality_blend parse error: $e');
      }
    }
    return null;
  }

  // ==========================================
  // Other sections -> raw data for now (models coming next)
  // ==========================================
  Future<MultipleIntelligenceResponse?> fetchMultipleIntelligence(
      {required String userDataId}) async {
    final data = await fetchByParam(
      userParam: multipleIntelligence,
      userDataId: userDataId,
    );

    logFullReportData('MULTIPLE_INTELLIGENCE', data);

    if (data is Map<String, dynamic>) {
      try {
        return MultipleIntelligenceResponse.fromJson(data);
      } catch (e) {
        debugPrint('personality_blend parse error: $e');
      }
    }
    return null;
  }


  Future<SensesAnalysisResponse?> fetchSensesAnalysis({
    required String userDataId,
  }) async {
    final data = await fetchByParam(
      userParam: sensesAnalysis,
      userDataId: userDataId,
    );

    logFullReportData('SENSES', data);

    if (data is Map<String, dynamic>) {
      try {
        return SensesAnalysisResponse.fromJson(data);
      } catch (e) {
        debugPrint('senses_analysis parse error: $e');
      }
    }
    return null;
  }

  Future<BrainDominanceResponse?> fetchBrainDominance({
    required String userDataId,
  }) async {
    final data = await fetchByParam(
      userParam: brainDominance,
      userDataId: userDataId,
    );

    logFullReportData('BRAIN_DOMINANCE', data);

    if (data is Map<String, dynamic>) {
      try {
        return BrainDominanceResponse.fromJson(data);
      } catch (e) {
        debugPrint('brain_dominance parse error: $e');
      }
    }
    return null;
  }

  Future<CareerMatchResponse?> fetchCareerMatch({
    required String userDataId,
  }) async {
    final data = await fetchByParam(
      userParam: careerMatch,
      userDataId: userDataId,
    );

    logFullReportData('CAREER_MATCH', data);

    if (data is Map<String, dynamic>) {
      try {
        return CareerMatchResponse.fromJson(data);
      } catch (e) {
        debugPrint('career_match parse error: $e');
      }
    }
    return null;
  }


  Future<dynamic> fetchReportByUserId({
    required String userDataId,
  }) async {
    final token = await _token();
    if (token.isEmpty || userDataId.isEmpty) {
      debugPrint('ReportService: token or userDataId missing');
      return null;
    }

    try {
      final response = await _apiService.fetchReportStatus(
        auth: token,
        userDataId: userDataId,
      );

      if (response.statusCode == 200 && response.data != null) {
        logFullReportData('ReportStatus', response.data);
        return response.data;
      }

      return null;
    } catch (e) {

      return null;
    }
  }




}
// Global instance: MUST be outside the class
final reportService = ReportService();