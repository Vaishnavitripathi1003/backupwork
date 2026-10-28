// lib/core/services/home_data_preloader.dart
import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user_models.dart';
import '../database/database_helper.dart';
import '../models/reportResponse.dart';
import '../network/api_service.dart';
import '../storage/user_pref.dart';

/// Loads everything the Home screen needs (candidate list + reports) in the
/// background right after login, so HomeScreen can render instantly.
///
/// Order of lookup for a report:  memory  ->  disk (SharedPreferences)  ->  API.
class HomeDataPreloader {
  HomeDataPreloader._();
  static final HomeDataPreloader instance = HomeDataPreloader._();

  static const String _diskPrefix = 'home_report_cache_';

  /// Latest candidate list fetched from the server (null until first load).
  List<User>? candidates;

  /// In-memory report cache (memberId -> report).
  final Map<String, ReportModel> reports = {};

  bool loadedOnce = false;
  Future<void>? _running;
  final Map<String, Future<ReportModel?>> _reportFutures = {};

  // ---------------------------------------------------------------- public

  /// Call right after a successful login (clears the previous user's data first).
  Future<void> startAfterLogin() async {
    await clear();
    ensureStarted(force: true); // fire & forget
  }

  /// Called by LoginService with the candidate list it already fetched and
  /// saved to SQLite (avoids a duplicate API call). Starts report prefetch.
  void seedCandidates(List<User> list) {
    candidates = list;
    loadedOnce = true;
    unawaited(_prefetchFirst(list)); // background, not awaited
  }

  /// Starts the candidate preload if it hasn't run yet.
  /// Returned future completes when the candidate list is ready
  /// (report prefetch keeps running in the background).
  Future<void> ensureStarted({bool force = false}) {
    if (force) {
      _running = _run().whenComplete(() => _running = null);
      return _running!;
    }
    if (_running != null) return _running!;
    if (loadedOnce) return Future.value();
    _running = _run().whenComplete(() => _running = null);
    return _running!;
  }

  /// Memory -> disk -> API (deduplicated). Returns null if report isn't ready.
  Future<ReportModel?> loadReport(String id, {bool forceNetwork = false}) {
    if (!forceNetwork) {
      final cached = reports[id];
      if (cached != null) return Future.value(cached);
      final inFlight = _reportFutures[id];
      if (inFlight != null) return inFlight;
    }
    final f = _loadReportInner(id, forceNetwork)
        .whenComplete(() => _reportFutures.remove(id));
    _reportFutures[id] = f;
    return f;
  }

  /// Forget a member's cached report (e.g. after a fresh scan).
  Future<void> invalidate(String id) async {
    reports.remove(id);
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('$_diskPrefix$id');
    } catch (_) {}
  }

  /// Call on logout / before a new login.
  Future<void> clear() async {
    candidates = null;
    reports.clear();
    _reportFutures.clear();
    loadedOnce = false;
    try {
      final prefs = await SharedPreferences.getInstance();
      for (final k in prefs.getKeys().where((k) => k.startsWith(_diskPrefix)).toList()) {
        await prefs.remove(k);
      }
    } catch (_) {}
  }

  // --------------------------------------------------------------- private

  Future<String> _token() async {
    final prefs = await SharedPreferences.getInstance();
    return UserPref(prefs).getToken() ?? '';
  }

  Future<void> _run() async {
    try {
      final token = await _token();
      if (token.isEmpty) return;

      final response = await ApiService().findFingerPrintScanByAdmin(auth: token);
      if (response.statusCode == 200 && response.data != null) {
        final resp = CandidateListResponse.fromJson(response.data);
        final list = resp.data;
        if (list != null && list.isNotEmpty) {
          // Keep locally known "report generated" flags
          final local = await DatabaseHelper.instance.getCandidateMembers();
          final done = <String>{
            for (final c in local)
              if (c.isReportGenerated == true) c.id,
          };
          for (final u in list) {
            if (done.contains(u.id)) u.isReportGenerated = true;
          }

          candidates = list;

          // Non-blocking DB write
          unawaited(DatabaseHelper.instance.insertCandidateMembers(list).then(
                (_) {},
            onError: (e) => debugPrint('Insert candidates error: $e'),
          ));

          // Reports download in background (not awaited)
          unawaited(_prefetchFirst(list));
        }
      }
    } catch (e) {
      debugPrint('HomeDataPreloader error: $e');
    } finally {
      loadedOnce = true;
    }
  }

  /// Sirf default-selected (pehle) member ki report background me laao,
  /// aur sirf tab jab uska isReportGenerated == true ho.
  /// Baaki members ki report tab aayegi jab user unhe select karega.
  Future<void> _prefetchFirst(List<User> list) async {
    if (list.isEmpty) return;
    final first = list.first;
    if (first.isReportGenerated != true || first.id.isEmpty) return;
    try {
      await loadReport(first.id);
    } catch (e) {
      debugPrint('Prefetch error for ${first.id}: $e');
    }
  }

  Future<ReportModel?> _loadReportInner(String id, bool forceNetwork) async {
    if (!forceNetwork) {
      final disk = await _readFromDisk(id);
      if (disk != null) {
        reports[id] = disk;
        return disk;
      }
    }
    final token = await _token();
    if (token.isEmpty || id.isEmpty) return null;

    final response = await ApiService().findReportByUserDataId(
      auth: token,
      userDataId: id,
    );
    if (response.statusCode == 200 && response.data != null) {
      final reportResp = ReportResponse.fromJson(response.data);
      if (reportResp.report.isNotEmpty) {
        final report = reportResp.report.first;
        reports[id] = report;
        unawaited(_saveToDisk(id, response.data));
        return report;
      }
    }
    return null;
  }

  Future<ReportModel?> _readFromDisk(String id) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('$_diskPrefix$id');
      if (raw == null || raw.isEmpty) return null;
      final resp = ReportResponse.fromJson(jsonDecode(raw));
      return resp.report.isNotEmpty ? resp.report.first : null;
    } catch (e) {
      debugPrint('Disk report read error: $e');
      return null;
    }
  }

  Future<void> _saveToDisk(String id, dynamic data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('$_diskPrefix$id', jsonEncode(data));
    } catch (e) {
      debugPrint('Disk report save error: $e');
    }
  }
}