import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/Global/global_class.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/models/intelligence_models.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/ReportService.dart';
import '../../../core/services/dashboard_report_status_controller.dart';
import '../../../core/services/finger_channel.dart';
import '../../../core/services/homedataPreloader.dart';
import '../../../core/models/reportResponse.dart';
import '../../../core/network/api_service.dart';
import '../../../core/storage/app_pref.dart';
import '../../../core/storage/user_pref.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/user_models.dart';
import '../../../shared/widgets/add_family_member_dialog.dart';
import '../ai_counselor_screen.dart';
import '../brain_dominance_detail_screen.dart';
import '../dmit_protocol_intro_screen.dart';

import '';
import '../multi_intelligence_detail_screen.dart';
import '../personality_detail_screen.dart';
import '../senses_detail_screen.dart';
import '../swot_detail_screen.dart';
import 'dpdp_privacy_screen.dart';
import 'upgrade_plan_modal.dart';

class DakshIntelligenceDrawer extends StatefulWidget {
  const DakshIntelligenceDrawer({super.key});

  @override
  State<DakshIntelligenceDrawer> createState() =>
      _DakshIntelligenceDrawerState();
}

class _DakshIntelligenceDrawerState extends State<DakshIntelligenceDrawer> {
  String _adminName = '';
  String _adminEmail = '';
  List<User> _candidateMembers = [];
  int _selectedMemberIndex = 0;

  @override
  void initState() {
    super.initState();
    GlobalClass.selectedMemberNotifier.addListener(_selectedChanged);
    DashboardReportStatusController.instance.state.addListener(_onDashboardReportStatus);
    //_loadAdminDataFromLocal();
    _loadAdminAndCandidates();
  }

  void _selectedChanged() {
    if (!mounted) return;
    final idx = _candidateMembers.indexWhere((e) => e.id == GlobalClass.selected_member);
    if (idx >= 0) setState(() => _selectedMemberIndex = idx);
  }

  void _onDashboardReportStatus() {
    if (!mounted) return;
    final flow = DashboardReportStatusController.instance.state.value;
    if (flow.candidateId != GlobalClass.selected_member) return;
    if (flow.readyFor(flow.candidateId)) {
      _loadAdminAndCandidates();
    } else {
      setState(() {}); // Hide older ready flag during a new scan.
    }
  }

  @override
  void dispose() {
    GlobalClass.selectedMemberNotifier.removeListener(_selectedChanged);
    DashboardReportStatusController.instance.state.removeListener(_onDashboardReportStatus);
    super.dispose();
  }

  Future<void> _loadAdminAndCandidates() async {
    try {
      final sqliteAdmin = await DatabaseHelper.instance.getAdminData();
      final sqliteCandidates = await DatabaseHelper.instance.getCandidateMembers();

      if (mounted) {
        setState(() {
          if (sqliteAdmin != null) {
            final fName = sqliteAdmin.firstName ?? '';
            final lName = sqliteAdmin.lastName ?? '';
            final full = '$fName $lName'.trim();
            if (full.isNotEmpty) _adminName = full;
            if (sqliteAdmin.email != null && sqliteAdmin.email!.isNotEmpty) {
              _adminEmail = sqliteAdmin.email!;
            }
          }
          if (sqliteCandidates.isNotEmpty) {
            _candidateMembers = sqliteCandidates;
            final currentSelectedId = GlobalClass.selected_member;
            final idx = _candidateMembers.indexWhere((u) => u.id == currentSelectedId);
            _selectedMemberIndex = idx >= 0 ? idx : 0;
          }
        });
      }
    } catch (e) {
      debugPrint('Error loading drawer user data: $e');
    }
  }

  User? get _selectedCandidateUser {
    if (_candidateMembers.isNotEmpty &&
        _selectedMemberIndex < _candidateMembers.length) {
      return _candidateMembers[_selectedMemberIndex];
    }
    return null;
  }

  String get _activeMemberName {
    final candidate = _selectedCandidateUser;
    if (candidate != null) {
      return (candidate.dataName != null && candidate.dataName!.isNotEmpty)
          ? candidate.dataName!
          : (candidate.firstName != null && candidate.firstName!.isNotEmpty)
              ? candidate.firstName!
              : _adminName;
    }
    return _adminName;
  }

  String get _activeMemberContact {
    final candidate = _selectedCandidateUser;
    if (candidate != null) {
      if (candidate.mobile != null && candidate.mobile!.isNotEmpty) {
        return candidate.mobile!;
      }
      if (candidate.email != null && candidate.email!.isNotEmpty) {
        return candidate.email!;
      }
    }
    return _adminEmail;
  }

  String get _activeMemberClass {
    final candidate = _selectedCandidateUser;
    if (candidate != null &&
        candidate.studdingClass != null &&
        candidate.studdingClass!.isNotEmpty) {
      return candidate.studdingClass!;
    }
    return '';
  }

  bool get _activeMemberReportReady {
    final id = GlobalClass.selected_member;
    final flow = DashboardReportStatusController.instance.state.value;
    if (flow.waitingFor(id)) return false;
    if (flow.readyFor(id)) return true;
    return _selectedCandidateUser?.isReportGenerated == true;
  }

  void _navigateToScreen(Widget screen) {
    Navigator.pop(context); // Close Drawer
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
  }

  Future<void> _openAssessmentScreen(String type) async {
    final candidateId = GlobalClass.selected_member;
    if (DashboardReportStatusController.instance.state.value.waitingFor(candidateId)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Report is being generated. Please wait for the status to finish.')),
      );
      return;
    }
    if (candidateId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a candidate first.')));
      return;
    }
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );
    Widget? destination;
    try {
      // Read the currently selected candidate's actual report from the backend.
      final prefs = await SharedPreferences.getInstance();
      final token = UserPref(prefs).getToken() ?? '';
      if (token.isEmpty) throw StateError('Authentication required');
      final response = await ApiService().findReportByUserDataId(
        auth: token, userDataId: candidateId);
      if (response.statusCode != 200 || response.data is! Map<String, dynamic>) {
        throw StateError('Report unavailable');
      }
      final reports = ReportResponse.fromJson(response.data as Map<String, dynamic>).report;
      final report = reports.isEmpty ? null : reports.first;
      if (report == null) throw StateError('Report is not generated for this candidate');
      switch (type) {
        case 'mi':
          if (report.multipleIntelligence != null) {
            destination = MultiIntelligenceDetailScreen(
                multipleIntelligence: report!.multipleIntelligence!);
          }
          break;
        case 'brain':
          if (report.brainDominance != null) {
            destination = BrainDominanceDetailScreen(
                brainDominance: report.brainDominance);
          }
          break;
        case 'senses':
          if (report.senses != null) {
            destination = SensesDetailScreen(senses: report.senses);
          }
          break;
        case 'personality':
          if (report.personality != null) {
            destination = PersonalityDetailScreen(/*personality: report.personality*/);
          }
          break;
        case 'swot':
          // The SWOT descriptions remain local. Only the personality labels
          // are loaded from the selected candidate's API report.
          final blend = await ReportService().fetchPersonalityBlend(
            userDataId: candidateId,
          );
          final primary = (blend?.report?.personality?.primary ??
                  report.personality?.primary ?? '')
              .trim();
          final secondary = (blend?.report?.personality?.secondary ??
                  report.personality?.secondary ?? '')
              .trim();
          if (primary.isNotEmpty) {
            destination = SwotDetailScreen(
              primary: primary,
              secondary: secondary,
            );
          }
          break;
      }
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop(); // loading dialog
      if (candidateId != GlobalClass.selected_member) return;
      if (destination == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Personality data is not available for this candidate.')));
        return;
      }
      _navigateToScreen(destination);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to load candidate report: $e')));
    }
  }

  Future<void> _signOut() async {
    final bool? confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Sign Out',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        content: const Text('Are you sure you want to sign out and switch accounts?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF64748B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF4444),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Sign Out', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final prefs = await SharedPreferences.getInstance();
      final userPref = UserPref(prefs);
      final appPref = AppPref(prefs);

      await userPref.clearToken();
      await appPref.clearToken();

      // Clear all SQLite data, Global selections, and cached reports
      await DatabaseHelper.instance.clearAllData();
      GlobalClass.reset();
      await HomeDataPreloader.instance.clear();
      DashboardReportStatusController.instance.cancel();
      try {
        await FingerChannel.clearScanCache();
      } catch (_) {

      }

      if (mounted) {
        Navigator.pop(context); // Close Drawer
        context.go(AppRoutes.signIn); // Navigate to SignIn Page
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.sizeOf(context).width;
    final double topPadding = MediaQuery.viewPaddingOf(context).top;

    return RepaintBoundary(
      child: Drawer(
        width: (screenWidth * 0.85).clamp(300.0, 380.0),
        backgroundColor: Colors.white,
        elevation: 16,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topRight: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              // Top Dark Blue Header Container
              Container(
                width: double.infinity,
                padding: EdgeInsets.only(
                  top: topPadding + 14,
                  left: 16,
                  right: 14,
                  bottom: 16,
                ),
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Color(0xFF0F172A),
                      Color(0xFF1E1B4B),
                      Color(0xFF0F172A),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Row & Close Button
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Flexible(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'assets/images/dakshlogo.png',
                                width: 16,
                                height: 16,
                                fit: BoxFit.contain,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  'DAKSH INTELLIGENCE MENU',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: context.scaleFont(10.5),
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFF06B6D4),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close_rounded,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Active Student Profile Row
                    Row(
                      children: [
                        Stack(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: const Color(0xFFFEF08A),
                                border: Border.all(
                                  color: const Color(0xFF818CF8),
                                  width: 2,
                                ),
                              ),
                              child: const Center(
                                child: Text(
                                  '👦',
                                  style: TextStyle(fontSize: 26),
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 0,
                              right: 0,
                              child: Container(
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF22C55E),
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                      color: const Color(0xFF0F172A), width: 2),
                                ),
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _activeMemberName,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                _activeMemberContact,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  fontSize: 11,
                                  color: Color(0xFF94A3B8),
                                ),
                              ),
                              const SizedBox(height: 4),
                              Wrap(
                                spacing: 4,
                                runSpacing: 4,
                                children: [
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 7, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: _activeMemberReportReady
                                          ? const Color(0xFF065F46)
                                          : const Color(0xFF78350F),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      _activeMemberReportReady
                                          ? 'Report Ready ✨'
                                          : 'Scan Pending ⏳',
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: _activeMemberReportReady
                                            ? const Color(0xFF86EFAC)
                                            : const Color(0xFFFDE047),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    // Switch Profile Row
                    if (_candidateMembers.isNotEmpty)
                      Row(
                        children: [
                          const Text(
                            'Switch Profile:',
                            style: TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                              color: Colors.white70,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              physics: const BouncingScrollPhysics(),
                              child: Row(
                                children: [
                                  ...List.generate(_candidateMembers.length, (idx) {
                                    final isSelected = _selectedMemberIndex == idx;
                                    final user = _candidateMembers[idx];
                                    final name = (user.dataName != null &&
                                            user.dataName!.isNotEmpty)
                                        ? user.dataName!
                                        : (user.firstName != null &&
                                                user.firstName!.isNotEmpty)
                                            ? user.firstName!
                                            : 'Candidate';

                                    return GestureDetector(
                                      onTap: () {
                                        setState(() => _selectedMemberIndex = idx);
                                        GlobalClass.selected_member = user.id;
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 8.0),
                                        child: Column(
                                          children: [
                                            Container(
                                              width: 32,
                                              height: 32,
                                              decoration: BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: const Color(0xFF1E293B),
                                                border: Border.all(
                                                  color: isSelected
                                                      ? const Color(0xFF06B6D4)
                                                      : Colors.transparent,
                                                  width: 2,
                                                ),
                                              ),
                                              child: const Center(
                                                child: Text(
                                                  '👦',
                                                  style: TextStyle(fontSize: 15),
                                                ),
                                              ),
                                            ),
                                            const SizedBox(height: 2),
                                            Text(
                                              name,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: TextStyle(
                                                fontSize: 9.5,
                                                color: isSelected
                                                    ? const Color(0xFF06B6D4)
                                                    : Colors.white70,
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }),
                                  GestureDetector(
                                    onTap: () {
                                      AddFamilyMemberDialog.show(context);
                                    },
                                    child: Column(
                                      children: [
                                        Container(
                                          width: 32,
                                          height: 32,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color: Colors.white38,
                                              width: 1.2,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 16,
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        const Text(
                                          'Add',
                                          style: TextStyle(
                                            fontSize: 9.5,
                                            color: Colors.white60,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),

              // Scrollable Menu Items
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Section 1: COGNITIVE ASSESSMENTS
                      _buildSectionHeader('COGNITIVE ASSESSMENTS'),
                      const SizedBox(height: 8),

                      _buildMenuTile(
                        icon: '🔷',
                        title: '8 Multi-Intelligence Wheel',
                        badgeBgColor: const Color(0xFFEEF2FF),
                        badgeTextColor: const Color(0xFF6366F1),
                        onTap: () => _openAssessmentScreen('mi'),
                      ),
                      _buildMenuTile(
                        icon: '🔮',
                        title: 'Brain Dominance & Balance',
                        badgeBgColor: const Color(0xFFF3E8FF),
                        badgeTextColor: const Color(0xFFA855F7),
                        onTap: () => _openAssessmentScreen('brain'),
                      ),
                      _buildMenuTile(
                        icon: '👁',
                        title: '5 Senses Sensory Modalities',
                        badgeBgColor: const Color(0xFFE0F2FE),
                        badgeTextColor: const Color(0xFF0284C7),
                        onTap: () => _openAssessmentScreen('senses'),
                      ),
                      _buildMenuTile(
                        icon: '🎯',
                        title: 'DISC Personality Blend',
                        badgeBgColor: const Color(0xFFDCFCE7),
                        badgeTextColor: const Color(0xFF16A34A),
                        onTap: () => _openAssessmentScreen('personality'),
                      ),
                      _buildMenuTile(
                        icon: '🛡',
                        title: 'SWOT Analysis & Matrix',
                        badgeBgColor: const Color(0xFFFEF9C3),
                        badgeTextColor: const Color(0xFFCA8A04),
                        onTap: () => _openAssessmentScreen('swot'),
                      ),

                      const SizedBox(height: 16),

                      const SizedBox(height: 16),

                      // Section 2: PRIVACY & LEGAL
                      _buildSectionHeader('PRIVACY & LEGAL'),
                      const SizedBox(height: 8),

                      _buildMenuTile(
                        icon: '🔒',
                        title: 'DPDP Act & Data Privacy',
                        onTap: () => _navigateToScreen(const DpdpPrivacyScreen()),
                      ),

                      const SizedBox(height: 10),

                      // Sign Out Tile
                      GestureDetector(
                        onTap: _signOut,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF2F2),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: const Color(0xFFFCA5A5)),
                          ),
                          child: Row(
                            children: const [
                              Icon(
                                Icons.logout_rounded,
                                color: Color(0xFFEF4444),
                                size: 18,
                              ),
                              SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  'Sign Out',
                                  style: TextStyle(
                                    fontSize: 13.0,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFFEF4444),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),

              // Bottom Footer
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: const BoxDecoration(
                  color: Color(0xFFF8FAFC),
                  border: Border(
                    top: BorderSide(color: Color(0xFFE2E8F0)),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            'Daksh Pro',
                            style: TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          SizedBox(height: 2),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      'v2.4.0',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 10.5,
        fontWeight: FontWeight.w800,
        color: Color(0xFF94A3B8),
        letterSpacing: 0.6,
      ),
    );
  }

  Widget _buildBannerCard({
    required Color bgColor,
    Color? borderColor,
    bool isDarkText = false,
    required String icon,
    required String title,
    required String titleBadge,
    required Color badgeBgColor,
    required String subtitle,
  }) {
    final textColor = isDarkText ? const Color(0xFF0F172A) : Colors.white;
    final subColor = isDarkText ? const Color(0xFF047857) : Colors.white70;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(18),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.20),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 4,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: textColor,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                      decoration: BoxDecoration(
                        color: badgeBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        titleBadge,
                        style: const TextStyle(
                          fontSize: 9.0,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10.5,
                    color: subColor,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: textColor,
            size: 18,
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTile({
    required String icon,
    required String title,
    String? badgeText,
    Color? badgeBgColor,
    Color? badgeTextColor,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6.0),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Text(icon, style: const TextStyle(fontSize: 15)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1E293B),
                  ),
                ),
              ),
              if (badgeText != null) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                  decoration: BoxDecoration(
                    color: badgeBgColor ?? const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      fontSize: 10.0,
                      fontWeight: FontWeight.w700,
                      color: badgeTextColor ?? const Color(0xFF64748B),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
