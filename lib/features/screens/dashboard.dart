/*
import 'package:flutter/material.dart';
import '../../core/models/intelligence_models.dart';
import '../../core/Global/global_class.dart';
import '../../core/database/database_helper.dart';
import '../../core/services/dashboard_report_status_controller.dart';
import 'dmit_protocol_intro_screen.dart';
import '../../core/services/app_version_checker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'ai_counselor_screen.dart';
import 'assessment_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'report_screen.dart';
import 'widgets/daksh_intelligence_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  bool _openingDashboardScanner = false;

  /// Dashboard Scan -> DMIT -> successful upload -> Report tab ->
  /// poll selected candidate status -> load Report and refresh Home.
  Future<void> _openDashboardScanner() async {
    if (_openingDashboardScanner) return;
    final candidateId = GlobalClass.selected_member.trim();
    if (candidateId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a candidate on Home first.')),
      );
      setState(() => _currentIndex = 0);
      return;
    }

    _openingDashboardScanner = true;
    try {
      final candidate = await DatabaseHelper.instance.getMemberById(candidateId);
      if (!mounted) return;
      if (candidate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected candidate not found. Please select again.')),
        );
        setState(() => _currentIndex = 0);
        return;
      }
      final candidateName = (candidate.dataName ?? '').trim().isNotEmpty
          ? candidate.dataName!.trim()
          : [candidate.firstName, candidate.lastName]
              .whereType<String>()
              .where((part) => part.trim().isNotEmpty)
              .join(' ');

      final uploaded = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => DmitProtocolIntroScreen(candidateName: candidateName),
        ),
      );
      if (!mounted || uploaded != true) return;
      if (GlobalClass.selected_member != candidateId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Candidate changed. Please select and scan again.')),
        );
        return;
      }

      // The native scan has finished uploading. Report generation may still
      // be pending on the backend, so never mark it ready here.
      setState(() => _currentIndex = 3);
      DashboardReportStatusController.instance.startForCandidate(candidateId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open scanner: $e')),
      );
    } finally {
      _openingDashboardScanner = false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
  *//*

*/
/*  WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateManager.checkForUpdates(context);
    });*//*
*/
/*

    super.initState();
  }

  @override
  void dispose() {
    final controller = DashboardReportStatusController.instance;
    if (controller.state.value.phase == DashboardReportPhase.waiting) {
      controller.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DakshIntelligenceDrawer(),
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: const [
          HomeScreen(),
          AssessmentScreen(),
          AICounselorScreen(
            profile: StudentProfile(
              id: '1',
              name: 'Aarav',
              role: 'Class 8',
              avatar: '👦',
              gender: 'boy',
              grade: 'Class 8',
              active: true,
            ),
          ),
          ReportScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildResponsiveBottomNavigationBar(context),
    );
  }

  Widget _buildResponsiveBottomNavigationBar(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final isNarrow = context.isNarrowMobile;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: context.responsiveValue(
            mobile: 68 + (bottomPadding > 0 ? 0 : 6),
            tablet: 76,
            desktop: 80,
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 0,
                  label: 'Home',
                  icon: Icons.home_rounded,
                  isNarrow: isNarrow,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 1,
                  label: 'Assessment',
                  icon: Icons.calendar_today_outlined,
                  hasBadge: true,
                  isNarrow: isNarrow,
                ),
              ),
              Expanded(
                child: _buildScanNavItem(context: context, isNarrow: isNarrow),
              ),
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 3,
                  label: 'Report',
                  icon: Icons.article_outlined,
                  isNarrow: isNarrow,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 4,
                  label: 'Profile',
                  icon: Icons.person_outline_rounded,
                  isNarrow: isNarrow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
    bool hasBadge = false,
    required bool isNarrow,
  }) {
    final bool isSelected = _currentIndex == index;
    final Color activeColor = AppTheme.primary;
    final Color inactiveColor = const Color(0xFF94A3B8);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: isNarrow ? 20 : 22,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              if (hasBadge)
                Positioned(
                  top: 0,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: context.scaleFont(isNarrow ? 10 : 11),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanNavItem({
    required BuildContext context,
    required bool isNarrow,
  }) {
    return InkWell(
      onTap: _openDashboardScanner,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Transform.translate(
        offset: const Offset(0, -8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isNarrow ? 44 : 48,
              height: isNarrow ? 44 : 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF3B82F6),
                    Color(0xFF00E5FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.fingerprint_rounded,
                  color: Colors.white,
                  size: isNarrow ? 26 : 28,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Scan',
              style: TextStyle(
                fontSize: context.scaleFont(isNarrow ? 10 : 11),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
*//*

import 'package:flutter/material.dart';
import '../../core/models/intelligence_models.dart';
import '../../core/Global/global_class.dart';
import '../../core/database/database_helper.dart';
import '../../core/services/dashboard_report_status_controller.dart';
import 'dmit_protocol_intro_screen.dart';
import '../../core/services/app_version_checker.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'ai_counselor_screen.dart';
import 'assessment_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'report_screen.dart';
import 'widgets/daksh_intelligence_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;

  bool _openingDashboardScanner = false;

  /// Dashboard Scan -> DMIT -> successful upload -> Report tab ->
  /// poll selected candidate status -> load Report and refresh Home.
  void _goToReportAfterUpload(String candidateId) {
    setState(() => _currentIndex = 3); // Report tab
    DashboardReportStatusController.instance.startForCandidate(candidateId);
  }

  /// Home screen ke Scan button se upload hone par sirf Report tab kholna hai.
  /// Status polling Home khud karta hai.
  void _openReportTab() {
    if (!mounted) return;
    setState(() => _currentIndex = 3);
  }

  Future<void> _openDashboardScanner() async {
    if (_openingDashboardScanner) return;
    final candidateId = GlobalClass.selected_member.trim();
    if (candidateId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a candidate on Home first.')),
      );
      setState(() => _currentIndex = 0);
      return;
    }

    _openingDashboardScanner = true;
    try {
      final candidate = await DatabaseHelper.instance.getMemberById(candidateId);
      if (!mounted) return;
      if (candidate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Selected candidate not found. Please select again.')),
        );
        setState(() => _currentIndex = 0);
        return;
      }
      final candidateName = (candidate.dataName ?? '').trim().isNotEmpty
          ? candidate.dataName!.trim()
          : [candidate.firstName, candidate.lastName]
          .whereType<String>()
          .where((part) => part.trim().isNotEmpty)
          .join(' ');

      final uploaded = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (_) => DmitProtocolIntroScreen(candidateName: candidateName),
        ),
      );
      if (!mounted || uploaded != true) return;
      if (GlobalClass.selected_member != candidateId) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Candidate changed. Please select and scan again.')),
        );
        return;
      }

      // The native scan has finished uploading. Report generation may still
      // be pending on the backend, so never mark it ready here.
      _goToReportAfterUpload(candidateId);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unable to open scanner: $e')),
      );
    } finally {
      _openingDashboardScanner = false;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    */
/*  WidgetsBinding.instance.addPostFrameCallback((_) {
      AppUpdateManager.checkForUpdates(context);
    });*//*

    super.initState();
  }

  @override
  void dispose() {
    final controller = DashboardReportStatusController.instance;
    if (controller.state.value.phase == DashboardReportPhase.waiting) {
      controller.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DakshIntelligenceDrawer(),
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        // NOTE: `const` hata diya kyunki HomeScreen ko callback (function) dena hai
        children: [
          HomeScreen(onScanUploaded: _openReportTab),
          const AssessmentScreen(),
          const AICounselorScreen(
            profile: StudentProfile(
              id: '1',
              name: 'Aarav',
              role: 'Class 8',
              avatar: '👦',
              gender: 'boy',
              grade: 'Class 8',
              active: true,
            ),
          ),
          const ReportScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: _buildResponsiveBottomNavigationBar(context),
    );
  }

  Widget _buildResponsiveBottomNavigationBar(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final isNarrow = context.isNarrowMobile;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: context.responsiveValue(
            mobile: 68 + (bottomPadding > 0 ? 0 : 6),
            tablet: 76,
            desktop: 80,
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 0,
                  label: 'Home',
                  icon: Icons.home_rounded,
                  isNarrow: isNarrow,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 1,
                  label: 'Assessment',
                  icon: Icons.calendar_today_outlined,
                  hasBadge: true,
                  isNarrow: isNarrow,
                ),
              ),
              Expanded(
                child: _buildScanNavItem(context: context, isNarrow: isNarrow),
              ),
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 3,
                  label: 'Report',
                  icon: Icons.article_outlined,
                  isNarrow: isNarrow,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 4,
                  label: 'Profile',
                  icon: Icons.person_outline_rounded,
                  isNarrow: isNarrow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
    bool hasBadge = false,
    required bool isNarrow,
  }) {
    final bool isSelected = _currentIndex == index;
    final Color activeColor = AppTheme.primary;
    final Color inactiveColor = const Color(0xFF94A3B8);

    return InkWell(
      onTap: () => setState(() => _currentIndex = index),
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected ? const Color(0xFFEEF2FF) : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: isNarrow ? 20 : 22,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              if (hasBadge)
                Positioned(
                  top: 0,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: context.scaleFont(isNarrow ? 10 : 11),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanNavItem({
    required BuildContext context,
    required bool isNarrow,
  }) {
    return InkWell(
      onTap: _openDashboardScanner,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Transform.translate(
        offset: const Offset(0, -8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isNarrow ? 44 : 48,
              height: isNarrow ? 44 : 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF3B82F6),
                    Color(0xFF00E5FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.fingerprint_rounded,
                  color: Colors.white,
                  size: isNarrow ? 26 : 28,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Scan',
              style: TextStyle(
                fontSize: context.scaleFont(isNarrow ? 10 : 11),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}*/
import 'package:daksh/core/Global/global_class.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/api_constants.dart';
import '../../core/services/firebase_notification_manager.dart';
import '../../core/storage/user_pref.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'assessment_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'report_screen.dart';
import 'widgets/daksh_intelligence_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  // Tabs: Home 0, Assessment 1, Report 2, Profile 3 (Scan beech me hai, index nahi leta)
  int _currentIndex = 0;

  final GlobalKey<HomeScreenState> _homeKey = GlobalKey<HomeScreenState>();

  @override
  void initState() {
    super.initState();
    _setupFirebaseNotifications();
  }

  Future<void> _setupFirebaseNotifications() async {
    String baseUrl = ApiConstants.baseUrl;
    final prefs = await SharedPreferences.getInstance();
    final userPref = UserPref(prefs);
    final authToken = userPref.getToken() ?? '';

    if (authToken.isNotEmpty) {
      FirebaseNotificationManager().initialize(
        baseUrl: baseUrl,
        userAuthToken: authToken,
        onNotificationTap: () {
          // Switch Dashboard tab to Report screen (Index 2)
          setState(() {
            _currentIndex = 2; // Index 2 is ReportScreen
          });
        },
      );
    }
  }

  void _onScanTap() {
    setState(() => _currentIndex = 0);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _homeKey.currentState?.openScan();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const DakshIntelligenceDrawer(),
      backgroundColor: AppTheme.background,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(key: _homeKey),
          const AssessmentScreen(),
          const ReportScreen(),
          ProfileScreen(onScanRequested: _onScanTap),
        ],
      ),
      bottomNavigationBar: _buildResponsiveBottomNavigationBar(context),
    );
  }

  Widget _buildResponsiveBottomNavigationBar(BuildContext context) {
    final bottomPadding = MediaQuery.paddingOf(context).bottom;
    final isNarrow = context.isNarrowMobile;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: context.responsiveValue(
            mobile: 68 + (bottomPadding > 0 ? 0 : 6),
            tablet: 76,
            desktop: 80,
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 0,
                  label: 'Home',
                  icon: Icons.home_rounded,
                  isNarrow: isNarrow,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 1,
                  label: 'Assessment',
                  icon: Icons.calendar_today_outlined,
                  hasBadge: true,
                  isNarrow: isNarrow,
                ),
              ),
              Expanded(
                child: _buildScanNavItem(context: context, isNarrow: isNarrow),
              ),
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 2,
                  label: 'Report',
                  icon: Icons.article_outlined,
                  isNarrow: isNarrow,
                ),
              ),
              Expanded(
                child: _buildNavItem(
                  context: context,
                  index: 3,
                  label: 'Profile',
                  icon: Icons.person_outline_rounded,
                  isNarrow: isNarrow,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required BuildContext context,
    required int index,
    required String label,
    required IconData icon,
    bool hasBadge = false,
    required bool isNarrow,
  }) {
    final bool isSelected = _currentIndex == index;
    final Color activeColor = AppTheme.primary;
    const Color inactiveColor = Color(0xFF94A3B8);

    return InkWell(
      onTap: () {
        /*if(_currentIndex==3)
          {

          }
        setState(() => _currentIndex = index);*/
        final previousIndex = _currentIndex;
        setState(() => _currentIndex = index);

        // Profile -> Home: refresh candidate data
        if (previousIndex == 3 && index == 0) {
          _homeKey.currentState?.reloadCandidates();
        }

      },
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFEEF2FF)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  size: isNarrow ? 20 : 22,
                  color: isSelected ? activeColor : inactiveColor,
                ),
              ),
              if (hasBadge)
                Positioned(
                  top: 0,
                  right: 4,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: const Color(0xFF6366F1),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 2),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              label,
              maxLines: 1,
              style: TextStyle(
                fontSize: context.scaleFont(isNarrow ? 10 : 11),
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? activeColor : inactiveColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScanNavItem({
    required BuildContext context,
    required bool isNarrow,
  }) {
    return InkWell(
      onTap: _onScanTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Transform.translate(
        offset: const Offset(0, -8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: isNarrow ? 44 : 48,
              height: isNarrow ? 44 : 48,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF2563EB),
                    Color(0xFF3B82F6),
                    Color(0xFF00E5FF),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Center(
                child: Icon(
                  Icons.fingerprint_rounded,
                  color: Colors.white,
                  size: isNarrow ? 26 : 28,
                ),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Scan',
              style: TextStyle(
                fontSize: context.scaleFont(isNarrow ? 10 : 11),
                fontWeight: FontWeight.bold,
                color: const Color(0xFF2563EB),
              ),
            ),
          ],
        ),
      ),
    );
  }
}