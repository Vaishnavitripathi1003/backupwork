import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Global/global_class.dart';
import '../database/database_helper.dart';
import '../storage/user_pref.dart';
import 'ReportService.dart';

/// Only a scan initiated from Dashboard starts this flow.
/// Upload success is NOT the same as report-generation success.
enum DashboardReportPhase { idle, waiting, ready, failed }

@immutable
class DashboardReportState {
  final String candidateId;
  final DashboardReportPhase phase;
  final String message;

  const DashboardReportState({
    this.candidateId = '',
    this.phase = DashboardReportPhase.idle,
    this.message = '',
  });

  bool waitingFor(String id) =>
      candidateId == id && phase == DashboardReportPhase.waiting;
  bool readyFor(String id) =>
      candidateId == id && phase == DashboardReportPhase.ready;
  bool failedFor(String id) =>
      candidateId == id && phase == DashboardReportPhase.failed;
}

/// Single poller shared by the Dashboard, Report tab and Home tab.
/// Stops when the candidate changes, and ignores responses from older polls.
class DashboardReportStatusController {
  DashboardReportStatusController._() {
    GlobalClass.selectedMemberNotifier.addListener(_onCandidateChanged);
  }

  static final DashboardReportStatusController instance =
      DashboardReportStatusController._();

  final ValueNotifier<DashboardReportState> state =
      ValueNotifier(const DashboardReportState());

  int _pollVersion = 0;

  void _onCandidateChanged() {
    final current = state.value;
    if (current.candidateId.isNotEmpty &&
        current.candidateId != GlobalClass.selected_member) {
      cancel();
    }
  }

  void cancel() {
    ++_pollVersion;
    state.value = const DashboardReportState();
  }

  /// Start after the native scanner confirms all ten prints were uploaded.
  /// The backend's isReportGenerated flag is the authoritative ready state.
  void startForCandidate(String candidateId) {
    final id = candidateId.trim();
    if (id.isEmpty || id != GlobalClass.selected_member) return;
    ++_pollVersion;
    final version = _pollVersion;
    state.value = DashboardReportState(
      candidateId: id,
      phase: DashboardReportPhase.waiting,
      message: 'Fingerprints uploaded. Waiting for report generation...',
    );
    unawaited(_pollUntilReady(id, version));
  }

  bool _isCurrent(String id, int version) =>
      version == _pollVersion && GlobalClass.selected_member == id;

  Future<void> _pollUntilReady(String id, int version) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!_isCurrent(id, version)) return;
      if ((UserPref(prefs).getToken() ?? '').isEmpty) {
        state.value = DashboardReportState(
          candidateId: id,
          phase: DashboardReportPhase.failed,
          message: 'Session expired. Please log in again and retry.',
        );
        return;
      }

      while (_isCurrent(id, version)) {
        try {
          final response = await reportService.fetchReportByUserId(
            userDataId: id,
          );
          if (!_isCurrent(id, version)) return;

          if (ReportService.isReportGenerated(response)) {
            // SQLite is updated ONLY after backend confirms generation.
            // An SQLite failure must not discard a confirmed server result.
            try {
              await DatabaseHelper.instance.updateReportGeneratedStatus(id, true);
            } catch (e) {
              debugPrint('Dashboard report SQLite update failed: $e');
            }
            if (!_isCurrent(id, version)) return;
            state.value = DashboardReportState(
              candidateId: id,
              phase: DashboardReportPhase.ready,
              message: 'Report is ready.',
            );
            return;
          }
        } catch (e) {
          // Temporary network/server failures are retried, not treated as ready.
          debugPrint('Dashboard report status retry for $id: $e');
        }
        await Future<void>.delayed(const Duration(seconds: 3));
      }
    } catch (e) {
      if (!_isCurrent(id, version)) return;
      state.value = DashboardReportState(
        candidateId: id,
        phase: DashboardReportPhase.failed,
        message: 'Unable to check report status. Tap Retry.',
      );
      debugPrint('Dashboard report status failed: $e');
    }
  }
}
