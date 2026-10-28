/*
import 'package:daksh/core/Global/global_class.dart';
import 'package:daksh/features/screens/widgets/multipleintellegencehome.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/reportResponse.dart';
import '../../core/network/api_service.dart';
import '../../core/services/ReportService.dart';
import '../../core/services/dashboard_report_status_controller.dart';
import '../../core/storage/user_pref.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/brainDominanceResponse.dart';
import '../../data/models/careerMatchResponse.dart';
import '../../data/models/multipleintellegenceResponse.dart';
import '../../data/models/personalityblenResponse.dart';
import '../../data/models/sensesAnalysisResponse.dart';
import '../../data/models/user_models.dart';
import 'brain_dominance_detail_screen.dart';
import 'multi_intelligence_detail_screen.dart';
import 'personality_detail_screen.dart';
import 'senses_detail_screen.dart';
import 'swot_detail_screen.dart';
import 'widgets/ask_vayo_overlay.dart';

/// Responsive Holistic Report Screen binding candidate & report data dynamically using ReportService endpoints without changing the report view layout.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedMemberName = 'Student';
  User? _selectedCandidateUser;
  ReportModel? _reportModel;
  bool _isLoadingReport = true;
  int _requestVersion = 0;

  PersonalityBlendResponse? _personalityBlend;
  MultipleIntelligenceResponse? _multipleIntelligenceResponse;
  SensesAnalysisResponse? _sensesAnalysis;
  BrainDominanceResponse? _brainDominanceResponse;
  CareerMatchResponse? _careerMatch;

  @override
  void initState() {
    super.initState();
    GlobalClass.selectedMemberNotifier.addListener(_loadReportData);
    DashboardReportStatusController.instance.state
        .addListener(_handleDashboardReportStatus);
    _loadReportData();
  }

  @override
  void dispose() {
    GlobalClass.selectedMemberNotifier.removeListener(_loadReportData);
    DashboardReportStatusController.instance.state
        .removeListener(_handleDashboardReportStatus);
    super.dispose();
  }

  void _handleDashboardReportStatus() {
    if (!mounted) return;
    final flow = DashboardReportStatusController.instance.state.value;
    final id = GlobalClass.selected_member;
    if (id.isEmpty || flow.candidateId != id) return;

    if (flow.waitingFor(id)) {
      ++_requestVersion; // Prevent old network replies from populating the page.
      setState(() {
        _isLoadingReport = false;
        _reportModel = null;
        _personalityBlend = null;
        _multipleIntelligenceResponse = null;
        _sensesAnalysis = null;
        _brainDominanceResponse = null;
        _careerMatch = null;
      });
    } else if (flow.readyFor(id)) {
      // Triggered immediately after the backend reports true.
      _loadReportData();
    } else if (flow.failedFor(id)) {
      setState(() => _isLoadingReport = false);
    }
  }

  Widget _buildDashboardGenerationCard(String id, {String? error}) {
    final waiting = error == null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Column(
        children: [
          if (waiting)
            const CircularProgressIndicator(color: Color(0xFF6366F1))
          else
            const Icon(Icons.error_outline, color: Colors.deepOrange, size: 32),
          const SizedBox(height: 14),
          Text(
            waiting ? 'Generating candidate report...' : 'Report status unavailable',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            waiting
                ? 'All 10 fingerprints uploaded. Checking report status for selected candidate.'
                : (error ?? ''),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          if (!waiting) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => DashboardReportStatusController.instance
                  .startForCandidate(id),
              child: const Text('Retry status check'),
            ),
          ],
        ],
      ),
    );
  }

  double _toPercentage(dynamic val) {
    if (val == null || val is! num) return 0.0;
    final d = val.toDouble();
    return d <= 1.0 ? (d * 100) : d;
  }

  Future<void> loadReportDataAccToCandidateIdAndParams(
    String memberId, int expectedRequestVersion) async {
    final reportService = ReportService();

    final pbFuture = reportService.fetchPersonalityBlend(userDataId: memberId);
    final miFuture = reportService.fetchMultipleIntelligence(userDataId: memberId);
    final saFuture = reportService.fetchSensesAnalysis(userDataId: memberId);
    final bdFuture = reportService.fetchBrainDominance(userDataId: memberId);
    final cmFuture = reportService.fetchCareerMatch(userDataId: memberId);

    final results = await Future.wait([pbFuture, miFuture, saFuture, bdFuture, cmFuture]);

    if (!mounted || expectedRequestVersion != _requestVersion ||
        memberId != GlobalClass.selected_member ||
        DashboardReportStatusController.instance.state.value.waitingFor(memberId)) {
      return;
    }

    setState(() {
      _personalityBlend = results[0] as PersonalityBlendResponse?;
      _multipleIntelligenceResponse = results[1] as MultipleIntelligenceResponse?;
      _sensesAnalysis = results[2] as SensesAnalysisResponse?;
      _brainDominanceResponse = results[3] as BrainDominanceResponse?;
      _careerMatch = results[4] as CareerMatchResponse?;
    });
  }

  Future<void> _loadReportData() async {
    final memberId = GlobalClass.selected_member;
    final requestVersion = ++_requestVersion;
    if (mounted) setState(() {
      _isLoadingReport = true;
      _reportModel = null;
      _personalityBlend = null;
      _multipleIntelligenceResponse = null;
      _sensesAnalysis = null;
      _brainDominanceResponse = null;
      _careerMatch = null;
    });
    debugPrint('ReportScreen: loading report data for memberId="$memberId"');

    // A Dashboard-triggered upload can finish before report generation.
    // Do not request report sections while the backend still says pending.
    if (DashboardReportStatusController.instance.state.value.waitingFor(memberId)) {
      try {
        final candidate = await DatabaseHelper.instance.getMemberById(memberId);
        if (!mounted || requestVersion != _requestVersion ||
            memberId != GlobalClass.selected_member) return;
        setState(() {
          _selectedCandidateUser = candidate;
          _selectedMemberName = candidate == null ? 'Student' : _fullName(candidate);
          _isLoadingReport = false;
        });
      } catch (e) {
        debugPrint('Cannot load candidate while generating report: $e');
        if (mounted && requestVersion == _requestVersion) {
          setState(() => _isLoadingReport = false);
        }
      }
      return;
    }


    if (memberId.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingReport = false;
          _reportModel = null;
          _selectedCandidateUser = null;
          _personalityBlend = null;
          _multipleIntelligenceResponse = null;
          _sensesAnalysis = null;
          _brainDominanceResponse = null;
          _careerMatch = null;
        });
      }
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = UserPref(prefs).getToken() ?? '';

      // 1) Extract candidate User object from local SQLite user_table
      final User? candidateUser =
          await DatabaseHelper.instance.getMemberById(memberId);

      final memberName =
          candidateUser != null ? _fullName(candidateUser) : 'Student';
      // Server is authoritative; SQLite is used only for candidate metadata.
      final status = token.isNotEmpty
          ? await reportService.fetchReportByUserId(userDataId: memberId)
          : null;
      final bool isReportGeneratedInSqlite =
          ReportService.isReportGenerated(status) ||
          DashboardReportStatusController.instance.state.value.readyFor(memberId);

      if (!mounted || requestVersion != _requestVersion || memberId != GlobalClass.selected_member) return;
      setState(() {
        _selectedMemberName = memberName;
        _selectedCandidateUser = candidateUser;
      });

      // 2) Check if isReportGenerated is 0 or 1
      if (!isReportGeneratedInSqlite) {
        if (mounted) {
          setState(() {
            _reportModel = null;
            _isLoadingReport = false;
            _personalityBlend = null;
            _multipleIntelligenceResponse = null;
            _sensesAnalysis = null;
            _brainDominanceResponse = null;
            _careerMatch = null;
          });
        }
        return;
      }

      // 3) If isReportGenerated is 1, fetch report data using param endpoints & full report
      setState(() => _isLoadingReport = true);

      ReportModel? newReport;
      if (token.isNotEmpty) {
        final response = await ApiService().findReportByUserDataId(
          auth: token,
          userDataId: memberId,
        );

        if (response.statusCode == 200 && response.data != null) {
          logFullReportData('ReportScreen findReportByUserDataId ($memberId)', response.data);
          final reportResp = ReportResponse.fromJson(response.data);
          if (reportResp.report.isNotEmpty) {
            newReport = reportResp.report.first;
          }
        }
      }

      // Load parameters in parallel
      await loadReportDataAccToCandidateIdAndParams(memberId, requestVersion);

      if (!mounted || requestVersion != _requestVersion || memberId != GlobalClass.selected_member) return;
      setState(() {
        _reportModel = newReport;
        _isLoadingReport = false;
      });
    } catch (e) {
      debugPrint('Error loading report for selected member: $e');
      if (mounted && requestVersion == _requestVersion) setState(() => _isLoadingReport = false);
    }
  }

  String _fullName(User m) {
    final data = (m.dataName ?? '').trim();
    if (data.isNotEmpty) return data;

    final first = (m.firstName ?? '').trim();
    final last = (m.lastName ?? '').trim();
    final full = [first, last].where((s) => s.isNotEmpty).join(' ');
    return full.isNotEmpty ? full : 'Student';
  }

  void _openMultiIntelligenceDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiIntelligenceHomeDetailScreen(
          multipleIntelligence: _multipleIntelligenceResponse!.report?.multipleIntelligence,
        ),
      ),
    );
  }

  void _openBrainDominanceDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrainDominanceDetailScreen(
          brainDominance: _reportModel?.brainDominance,
        ),
      ),
    );
  }

  void _openSensesDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SensesDetailScreen(
          senses: _reportModel?.senses,
        ),
      ),
    );
  }

  void _openPersonalityDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PersonalityDetailScreen(
          personality: _reportModel?.personality,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;
    final dashboardGeneration = DashboardReportStatusController.instance.state.value;
    final currentCandidateId = GlobalClass.selected_member;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Header Row
                  _buildHeaderRow(context, isNarrow),

                  const SizedBox(height: 14),

                  // 2. Free Tier Preview Active Banner
                  _buildFreeTierBanner(context, isNarrow),

                  const SizedBox(height: 14),

                  // 3. Student Profile Card (Bound to Selected Candidate)
                  _buildStudentProfileCard(context, isNarrow),

                  const SizedBox(height: 14),

                  // 4. Conditional Content based on isReportGenerated status
                  if (dashboardGeneration.waitingFor(currentCandidateId)) ...[
                    _buildDashboardGenerationCard(currentCandidateId),
                    const SizedBox(height: 80),
                  ] else if (dashboardGeneration.failedFor(currentCandidateId)) ...[
                    _buildDashboardGenerationCard(
                      currentCandidateId,
                      error: dashboardGeneration.message,
                    ),
                    const SizedBox(height: 80),
                  ] else if (_isLoadingReport) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          CircularProgressIndicator(
                              color: Color(0xFF6366F1), strokeWidth: 3),
                          SizedBox(height: 18),
                          Text(
                            'Loading Holistic Report...',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 80),
                  ] else if (_reportModel == null &&
                      _personalityBlend == null &&
                      _multipleIntelligenceResponse == null &&
                      _sensesAnalysis == null &&
                      _brainDominanceResponse == null &&
                      _careerMatch == null) ...[
                    // No Report Found / Scan Pending Placeholder View
                    _buildNoReportFoundCard(context, isNarrow),
                    const SizedBox(height: 80),
                  ] else ...[
                    // 8 Multiple Intelligences Card
                    _buildMultipleIntelligencesCard(context, isNarrow),

                    const SizedBox(height: 14),

                    // Brain Dominance Card
                    _buildBrainDominanceCard(context, isNarrow),

                    const SizedBox(height: 14),

                    // 5 Senses Learning Style Card
                    _buildFiveSensesCard(context, isNarrow),

                    const SizedBox(height: 14),

                    // Personality & SWOT Matrix Row/Column
                    _buildPersonalityAndSwotRow(context, isNarrow),

                    const SizedBox(height: 14),

                    // Unlock Personalized Recommendations Banner
                    _buildUnlockRecommendationsBanner(context, isNarrow),

                    const SizedBox(height: 80), // Bottom navigation padding
                  ],
                ],
              ),
            ),

            // Floating Ask Vayo Widget
            */
/*const Positioned(
              right: 12,
              bottom: 16,
              child: AskVayoFloatingWidget(),
            ),*//*

          ],
        ),
      ),
    );
  }

  Widget _buildNoReportFoundCard(BuildContext context, bool isNarrow) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isNarrow ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📄', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No Report Found',
            style: TextStyle(
              fontSize: context.scaleFont(18),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No biometric report has been generated yet for $_selectedMemberName. Please complete the 10-finger scan to generate the certified assessment report.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, bool isNarrow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Holistic Report',
                  style: TextStyle(
                    fontSize: context.scaleFont(22),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Certified Assessment dossier for $_selectedMemberName',
                style: TextStyle(
                  fontSize: context.scaleFont(11),
                  color: AppTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Export (Locked) Button
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 8 : 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 12, color: Color(0xFFD97706)),
              const SizedBox(width: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Export (Locked)',
                  style: TextStyle(
                    fontSize: context.scaleFont(10),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFreeTierBanner(BuildContext context, bool isNarrow) {
    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFAF5FF),
            Color(0xFFFFFBEB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9D5FF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('👑', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Tier Preview Active',
                  style: TextStyle(
                    fontSize: context.scaleFont(12),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF312E81),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Personality Type is 100% unlocked. Full PDF export & multi-intelligence drilldowns lock until Premium.',
                  style: TextStyle(
                    fontSize: context.scaleFont(10.5),
                    color: const Color(0xFF6B21A8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              elevation: 0,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 8 : 12,
                vertical: 6,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Unlock All',
                style: TextStyle(
                  fontSize: context.scaleFont(10.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentProfileCard(BuildContext context, bool isNarrow) {
    final bool isReady = _selectedCandidateUser?.isReportGenerated == true ||
        _reportModel != null ||
        _personalityBlend != null;

    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              */
/*Text(
                'STUDENT PROFILE',
                style: TextStyle(
                  fontSize: context.scaleFont(11),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: const Color(0xFF6366F1),
                ),
              ),*//*

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isReady
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isReady
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Text(
                  _isLoadingReport
                      ? 'Loading Report...'
                      : (isReady
                          ? 'Full Spectrum Validated'
                          : 'Scan Pending ⏳'),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isReady
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF08A).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('👦', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedMemberName,
                      style: TextStyle(
                        fontSize: context.scaleFont(15),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedCandidateUser?.studdingClass != null
                          ? 'Grade: ${_selectedCandidateUser!.studdingClass}'
                          : 'Grade unavailable',
                      style: TextStyle(
                        fontSize: context.scaleFont(11),
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Candidate report overview',
                      style: TextStyle(
                        fontSize: context.scaleFont(10.5),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4338CA),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleIntelligencesCard(BuildContext context, bool isNarrow) {
    final dynamic miData = _reportModel?.multipleIntelligence;

    final kScore = _toPercentage(miData?.kinesthetic?.self ?? 0.0);
    final lScore = _toPercentage(miData?.linguistic?.self ?? 0.0);
    final iScore = _toPercentage(miData?.interpersonal?.self ?? 0.0);
    final mScore = _toPercentage(miData?.logicalMathematical?.self ?? 0.0);

    return InkWell(
      onTap: () => _openMultiIntelligenceDetail(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.diamond_outlined, color: Color(0xFF0284C7), size: 16),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '8 Multiple Intelligences',
                      style: TextStyle(
                        fontSize: context.scaleFont(12.5),
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Preview Wheel',
                        style: TextStyle(
                          fontSize: context.scaleFont(10),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.lock_rounded, size: 11, color: Color(0xFFD97706)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            _buildIntelligenceProgressRow('Bodily Kinesthetic', kScore / 100.0, '${kScore.toStringAsFixed(0)}%', const Color(0xFFF59E0B)),
            const SizedBox(height: 10),
            _buildIntelligenceProgressRow('Linguistic Intelligence', lScore / 100.0, '${lScore.toStringAsFixed(0)}%', const Color(0xFF8B5CF6)),
            const SizedBox(height: 10),
            _buildIntelligenceProgressRow('Interpersonal Intelligence', iScore / 100.0, '${iScore.toStringAsFixed(0)}%', const Color(0xFF0D9488)),
            const SizedBox(height: 10),
            _buildIntelligenceProgressRow('Logical-Mathematical Intelli...', mScore / 100.0, '${mScore.toStringAsFixed(0)}%', const Color(0xFFF43F5E)),
          ],
        ),
      ),
    );
  }

  Widget _buildIntelligenceProgressRow(
    String title,
    double progress,
    String percentage,
    Color color,
  ) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildBrainDominanceCard(BuildContext context, bool isNarrow) {
    final dynamic bdData = _reportModel?.brainDominance;

    final rightBrain = _toPercentage(bdData?.rightBrain ?? 0.62);
    final leftBrain = _toPercentage(bdData?.leftBrain ?? 0.38);

    return InkWell(
      onTap: () => _openBrainDominanceDetail(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('🔮', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Brain Dominance',
                        style: TextStyle(
                          fontSize: context.scaleFont(13),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      _buildLockedTag(),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Right Brain Dominant (${rightBrain.toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontSize: context.scaleFont(11.5),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                  Text(
                    'Left Brain: ${leftBrain.toStringAsFixed(0)}% Analytical',
                    style: TextStyle(
                      fontSize: context.scaleFont(10.5),
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildFiveSensesCard(BuildContext context, bool isNarrow) {
    final dynamic sensesData =  _reportModel?.senses;

    final vision = _toPercentage(sensesData?.see ?? 0.88);
    final touch = _toPercentage(sensesData?.touch ?? 0.82);

    return InkWell(
      onTap: () => _openSensesDetail(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('👁️', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '5 Senses Learning Style',
                        style: TextStyle(
                          fontSize: context.scaleFont(13),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      _buildLockedTag(),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Vision (${vision.toStringAsFixed(0)}%) & Touch (${touch.toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontSize: context.scaleFont(11.5),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D9488),
                    ),
                  ),
                  Text(
                    'High hands-on tactile & spatial absorption',
                    style: TextStyle(
                      fontSize: context.scaleFont(10.5),
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityAndSwotRow(BuildContext context, bool isNarrow) {
    if (isNarrow) {
      return Column(
        children: [
          _buildPersonalityCard(context, isNarrow),
          const SizedBox(height: 10),
          _buildSwotCard(context, isNarrow),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildPersonalityCard(context, isNarrow)),
        const SizedBox(width: 10),
        Expanded(child: _buildSwotCard(context, isNarrow)),
      ],
    );
  }

  Widget _buildPersonalityCard(BuildContext context, bool isNarrow) {
    final dynamic personalityData = _reportModel?.personality;

    final primary = (personalityData?.primary is String && (personalityData?.primary as String).isNotEmpty)
        ? personalityData.primary as String
        : '';
    final secondary = (personalityData?.secondary is String && (personalityData?.secondary as String).isNotEmpty)
        ? personalityData.secondary as String
        : '';

    return InkWell(
      onTap: () => {},
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('🎯', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 4),
                    Text(
                      'Personality',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
                */
/*Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'FREE PASS ✨',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),*//*

              ],
            ),
            const SizedBox(height: 6),
            Text(
              primary,
              style: TextStyle(
                fontSize: context.scaleFont(11.5),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              secondary,
              style: TextStyle(
                fontSize: context.scaleFont(10.5),
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwotCard(BuildContext context, bool isNarrow) {
   // final personality = _personalityBlend?.report?.personality;
    final primary = _reportModel?.personality?.primary .trim()??"";
    final secondary = _reportModel?.personality?.secondary .trim()??"";
    return InkWell(
      onTap: primary.isEmpty ? null : () {
        Navigator.push(context, MaterialPageRoute(builder: (_) =>
          SwotDetailScreen(primary: primary, secondary: secondary)));
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('🛡️', style: TextStyle(fontSize: 13)),
                SizedBox(width: 4),
                Text(
                  'SWOT Matrix',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              primary.isEmpty ? 'SWOT unavailable' : 'Primary: $primary',
              style: TextStyle(
                fontSize: context.scaleFont(11.5),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              secondary.isEmpty ? 'Secondary: Not available' : 'Secondary: $secondary',
              style: TextStyle(
                fontSize: context.scaleFont(10.5),
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockRecommendationsBanner(BuildContext context, bool isNarrow) {
    final primary = _reportModel?.personality?.primary.trim() ?? "";
    final secondary = _reportModel?.personality?.secondary.trim() ?? "";
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SwotDetailScreen(
              primary: primary,
              secondary: secondary,
              initialShowRecommendations: true,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 12 : 16,
          vertical: isNarrow ? 12 : 14,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFEA580C),
              Color(0xFF7C3AED),
              Color(0xFF2563EB),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEA580C).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_rounded, size: 14, color: Color(0xFFFEF08A)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Unlock Personalized Recommendations 👑',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.scaleFont(11.5),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.lock_rounded, size: 9, color: Color(0xFFD97706)),
          SizedBox(width: 2),
          Text(
            'Locked',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD97706),
            ),
          ),
        ],
      ),
    );
  }
}
*/
import 'package:daksh/core/Global/global_class.dart';
import 'package:daksh/features/screens/widgets/multipleintellegencehome.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/database/database_helper.dart';
import '../../core/models/reportResponse.dart';
import '../../core/network/api_service.dart';
import '../../core/services/ReportService.dart';
import '../../core/services/dashboard_report_status_controller.dart';
import '../../core/storage/user_pref.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/brainDominanceResponse.dart';
import '../../data/models/careerMatchResponse.dart';
import '../../data/models/multipleintellegenceResponse.dart';
import '../../data/models/personalityblenResponse.dart';
import '../../data/models/sensesAnalysisResponse.dart';
import '../../data/models/user_models.dart';
import 'brain_dominance_detail_screen.dart';
import 'multi_intelligence_detail_screen.dart';
import 'personality_detail_screen.dart';
import 'senses_detail_screen.dart';
import 'swot_detail_screen.dart';
import 'widgets/ask_vayo_overlay.dart';

/// Responsive Holistic Report Screen binding candidate & report data dynamically using ReportService endpoints without changing the report view layout.
class ReportScreen extends StatefulWidget {
  const ReportScreen({super.key});

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  String _selectedMemberName = 'Student';
  User? _selectedCandidateUser;
  ReportModel? _reportModel;
  bool _isLoadingReport = true;
  int _requestVersion = 0;

  PersonalityBlendResponse? _personalityBlend;
  MultipleIntelligenceResponse? _multipleIntelligenceResponse;
  SensesAnalysisResponse? _sensesAnalysis;
  BrainDominanceResponse? _brainDominanceResponse;
  CareerMatchResponse? _careerMatch;

  @override
  void initState() {
    super.initState();
    GlobalClass.selectedMemberNotifier.addListener(_loadReportData);
    DashboardReportStatusController.instance.state
        .addListener(_handleDashboardReportStatus);
    _loadReportData();
  }

  @override
  void dispose() {
    GlobalClass.selectedMemberNotifier.removeListener(_loadReportData);
    DashboardReportStatusController.instance.state
        .removeListener(_handleDashboardReportStatus);
    super.dispose();
  }

  void _handleDashboardReportStatus() {
    if (!mounted) return;
    final flow = DashboardReportStatusController.instance.state.value;
    final id = GlobalClass.selected_member;
    if (id.isEmpty || flow.candidateId != id) return;

    if (flow.waitingFor(id)) {
      ++_requestVersion; // Prevent old network replies from populating the page.
      setState(() {
        _isLoadingReport = false;
        _reportModel = null;
        _personalityBlend = null;
        _multipleIntelligenceResponse = null;
        _sensesAnalysis = null;
        _brainDominanceResponse = null;
        _careerMatch = null;
      });
    } else if (flow.readyFor(id)) {
      // Triggered immediately after the backend reports true.
      _loadReportData();
    } else if (flow.failedFor(id)) {
      setState(() => _isLoadingReport = false);
    }
  }

  Widget _buildDashboardGenerationCard(String id, {String? error}) {
    final waiting = error == null;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFC7D2FE)),
      ),
      child: Column(
        children: [
          if (waiting)
            const CircularProgressIndicator(color: Color(0xFF6366F1))
          else
            const Icon(Icons.error_outline, color: Colors.deepOrange, size: 32),
          const SizedBox(height: 14),
          Text(
            waiting ? 'Generating candidate report...' : 'Report status unavailable',
            textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            waiting
                ? 'All 10 fingerprints uploaded. Checking report status for selected candidate.'
                : (error ?? ''),
            textAlign: TextAlign.center,
            style: const TextStyle(color: Color(0xFF64748B)),
          ),
          if (!waiting) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => DashboardReportStatusController.instance
                  .startForCandidate(id),
              child: const Text('Retry status check'),
            ),
          ],
        ],
      ),
    );
  }

  double _toPercentage(dynamic val) {
    if (val == null || val is! num) return 0.0;
    final d = val.toDouble();
    return d <= 1.0 ? (d * 100) : d;
  }

  Future<void> loadReportDataAccToCandidateIdAndParams(
      String memberId, int expectedRequestVersion) async {
    final reportService = ReportService();

    final pbFuture = reportService.fetchPersonalityBlend(userDataId: memberId);
    final miFuture = reportService.fetchMultipleIntelligence(userDataId: memberId);
    final saFuture = reportService.fetchSensesAnalysis(userDataId: memberId);
    final bdFuture = reportService.fetchBrainDominance(userDataId: memberId);
    final cmFuture = reportService.fetchCareerMatch(userDataId: memberId);

    final results = await Future.wait([pbFuture, miFuture, saFuture, bdFuture, cmFuture]);

    if (!mounted || expectedRequestVersion != _requestVersion ||
        memberId != GlobalClass.selected_member ||
        DashboardReportStatusController.instance.state.value.waitingFor(memberId)) {
      return;
    }

    setState(() {
      _personalityBlend = results[0] as PersonalityBlendResponse?;
      _multipleIntelligenceResponse = results[1] as MultipleIntelligenceResponse?;
      _sensesAnalysis = results[2] as SensesAnalysisResponse?;
      _brainDominanceResponse = results[3] as BrainDominanceResponse?;
      _careerMatch = results[4] as CareerMatchResponse?;
    });
  }

  /// Checks whether the report is generated for THIS selected member id.
  /// Server is authoritative; the Dashboard upload flow can also mark it ready.
  /// Used by both the first load and pull-to-refresh (both go through
  /// `_loadReportData`).
  Future<bool> _isReportGeneratedForMember(String memberId, String token) async {
    if (memberId.isEmpty) return false;

    final status = token.isNotEmpty
        ? await reportService.fetchReportByUserId(userDataId: memberId)
        : null;

    final generated = ReportService.isReportGenerated(status) ||
        DashboardReportStatusController.instance.state.value.readyFor(memberId);

    debugPrint('ReportScreen: isReportGenerated for "$memberId" = $generated');
    return generated;
  }

  Future<void> _loadReportData() async {
    final memberId = GlobalClass.selected_member;
    final requestVersion = ++_requestVersion;
    if (mounted) setState(() {
      _isLoadingReport = true;
      _reportModel = null;
      _personalityBlend = null;
      _multipleIntelligenceResponse = null;
      _sensesAnalysis = null;
      _brainDominanceResponse = null;
      _careerMatch = null;
    });
    debugPrint('ReportScreen: loading report data for memberId="$memberId"');

    // A Dashboard-triggered upload can finish before report generation.
    // Do not request report sections while the backend still says pending.
    if (DashboardReportStatusController.instance.state.value.waitingFor(memberId)) {
      try {
        final candidate = await DatabaseHelper.instance.getMemberById(memberId);
        if (!mounted || requestVersion != _requestVersion ||
            memberId != GlobalClass.selected_member) return;
        setState(() {
          _selectedCandidateUser = candidate;
          _selectedMemberName = candidate == null ? 'Student' : _fullName(candidate);
          _isLoadingReport = false;
        });
      } catch (e) {
        debugPrint('Cannot load candidate while generating report: $e');
        if (mounted && requestVersion == _requestVersion) {
          setState(() => _isLoadingReport = false);
        }
      }
      return;
    }


    if (memberId.isEmpty) {
      if (mounted) {
        setState(() {
          _isLoadingReport = false;
          _reportModel = null;
          _selectedCandidateUser = null;
          _personalityBlend = null;
          _multipleIntelligenceResponse = null;
          _sensesAnalysis = null;
          _brainDominanceResponse = null;
          _careerMatch = null;
        });
      }
      return;
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = UserPref(prefs).getToken() ?? '';

      // 1) Extract candidate User object from local SQLite user_table
      final User? candidateUser =
      await DatabaseHelper.instance.getMemberById(memberId);

      final memberName =
      candidateUser != null ? _fullName(candidateUser) : 'Student';

      // 2) Check if the report is generated for THIS selected member id
      final bool isReportGenerated =
      await _isReportGeneratedForMember(memberId, token);

      if (!mounted || requestVersion != _requestVersion || memberId != GlobalClass.selected_member) return;
      setState(() {
        _selectedMemberName = memberName;
        _selectedCandidateUser = candidateUser;
      });

      // Not generated for this id -> show "No Report Found" and stop
      if (!isReportGenerated) {
        if (mounted) {
          setState(() {
            _reportModel = null;
            _isLoadingReport = false;
            _personalityBlend = null;
            _multipleIntelligenceResponse = null;
            _sensesAnalysis = null;
            _brainDominanceResponse = null;
            _careerMatch = null;
          });
        }
        return;
      }

      // 3) If generated, fetch report data using param endpoints & full report
      setState(() => _isLoadingReport = true);

      ReportModel? newReport;
      if (token.isNotEmpty) {
        final response = await ApiService().findReportByUserDataId(
          auth: token,
          userDataId: memberId,
        );

        if (response.statusCode == 200 && response.data != null) {
          logFullReportData('ReportScreen findReportByUserDataId ($memberId)', response.data);
          final reportResp = ReportResponse.fromJson(response.data);
          if (reportResp.report.isNotEmpty) {
            newReport = reportResp.report.first;
          }
        }
      }

      // Load parameters in parallel
      await loadReportDataAccToCandidateIdAndParams(memberId, requestVersion);

      if (!mounted || requestVersion != _requestVersion || memberId != GlobalClass.selected_member) return;
      setState(() {
        _reportModel = newReport;
        _isLoadingReport = false;
      });
    } catch (e) {
      debugPrint('Error loading report for selected member: $e');
      if (mounted && requestVersion == _requestVersion) setState(() => _isLoadingReport = false);
    }
  }

  String _fullName(User m) {
    final data = (m.dataName ?? '').trim();
    if (data.isNotEmpty) return data;

    final first = (m.firstName ?? '').trim();
    final last = (m.lastName ?? '').trim();
    final full = [first, last].where((s) => s.isNotEmpty).join(' ');
    return full.isNotEmpty ? full : 'Student';
  }

  void _openMultiIntelligenceDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiIntelligenceHomeDetailScreen(
          multipleIntelligence: _multipleIntelligenceResponse!.report?.multipleIntelligence,
        ),
      ),
    );
  }

  void _openBrainDominanceDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrainDominanceDetailScreen(
          brainDominance: _reportModel?.brainDominance,
        ),
      ),
    );
  }

  void _openSensesDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SensesDetailScreen(
          senses: _reportModel?.senses,
        ),
      ),
    );
  }

  void _openPersonalityDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => PersonalityDetailScreen(
        /*  personality: _reportModel?.personality,*/
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;
    final dashboardGeneration = DashboardReportStatusController.instance.state.value;
    final currentCandidateId = GlobalClass.selected_member;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Stack(
          children: [
            RefreshIndicator(
              color: const Color(0xFF6366F1),
              // Re-checks report status for the selected id, then reloads
              onRefresh: _loadReportData,
              child: SingleChildScrollView(
                // AlwaysScrollable so pull-to-refresh works on short content too
                physics: const AlwaysScrollableScrollPhysics(
                  parent: BouncingScrollPhysics(),
                ),
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Header Row
                    _buildHeaderRow(context, isNarrow),

                    const SizedBox(height: 14),

                    // 2. Free Tier Preview Active Banner
                    _buildFreeTierBanner(context, isNarrow),

                    const SizedBox(height: 14),

                    // 3. Student Profile Card (Bound to Selected Candidate)
                    _buildStudentProfileCard(context, isNarrow),

                    const SizedBox(height: 14),

                    // 4. Conditional Content based on isReportGenerated status
                    if (dashboardGeneration.waitingFor(currentCandidateId)) ...[
                      _buildDashboardGenerationCard(currentCandidateId),
                      const SizedBox(height: 80),
                    ] else if (dashboardGeneration.failedFor(currentCandidateId)) ...[
                      _buildDashboardGenerationCard(
                        currentCandidateId,
                        error: dashboardGeneration.message,
                      ),
                      const SizedBox(height: 80),
                    ] else if (_isLoadingReport) ...[
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(32),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          border: Border.all(color: const Color(0xFFE2E8F0)),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            CircularProgressIndicator(
                                color: Color(0xFF6366F1), strokeWidth: 3),
                            SizedBox(height: 18),
                            Text(
                              'Loading Holistic Report...',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 80),
                    ] else if (_reportModel == null &&
                        _personalityBlend == null &&
                        _multipleIntelligenceResponse == null &&
                        _sensesAnalysis == null &&
                        _brainDominanceResponse == null &&
                        _careerMatch == null) ...[
                      // No Report Found / Scan Pending Placeholder View
                      _buildNoReportFoundCard(context, isNarrow),
                      const SizedBox(height: 80),
                    ] else ...[
                      // 8 Multiple Intelligences Card
                      _buildMultipleIntelligencesCard(context, isNarrow),

                      const SizedBox(height: 14),

                      // Brain Dominance Card
                      _buildBrainDominanceCard(context, isNarrow),

                      const SizedBox(height: 14),

                      // 5 Senses Learning Style Card
                      _buildFiveSensesCard(context, isNarrow),

                      const SizedBox(height: 14),

                      // Personality & SWOT Matrix Row/Column
                      _buildPersonalityAndSwotRow(context, isNarrow),

                      const SizedBox(height: 14),

                      // Unlock Personalized Recommendations Banner
                      _buildUnlockRecommendationsBanner(context, isNarrow),

                      const SizedBox(height: 80), // Bottom navigation padding
                    ],
                  ],
                ),
              ),
            ),

            // Floating Ask Vayo Widget
            /*const Positioned(
              right: 12,
              bottom: 16,
              child: AskVayoFloatingWidget(),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildNoReportFoundCard(BuildContext context, bool isNarrow) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isNarrow ? 20 : 28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 14,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 72,
            height: 72,
            decoration: const BoxDecoration(
              color: Color(0xFFFEF3C7),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('📄', style: TextStyle(fontSize: 36)),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'No Report Found',
            style: TextStyle(
              fontSize: context.scaleFont(18),
              fontWeight: FontWeight.w800,
              color: const Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'No biometric report has been generated yet for $_selectedMemberName. Please complete the 10-finger scan to generate the certified assessment report.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12.5,
              color: Color(0xFF64748B),
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, bool isNarrow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  'Holistic Report',
                  style: TextStyle(
                    fontSize: context.scaleFont(22),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Certified Assessment dossier for $_selectedMemberName',
                style: TextStyle(
                  fontSize: context.scaleFont(11),
                  color: AppTheme.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Export (Locked) Button
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: isNarrow ? 8 : 12,
            vertical: 6,
          ),
          decoration: BoxDecoration(
            color: const Color(0xFFFFFBEB),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 12, color: Color(0xFFD97706)),
              const SizedBox(width: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'Export (Locked)',
                  style: TextStyle(
                    fontSize: context.scaleFont(10),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFFB45309),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildFreeTierBanner(BuildContext context, bool isNarrow) {
    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : 14),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFFAF5FF),
            Color(0xFFFFFBEB),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE9D5FF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF7C3AED).withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('👑', style: TextStyle(fontSize: 22)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Tier Preview Active',
                  style: TextStyle(
                    fontSize: context.scaleFont(12),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF312E81),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Personality Type is 100% unlocked. Full PDF export & multi-intelligence drilldowns lock until Premium.',
                  style: TextStyle(
                    fontSize: context.scaleFont(10.5),
                    color: const Color(0xFF6B21A8),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 6),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4F46E5),
              foregroundColor: Colors.white,
              elevation: 0,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 8 : 12,
                vertical: 6,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Unlock All',
                style: TextStyle(
                  fontSize: context.scaleFont(10.5),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentProfileCard(BuildContext context, bool isNarrow) {
    final bool isReady = _selectedCandidateUser?.isReportGenerated == true ||
        _reportModel != null ||
        _personalityBlend != null;

    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 6,
            runSpacing: 4,
            children: [
              /*Text(
                'STUDENT PROFILE',
                style: TextStyle(
                  fontSize: context.scaleFont(11),
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.5,
                  color: const Color(0xFF6366F1),
                ),
              ),*/
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isReady
                      ? const Color(0xFFECFDF5)
                      : const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isReady
                        ? const Color(0xFFA7F3D0)
                        : const Color(0xFFFDE68A),
                  ),
                ),
                child: Text(
                  _isLoadingReport
                      ? 'Loading Report...'
                      : (isReady
                      ? 'Full Spectrum Validated'
                      : 'Scan Pending ⏳'),
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: isReady
                        ? const Color(0xFF059669)
                        : const Color(0xFFD97706),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF08A).withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Center(
                  child: Text('👦', style: TextStyle(fontSize: 24)),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _selectedMemberName,
                      style: TextStyle(
                        fontSize: context.scaleFont(15),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _selectedCandidateUser?.studdingClass != null
                          ? 'Grade: ${_selectedCandidateUser!.studdingClass}'
                          : 'Grade unavailable',
                      style: TextStyle(
                        fontSize: context.scaleFont(11),
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'Candidate report overview',
                      style: TextStyle(
                        fontSize: context.scaleFont(10.5),
                        fontWeight: FontWeight.bold,
                        color: const Color(0xFF4338CA),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMultipleIntelligencesCard(BuildContext context, bool isNarrow) {
    final dynamic miData = _reportModel?.multipleIntelligence;

    final kScore = _toPercentage(miData?.kinesthetic?.self ?? 0.0);
    final lScore = _toPercentage(miData?.linguistic?.self ?? 0.0);
    final iScore = _toPercentage(miData?.interpersonal?.self ?? 0.0);
    final mScore = _toPercentage(miData?.logicalMathematical?.self ?? 0.0);

    return InkWell(
      onTap: () => _openMultiIntelligenceDetail(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Center(
                    child: Icon(Icons.diamond_outlined, color: Color(0xFF0284C7), size: 16),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      '8 Multiple Intelligences',
                      style: TextStyle(
                        fontSize: context.scaleFont(12.5),
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        'Preview Wheel',
                        style: TextStyle(
                          fontSize: context.scaleFont(10),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ),
                    const SizedBox(width: 2),
                    const Icon(Icons.lock_rounded, size: 11, color: Color(0xFFD97706)),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 14),

            _buildIntelligenceProgressRow('Bodily Kinesthetic', kScore / 100.0, '${kScore.toStringAsFixed(0)}%', const Color(0xFFF59E0B)),
            const SizedBox(height: 10),
            _buildIntelligenceProgressRow('Linguistic Intelligence', lScore / 100.0, '${lScore.toStringAsFixed(0)}%', const Color(0xFF8B5CF6)),
            const SizedBox(height: 10),
            _buildIntelligenceProgressRow('Interpersonal Intelligence', iScore / 100.0, '${iScore.toStringAsFixed(0)}%', const Color(0xFF0D9488)),
            const SizedBox(height: 10),
            _buildIntelligenceProgressRow('Logical-Mathematical Intelli...', mScore / 100.0, '${mScore.toStringAsFixed(0)}%', const Color(0xFFF43F5E)),
          ],
        ),
      ),
    );
  }

  Widget _buildIntelligenceProgressRow(
      String title,
      double progress,
      String percentage,
      Color color,
      ) {
    return Row(
      children: [
        Expanded(
          flex: 5,
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Color(0xFF334155),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          flex: 4,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 7,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          percentage,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  Widget _buildBrainDominanceCard(BuildContext context, bool isNarrow) {
    final dynamic bdData = _reportModel?.brainDominance;

    final rightBrain = _toPercentage(bdData?.rightBrain ?? 0.62);
    final leftBrain = _toPercentage(bdData?.leftBrain ?? 0.38);

    return InkWell(
      onTap: () => _openBrainDominanceDetail(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFF3E8FF),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('🔮', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        'Brain Dominance',
                        style: TextStyle(
                          fontSize: context.scaleFont(13),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      _buildLockedTag(),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Right Brain Dominant (${rightBrain.toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontSize: context.scaleFont(11.5),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF6366F1),
                    ),
                  ),
                  Text(
                    'Left Brain: ${leftBrain.toStringAsFixed(0)}% Analytical',
                    style: TextStyle(
                      fontSize: context.scaleFont(10.5),
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildFiveSensesCard(BuildContext context, bool isNarrow) {
    final dynamic sensesData =  _reportModel?.senses;

    final vision = _toPercentage(sensesData?.see ?? 0.88);
    final touch = _toPercentage(sensesData?.touch ?? 0.82);

    return InkWell(
      onTap: () => _openSensesDetail(context),
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: const Color(0xFFECFDF5),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Center(
                child: Text('👁️', style: TextStyle(fontSize: 20)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 4,
                    runSpacing: 2,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '5 Senses Learning Style',
                        style: TextStyle(
                          fontSize: context.scaleFont(13),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      _buildLockedTag(),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Vision (${vision.toStringAsFixed(0)}%) & Touch (${touch.toStringAsFixed(0)}%)',
                    style: TextStyle(
                      fontSize: context.scaleFont(11.5),
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF0D9488),
                    ),
                  ),
                  Text(
                    'High hands-on tactile & spatial absorption',
                    style: TextStyle(
                      fontSize: context.scaleFont(10.5),
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 4),
            const Icon(Icons.arrow_forward_rounded, size: 16, color: Color(0xFF94A3B8)),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalityAndSwotRow(BuildContext context, bool isNarrow) {
    if (isNarrow) {
      return Column(
        children: [
          _buildPersonalityCard(context, isNarrow),
          const SizedBox(height: 10),
          _buildSwotCard(context, isNarrow),
        ],
      );
    }

    return Row(
      children: [
        Expanded(child: _buildPersonalityCard(context, isNarrow)),
        const SizedBox(width: 10),
        Expanded(child: _buildSwotCard(context, isNarrow)),
      ],
    );
  }

  Widget _buildPersonalityCard(BuildContext context, bool isNarrow) {
    final dynamic personalityData = _reportModel?.personality;

    final primary = (personalityData?.primary is String && (personalityData?.primary as String).isNotEmpty)
        ? personalityData.primary as String
        : '';
    final secondary = (personalityData?.secondary is String && (personalityData?.secondary as String).isNotEmpty)
        ? personalityData.secondary as String
        : '';

    return InkWell(
      onTap: () => {},
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              alignment: WrapAlignment.spaceBetween,
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: 4,
              runSpacing: 4,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Text('🎯', style: TextStyle(fontSize: 13)),
                    SizedBox(width: 4),
                    Text(
                      'Personality',
                      style: TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF7C3AED),
                      ),
                    ),
                  ],
                ),
                /*Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'FREE PASS ✨',
                    style: TextStyle(
                      fontSize: 8,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF059669),
                    ),
                  ),
                ),*/
              ],
            ),
            const SizedBox(height: 6),
            Text(
              primary,
              style: TextStyle(
                fontSize: context.scaleFont(11.5),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              secondary,
              style: TextStyle(
                fontSize: context.scaleFont(10.5),
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSwotCard(BuildContext context, bool isNarrow) {
    // final personality = _personalityBlend?.report?.personality;
    final primary = _reportModel?.personality?.primary .trim()??"";
    final secondary = _reportModel?.personality?.secondary .trim()??"";
    return InkWell(
      onTap: primary.isEmpty ? null : () {
        Navigator.push(context, MaterialPageRoute(builder: (_) =>
            SwotDetailScreen(primary: primary, secondary: secondary)));
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: EdgeInsets.all(isNarrow ? 12 : 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Text('🛡️', style: TextStyle(fontSize: 13)),
                SizedBox(width: 4),
                Text(
                  'SWOT Matrix',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD97706),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              primary.isEmpty ? 'SWOT unavailable' : 'Primary: $primary',
              style: TextStyle(
                fontSize: context.scaleFont(11.5),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF0F172A),
              ),
            ),
            Text(
              secondary.isEmpty ? 'Secondary: Not available' : 'Secondary: $secondary',
              style: TextStyle(
                fontSize: context.scaleFont(10.5),
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockRecommendationsBanner(BuildContext context, bool isNarrow) {
    final primary = _reportModel?.personality?.primary.trim() ?? "";
    final secondary = _reportModel?.personality?.secondary.trim() ?? "";
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SwotDetailScreen(
              primary: primary,
              secondary: secondary,
              initialShowRecommendations: true,
            ),
          ),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(
          horizontal: isNarrow ? 12 : 16,
          vertical: isNarrow ? 12 : 14,
        ),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [
              Color(0xFFEA580C),
              Color(0xFF7C3AED),
              Color(0xFF2563EB),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFEA580C).withValues(alpha: 0.3),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_rounded, size: 14, color: Color(0xFFFEF08A)),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                'Unlock Personalized Recommendations 👑',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: context.scaleFont(11.5),
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLockedTag() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.lock_rounded, size: 9, color: Color(0xFFD97706)),
          SizedBox(width: 2),
          Text(
            'Locked',
            style: TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD97706),
            ),
          ),
        ],
      ),
    );
  }
}