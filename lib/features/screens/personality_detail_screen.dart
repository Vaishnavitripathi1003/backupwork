import 'package:daksh/core/Global/global_class.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/models/intelligence_models.dart';
// Prefixed because both files define a `StudentProfile` class.

import '../../core/network/api_service.dart';
import '../../core/storage/user_pref.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../data/models/disc_personality_report.dart';
import 'ai_counselor_screen.dart';

/// Personality Profile screen. Takes no arguments: it fetches the DISC report
/// itself using the stored token and the currently selected member.
class PersonalityDetailScreen extends StatefulWidget {
  const PersonalityDetailScreen({super.key});

  @override
  State<PersonalityDetailScreen> createState() =>
      _PersonalityDetailScreenState();
}

class _PersonalityDetailScreenState extends State<PersonalityDetailScreen> {
  int _selectedTabIndex = 0;
  int _selectedStageIndex = 0;

  DakshPersonalityFullReport? _report;
  bool _isLoading = true;
  String? _errorMessage;

  final List<String> _tabs = [
    'Archetype & Blend',
    'Behavioral Metrics',
    'In Action',
    'Mentorship',
  ];

  @override
  void initState() {
    super.initState();
    _loadReport();
  }

  Future<void> _loadReport() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = UserPref(prefs).getToken() ?? '';
      final memberId = GlobalClass.selected_member;

      if (token.isEmpty || memberId.isEmpty) {
        throw Exception('Missing login session or selected member.');
      }

      final response =
      await ApiService().findDiscPersonalityLifeStagesGuideByUserDataId(
        auth: token,
        userDataId: memberId,
      );

      if (response.statusCode == 200 && response.data != null) {
        final parsed = DakshPersonalityFullReport.fromJson(response.data);
        if (!mounted) return;
        setState(() {
          _report = parsed;
          _isLoading = false;
        });
      } else {
        throw Exception('Unexpected response (${response.statusCode}).');
      }
    } catch (e) {
      debugPrint('Error loading DISC personality report: $e');
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Could not load personality profile.';
      });
    }
  }

/*  void _openCounselor(BuildContext context, [String? initialPrompt]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AICounselorScreen(
          profile: const StudentProfile(
            id: '1',
            name: 'Aarav',
            role: 'Class 8',
            avatar: '👦',
            gender: 'boy',
            grade: 'Class 8',
            active: true,
          ),
          initialPrompt: initialPrompt,
        ),
      ),
    );
  }*/

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;
    final report = _report;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Personality Profile',
              style: TextStyle(
                fontSize: context.scaleFont(18),
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            if (report != null)
              Text(
                '${report.personality.primary} – ${report.personality.secondary} Blend',
                style: const TextStyle(
                    fontSize: 11, color: AppTheme.textSecondary),
              ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined,
                size: 20, color: AppTheme.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : report == null
            ? _buildErrorState()
            : Column(
          children: [
            _buildTabsRow(context, isNarrow),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(
                    horizontal: padding, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSynthesisCard(context, isNarrow, report),
                    const SizedBox(height: 16),
                    if (_selectedTabIndex == 0)
                      _buildArchetypeAndBlendTab(
                          context, isNarrow, report),
                    if (_selectedTabIndex == 1)
                      _buildBehavioralMetricsTab(
                          context, isNarrow, report),
                    if (_selectedTabIndex == 2)
                      _buildInActionTab(context, isNarrow, report),
                    if (_selectedTabIndex == 3)
                      _buildMentorshipTab(context, isNarrow, report),
                    const SizedBox(height: 80),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline_rounded,
                size: 40, color: Color(0xFF94A3B8)),
            const SizedBox(height: 10),
            Text(
              _errorMessage ?? 'No personality data available.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _loadReport,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabsRow(BuildContext context, bool isNarrow) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: List.generate(_tabs.length, (index) {
            final bool isSelected = _selectedTabIndex == index;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: InkWell(
                onTap: () => setState(() => _selectedTabIndex = index),
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? const Color(0xFF0F172A)
                        : const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _tabs[index],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                      isSelected ? FontWeight.bold : FontWeight.w600,
                      color:
                      isSelected ? Colors.white : const Color(0xFF475569),
                    ),
                  ),
                ),
              ),
            );
          }),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Shared helpers
  // ---------------------------------------------------------------------------

  Widget _card(
      bool isNarrow, {
        required Widget child,
        Color color = Colors.white,
        Color borderColor = const Color(0xFFE2E8F0),
      }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isNarrow ? 14 : 18),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  Widget _cardTitle(BuildContext context, String title, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: context.scaleFont(15),
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(subtitle,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Shared header card: archetype + blend ratio. Shown at the top of every tab.
  Widget _buildSynthesisCard(
      BuildContext context, bool isNarrow, DakshPersonalityFullReport r) {
    final primary = r.personality.primary;
    final secondary = r.personality.secondary;
    final p = r.data.discQuadrantPlacement.primary;
    final s = r.data.discQuadrantPlacement.secondary;

    // Ratio bound to disc_quadrant_placement (normalised so it still works
    // if the two percentages ever don't add up to exactly 100).
    final total = p.percentage + s.percentage;
    final ratio = total > 0 ? p.percentage / total : 0.5;
    final ratioLabel = '${p.percentage} / ${s.percentage}';

    return _card(
      isNarrow,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Primary DISC Synthesis',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
              Flexible(
                child: Text(r.data.combination,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4338CA))),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      r.data.archetype,
                      style: TextStyle(
                        fontSize: context.scaleFont(20),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      r.data.cluster,
                      style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF64748B),
                          height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color(0xFFFAF5FF),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Center(
                  child: Icon(Icons.bolt_rounded,
                      color: Color(0xFF7C3AED), size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _pill('Full Blend (${p.percentage}/${s.percentage})',
                  const Color(0xFF0F172A), Colors.white),
              _pill('$primary (Primary)', const Color(0xFFF3E8FF),
                  const Color(0xFF7E22CE)),
              _pill('$secondary (Secondary)', const Color(0xFFDCFCE7),
                  const Color(0xFF15803D)),
            ],
          ),

          const SizedBox(height: 20),

          // Ratio donut
          Center(
            child: SizedBox(
              width: 130,
              height: 130,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 130,
                    height: 130,
                    child: CircularProgressIndicator(
                      value: ratio,
                      strokeWidth: 14,
                      backgroundColor: const Color(0xFF10B981),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF7C3AED)),
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(ratioLabel,
                          style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A))),
                      const Text('RATIO BALANCE',
                          style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF64748B))),
                    ],
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 6,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle,
                      size: 10, color: Color(0xFF7C3AED)),
                  const SizedBox(width: 4),
                  Text('$primary  ${p.percentage}%',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155))),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.circle,
                      size: 10, color: Color(0xFF10B981)),
                  const SizedBox(width: 4),
                  Text('$secondary  ${s.percentage}%',
                      style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF334155))),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 1: Archetype & Blend
  // ---------------------------------------------------------------------------

  Widget _buildArchetypeAndBlendTab(
      BuildContext context, bool isNarrow, DakshPersonalityFullReport r) {
    final primary = r.personality.primary;
    final secondary = r.personality.secondary;
    final p = r.data.discQuadrantPlacement.primary;
    final s = r.data.discQuadrantPlacement.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Synergy card
        _card(
          isNarrow,
          color: const Color(0xFF1E1B4B),
          borderColor: const Color(0xFF1E1B4B),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: const [
                  Text('Unique Cognitive Advantage',
                      style: TextStyle(fontSize: 12, color: Color(0xFFC7D2FE))),
                  Text('Dual Synergy',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFEF08A))),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('⭐', style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'The $primary & $secondary Synergy',
                      style: TextStyle(
                        fontSize: context.scaleFont(15),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${p.description} ${s.description}',
                style: const TextStyle(
                    fontSize: 12, color: Color(0xFFE0E7FF), height: 1.45),
              ),
              const Divider(height: 24, color: Colors.white24),
              Wrap(
                alignment: WrapAlignment.spaceBetween,
                runSpacing: 8,
                spacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Text(
                    'Archetype: ${r.data.archetype}',
                    style: const TextStyle(
                        fontSize: 11, color: Color(0xFFC7D2FE)),
                  ),
                  InkWell(
                    onTap: (){},/*_openCounselor(context,
                        'Explain my archetype "${r.data.archetype}" and what it means for me'),*/
                    child: const Text(
                      'Explore with AI →',
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFEF08A)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _buildPersonalityBreakdownCard(
          avatarChar: primary.isNotEmpty ? primary[0] : 'P',
          avatarBg: const Color(0xFFF3E8FF),
          title: '$primary Personality',
          percentage: '${p.percentage}%',
          subtitle: p.dimension,
          description: p.description,
          accent: const Color(0xFF7E22CE),
        ),

        const SizedBox(height: 16),

        _buildPersonalityBreakdownCard(
          avatarChar: secondary.isNotEmpty ? secondary[0] : 'S',
          avatarBg: const Color(0xFFDCFCE7),
          title: '$secondary Personality',
          percentage: '${s.percentage}%',
          subtitle: s.dimension,
          description: s.description,
          accent: const Color(0xFF15803D),
        ),
      ],
    );
  }

  Widget _pill(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration:
      BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          style: TextStyle(
              fontSize: 11, fontWeight: FontWeight.bold, color: fg)),
    );
  }

  Widget _buildPersonalityBreakdownCard({
    required String avatarChar,
    required Color avatarBg,
    required String title,
    required String percentage,
    required String subtitle,
    required String description,
    required Color accent,
  }) {
    return _card(
      context.isNarrowMobile,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration:
                BoxDecoration(color: avatarBg, shape: BoxShape.circle),
                child: Center(
                    child: Text(avatarChar,
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: accent))),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                              text: title,
                              style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppTheme.textPrimary)),
                          const TextSpan(text: ' • '),
                          TextSpan(
                              text: percentage,
                              style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                  color: accent)),
                        ],
                      ),
                    ),
                    Text(subtitle,
                        style: const TextStyle(
                            fontSize: 11, color: Color(0xFF64748B))),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(description,
              style: const TextStyle(
                  fontSize: 12, color: Color(0xFF475569), height: 1.35)),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 2: Behavioral Metrics
  // ---------------------------------------------------------------------------

  Color _meterColor(int pct) {
    if (pct >= 80) return const Color(0xFF7C3AED);
    if (pct >= 65) return const Color(0xFF2563EB);
    return const Color(0xFF10B981);
  }

  Widget _buildBehavioralMetricsTab(
      BuildContext context, bool isNarrow, DakshPersonalityFullReport r) {
    final meters = r.data.behavioralIntensityMeters;
    final p = r.data.discQuadrantPlacement.primary;
    final s = r.data.discQuadrantPlacement.secondary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          isNarrow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(context, 'Behavioral Intensity Meters',
                  'Scoring across key work and study dimensions'),
              const SizedBox(height: 16),
              for (int i = 0; i < meters.length; i++) ...[
                _buildMeterRow(
                  meters[i].metric,
                  meters[i].label,
                  (meters[i].percentage / 100).clamp(0.0, 1.0).toDouble(),
                  '${meters[i].percentage}%',
                  _meterColor(meters[i].percentage),
                ),
                if (i != meters.length - 1) const SizedBox(height: 12),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          isNarrow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(context, 'DISC Quadrant Coordinates',
                  'Overall psychometric matrix placement'),
              const SizedBox(height: 14),
              _QuadrantCard(
                title: '${p.dimension} (Primary)',
                score: '${p.percentage}%',
                subtitle: p.description,
                bgColor: const Color(0xFFFAF5FF),
                borderColor: const Color(0xFFE9D5FF),
                titleColor: const Color(0xFF7E22CE),
              ),
              const SizedBox(height: 10),
              _QuadrantCard(
                title: '${s.dimension} (Secondary)',
                score: '${s.percentage}%',
                subtitle: s.description,
                bgColor: const Color(0xFFECFDF5),
                borderColor: const Color(0xFFA7F3D0),
                titleColor: const Color(0xFF059669),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMeterRow(
      String label, String rating, double value, String pct, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(label,
                  style: const TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
            ),
            Row(
              children: [
                Text(rating,
                    style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: color)),
                const SizedBox(width: 6),
                Text(pct,
                    style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary)),
              ],
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 8,
            backgroundColor: const Color(0xFFF1F5F9),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 3: In Action (life stages)
  // ---------------------------------------------------------------------------

  List<_StageInfo> _buildStages(LifeStages ls) {
    return [
      _StageInfo(
        title: 'Student',
        subtitle: 'How they learn and work with others',
        icon: Icons.school_outlined,
        entries: [
          MapEntry('Group Projects', ls.studentProfile.groupProjects),
          MapEntry('Academic Pressure', ls.studentProfile.academicPressure),
          MapEntry('Communication', ls.studentProfile.communication),
          MapEntry('Optimal Learning Environment',
              ls.studentProfile.optimalLearningEnvironment),
        ],
      ),
      _StageInfo(
        title: 'Working Professional',
        subtitle: 'How they perform and lead at work',
        icon: Icons.work_outline_rounded,
        entries: [
          MapEntry('Workplace Execution',
              ls.workingProfessionalProfile.workplaceExecution),
          MapEntry('Leadership & Management',
              ls.workingProfessionalProfile.leadershipManagement),
          MapEntry(
              'Stress Response', ls.workingProfessionalProfile.stressResponse),
        ],
        roles: ls.workingProfessionalProfile.idealRoles,
      ),
      _StageInfo(
        title: 'Personal Life',
        subtitle: 'How they show up at home and in relationships',
        icon: Icons.home_outlined,
        entries: [
          MapEntry('Household Dynamics', ls.personalEverydayLife.householdDynamics),
          MapEntry('Everyday Relationships',
              ls.personalEverydayLife.everydayRelationships),
          MapEntry('Conflict Resolution',
              ls.personalEverydayLife.conflictResolution),
        ],
      ),
    ];
  }

  Widget _buildInActionTab(
      BuildContext context, bool isNarrow, DakshPersonalityFullReport r) {
    final stages = _buildStages(r.data.lifeStages);
    final current = stages[_selectedStageIndex.clamp(0, stages.length - 1)];

    return Visibility(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: List.generate(stages.length, (index) {
                final bool isSel = _selectedStageIndex == index;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => setState(() => _selectedStageIndex = index),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSel ? const Color(0xFF0F172A) : Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: Text(
                        stages[index].title,
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: isSel ? FontWeight.bold : FontWeight.w600,
                          color: isSel ? Colors.white : const Color(0xFF475569),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
          _card(
            isNarrow,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('LIFE STAGE PROFILE',
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w800,
                                  color: Color(0xFF6366F1),
                                  letterSpacing: 0.5)),
                          const SizedBox(height: 2),
                          Text(
                            current.title,
                            style: TextStyle(
                                fontSize: context.scaleFont(16),
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textPrimary),
                          ),
                          Text(
                            current.subtitle,
                            style: const TextStyle(
                                fontSize: 12, color: Color(0xFF64748B)),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                          color: const Color(0xFFF1F5F9),
                          borderRadius: BorderRadius.circular(12)),
                      child: Icon(current.icon,
                          color: const Color(0xFF4338CA), size: 22),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                for (final e in current.entries)
                  if (e.value.isNotEmpty) ...[
                    _buildPlaybookBox(e.key, e.value),
                    const SizedBox(height: 10),
                  ],
                if (current.roles.isNotEmpty) ...[
                  const Text('Ideal Roles',
                      style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4338CA))),
                  const SizedBox(height: 6),
                  Wrap(
                    spacing: 6,
                    runSpacing: 6,
                    children: current.roles
                        .map((role) => _pill(role, const Color(0xFFEEF2FF),
                        const Color(0xFF4338CA)))
                        .toList(),
                  ),
                  const SizedBox(height: 10),
                ],
               /* const SizedBox(height: 4),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: (){}, *//*=> _openCounselor(context,
                        'How can I make the most of my personality as a ${current.title.toLowerCase()}?'),*//*
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFEEF2FF),
                      foregroundColor: const Color(0xFF4338CA),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    icon: const Icon(Icons.chat_bubble_outline_rounded, size: 16),
                    label: const Text('Ask AI Counselor About This',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ),*/
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // TAB 4: Mentorship
  // ---------------------------------------------------------------------------

  Widget _buildMentorshipTab(
      BuildContext context, bool isNarrow,DakshPersonalityFullReport r) {
    final g = r.data.guidanceForParentsMentors;
    final m = r.data.keyMotivatorsPreferences;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _card(
          isNarrow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _cardTitle(context, 'Parent & Mentor Playbook',
                  'Guidelines to unlock full potential'),
              const SizedBox(height: 14),
              _buildPlaybookBox('Mentorship Guideline', g.mentorshipGuideline),
              const SizedBox(height: 10),
              _buildPlaybookBox('Communication Key', g.communicationKey),
              const SizedBox(height: 10),
              _buildPlaybookBox(
                  'Growth Exercise: ${g.growthExercise.title}',
                  g.growthExercise.description),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          isNarrow,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Key Motivators & Preferences',
                  style: TextStyle(
                      fontSize: context.scaleFont(15),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary)),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFECFDF5),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFA7F3D0))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('🔥 What Fuels The Engine:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF065F46))),
                    const SizedBox(height: 4),
                    Text(
                      m.whatFuelsTheEngine,
                      style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFF047857),
                          height: 1.35),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: const Color(0xFFFEF2F2),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFFECDD3))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('⚠️ What Drains Energy:',
                        style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF9F1239))),
                    const SizedBox(height: 4),
                    Text(
                      m.whatDrainsEnergy,
                      style: const TextStyle(
                          fontSize: 11.5,
                          color: Color(0xFFBE123C),
                          height: 1.35),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _card(
          isNarrow,
          color: const Color(0xFFEFF6FF),
          borderColor: const Color(0xFFBFDBFE),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: const [
                  Text('🤖', style: TextStyle(fontSize: 18)),
                  SizedBox(width: 8),
                  Text('Ask Vayo AI Custom Advice',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A))),
                ],
              ),
              const SizedBox(height: 6),
              const Text(
                'Ask our AI counselor specific questions about subject choices, stream selections, or study habits tailored to this personality.',
                style: TextStyle(
                    fontSize: 11.5, color: Color(0xFF2563EB), height: 1.35),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {},/*=> _openCounselor(context,
                      'Give me custom advice for subject and stream selections.'),*/
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Launch Tailored Counselor Chat >',
                      style: TextStyle(
                          fontSize: 12.5, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaybookBox(String title, String desc) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(14)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF4338CA))),
          const SizedBox(height: 4),
          Text(desc,
              style: const TextStyle(
                  fontSize: 11.5, color: Color(0xFF334155), height: 1.35)),
        ],
      ),
    );
  }
}

class _StageInfo {
  final String title;
  final String subtitle;
  final IconData icon;
  final List<MapEntry<String, String>> entries;
  final List<String> roles;

  _StageInfo({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.entries,
    this.roles = const [],
  });
}

class _QuadrantCard extends StatelessWidget {
  final String title;
  final String score;
  final String subtitle;
  final Color bgColor;
  final Color borderColor;
  final Color titleColor;

  const _QuadrantCard({
    required this.title,
    required this.score,
    required this.subtitle,
    required this.bgColor,
    required this.borderColor,
    required this.titleColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(title,
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: titleColor)),
              ),
              const SizedBox(width: 8),
              Text(score,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: titleColor)),
            ],
          ),
          const SizedBox(height: 4),
          Text(subtitle,
              style: const TextStyle(
                  fontSize: 11, color: Color(0xFF64748B), height: 1.3)),
        ],
      ),
    );
  }
}