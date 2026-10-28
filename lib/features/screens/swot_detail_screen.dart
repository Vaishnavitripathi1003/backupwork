import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/Global/global_class.dart';
import '../../core/network/api_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import '../../core/storage/user_pref.dart';
import '../../data/models/personalityswotmodel.dart';
import 'widgets/swot_content.dart';

/// Complete SWOT Analysis & Recommendations Screen.
/// Fetches and displays real SWOT & Recommendations data for the globally selected candidate.
class SwotDetailScreen extends StatefulWidget {
  final String? primary;
  final String? secondary;
  final bool initialShowRecommendations;

  const SwotDetailScreen({
    super.key,
    this.primary,
    this.secondary,
    this.initialShowRecommendations = false,
  });

  @override
  State<SwotDetailScreen> createState() => _SwotDetailScreenState();
}

class _SwotDetailScreenState extends State<SwotDetailScreen> {
  late bool _showRecommendations;
  bool _showSecondary = false; // false = Primary tab

  bool _isLoading = true;
  String? _errorMessage;

  PersonalitySwotResponse? _swotResponse;
  PersonalityRecommendationsResponse? _recommendationsResponse;

  @override
  void initState() {
    super.initState();
    _showRecommendations = widget.initialShowRecommendations;
    _fetchSwotData();
  }

  Future<void> _fetchSwotData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = UserPref(prefs).getToken() ?? '';
      final userDataId = GlobalClass.selected_member.trim();

      if (token.isEmpty || userDataId.isEmpty) {
        throw Exception('Missing login session or selected user ID.');
      }

      final api = ApiService();
      final responses = await Future.wait([
        api.findDiscPersonalityCombinationsSwotAnalysisByUserDataId(
          auth: token,
          userDataId: userDataId,
        ),
        api.findDiscPersonalityCombinationsRecommendationsByUserDataId(
          auth: token,
          userDataId: userDataId,
        ),
      ]);

      final swotRes = responses[0];
      final recRes = responses[1];

      PersonalitySwotResponse? swotData;
      PersonalityRecommendationsResponse? recData;

      if (swotRes.statusCode == 200 && swotRes.data != null) {
        swotData = PersonalitySwotResponse.fromJson(swotRes.data);
      }
      if (recRes.statusCode == 200 && recRes.data != null) {
        recData = PersonalityRecommendationsResponse.fromJson(recRes.data);
      }

      if (!mounted) return;
      setState(() {
        _swotResponse = swotData;
        _recommendationsResponse = recData;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('Error fetching SWOT data: $e');
      if (!mounted) return;
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String get _primaryText {
    final apiVal = _swotResponse?.personality.primary ?? '';
    if (apiVal.isNotEmpty) return apiVal;
    if (widget.primary?.trim().isNotEmpty ?? false) return widget.primary!.trim();
    return "";
  }

  String get _secondaryText {
    final apiVal = _swotResponse?.personality.secondary ?? '';
    if (apiVal.isNotEmpty) return apiVal;
    if (widget.secondary?.trim().isNotEmpty ?? false) return widget.secondary!.trim();
    return "";
  }

  /// True when Secondary is missing or identical to Primary.
  bool get _isSameType {
    final p = _primaryText.toLowerCase();
    final s = _secondaryText.toLowerCase();
    return s.isEmpty || p == s;
  }

  /// Always falls back to Primary when only one tab is shown.
  String get _selectedText =>
      (_showSecondary && !_isSameType) ? _secondaryText : _primaryText;

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;

    final selectedLabel =
        (_selectedText.trim().isNotEmpty) ? _selectedText : 'Dominant';
    final fallbackSwot = SwotResult.from(_selectedText, null);

    final List<String> strengths = (_swotResponse?.data.strengths.isNotEmpty ?? false)
        ? _swotResponse!.data.strengths
        : fallbackSwot.strengths;

    final List<String> weaknesses = (_swotResponse?.data.weaknesses.isNotEmpty ?? false)
        ? _swotResponse!.data.weaknesses
        : fallbackSwot.weaknesses;

    final List<String> opportunities = (_swotResponse?.data.opportunities.isNotEmpty ?? false)
        ? _swotResponse!.data.opportunities
        : fallbackSwot.opportunities;

    final List<String> threats = (_swotResponse?.data.threats.isNotEmpty ?? false)
        ? _swotResponse!.data.threats
        : fallbackSwot.threats;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppTheme.textPrimary),
          onPressed: () {
            if (_showRecommendations) {
              setState(() => _showRecommendations = false);
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _showRecommendations ? 'Recommendations' : 'SWOT Analysis',
          style: TextStyle(
            fontSize: context.scaleFont(18),
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: AppTheme.textPrimary),
            onPressed: _fetchSwotData,
            tooltip: 'Refresh SWOT Data',
          ),
        ],
      ),
      body: SafeArea(
        child: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF2563EB),
                ),
              )
            : _errorMessage != null && _swotResponse == null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              size: 48, color: Colors.redAccent),
                          const SizedBox(height: 12),
                          Text(
                            'Failed to load SWOT data',
                            style: TextStyle(
                              fontSize: context.scaleFont(16),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            _errorMessage!,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: _fetchSwotData,
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
                : Stack(
                    children: [
                      SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
                        child: AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          child: _showRecommendations
                              ? _buildRecommendationsView(context, isNarrow)
                              : _buildSwotMatrixView(
                                  context,
                                  isNarrow,
                                  selectedLabel,
                                  strengths,
                                  weaknesses,
                                  opportunities,
                                  threats,
                                ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  // ───────────────────────── SWOT MATRIX VIEW ─────────────────────────

  Widget _buildSwotMatrixView(
    BuildContext context,
    bool isNarrow,
    String label,
    List<String> strengths,
    List<String> weaknesses,
    List<String> opportunities,
    List<String> threats,
  ) {
    final bool isEmpty = strengths.isEmpty &&
        weaknesses.isEmpty &&
        opportunities.isEmpty &&
        threats.isEmpty;

    return Column(
      key: ValueKey('SwotMatrixView_$_showSecondary'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Primary / Secondary toggle
        _buildToggle(),
        const SizedBox(height: 14),

        if (isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 24),
            child: Center(
              child: Text(
                'No SWOT data available for "$label".',
                style: const TextStyle(fontSize: 12, color: Color(0xFF64748B)),
              ),
            ),
          )
        else ...[
          // Row 1: Strengths & Weaknesses
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSwotCard(
                  title: 'STRENGTHS',
                  titleColor: const Color(0xFF16A34A),
                  icon: Icons.fitness_center_rounded,
                  iconBg: const Color(0xFFDCFCE7),
                  iconColor: const Color(0xFF16A34A),
                  cardBg: const Color(0xFFF0FDF4),
                  borderColor: const Color(0xFFBBF7D0),
                  dotColor: const Color(0xFF16A34A),
                  items: strengths,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSwotCard(
                  title: 'WEAKNESSES',
                  titleColor: const Color(0xFFEA580C),
                  icon: Icons.link_rounded,
                  iconBg: const Color(0xFFFFEDD5),
                  iconColor: const Color(0xFFEA580C),
                  cardBg: const Color(0xFFFFFBEB),
                  borderColor: const Color(0xFFFED7AA),
                  dotColor: const Color(0xFFEA580C),
                  items: weaknesses,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // Row 2: Opportunities & Threats
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _buildSwotCard(
                  title: 'OPPORTUNITIES',
                  titleColor: const Color(0xFF2563EB),
                  icon: Icons.diamond_rounded,
                  iconBg: const Color(0xFFDBEAFE),
                  iconColor: const Color(0xFF2563EB),
                  cardBg: const Color(0xFFEFF6FF),
                  borderColor: const Color(0xFFBFDBFE),
                  dotColor: const Color(0xFF2563EB),
                  items: opportunities,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildSwotCard(
                  title: 'THREATS',
                  titleColor: const Color(0xFFE11D48),
                  icon: Icons.warning_amber_rounded,
                  iconBg: const Color(0xFFFFE4E6),
                  iconColor: const Color(0xFFE11D48),
                  cardBg: const Color(0xFFFEF2F2),
                  borderColor: const Color(0xFFFECDD3),
                  dotColor: const Color(0xFFE11D48),
                  items: threats,
                ),
              ),
            ],
          ),
        ],

        const SizedBox(height: 18),

        // AI Insight Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: const Color(0xFFE2E8F0)),
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
                children: const [
                  Icon(Icons.auto_awesome, size: 16, color: Color(0xFF7C3AED)),
                  SizedBox(width: 6),
                  Text(
                    'AI Insight',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF7C3AED),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                _aiInsightText(label),
                style: TextStyle(
                  fontSize: context.scaleFont(12.5),
                  color: const Color(0xFF334155),
                  height: 1.45,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // View Personalized Recommendations Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => setState(() => _showRecommendations = true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF2563EB),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'View Personalized Recommendations',
                  style: TextStyle(
                    fontSize: context.scaleFont(13),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              ],
            ),
          ),
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  String _aiInsightText(String label) {
    final d = _swotResponse?.data;
    if (d != null) {
      if (d.detailedStrengths.trim().isNotEmpty) {
        return d.detailedStrengths.trim();
      } else if (d.archetype.trim().isNotEmpty) {
        return '${d.archetype} (${d.combination}): Focus on leveraging key strengths while mitigating weaknesses for balanced growth.';
      }
    }
    return 'You exhibit strong $label leadership potential. Focus on improving patience and delegation skills to achieve even greater success in life.';
  }

  // ───────────────────────── PRIMARY / SECONDARY TOGGLE ─────────────────────────

  Widget _buildToggle() {
    Widget tab(String title, String? sub, bool selected, VoidCallback onTap) {
      return Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
            decoration: BoxDecoration(
              color: selected ? const Color(0xFF2563EB) : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected
                    ? const Color(0xFF2563EB)
                    : const Color(0xFFE2E8F0),
              ),
            ),
            child: Column(
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 10,
                    color: selected ? Colors.white70 : const Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  (sub?.trim().isNotEmpty ?? false) ? sub! : '--',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: selected ? Colors.white : const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    // Same type (or no secondary): show a single tab.
    if (_isSameType) {
      return Row(
        children: [
          tab('Primary & Secondary', _primaryText, true, () {}),
        ],
      );
    }

    return Row(
      children: [
        tab('Primary', _primaryText, !_showSecondary,
            () => setState(() => _showSecondary = false)),
        const SizedBox(width: 10),
        tab('Secondary', _secondaryText, _showSecondary,
            () => setState(() => _showSecondary = true)),
      ],
    );
  }

  // ───────────────────────── SWOT CARD ─────────────────────────

  Widget _buildSwotCard({
    required String title,
    required Color titleColor,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required Color cardBg,
    required Color borderColor,
    required Color dotColor,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon Circle
          Center(
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: iconBg,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 22),
            ),
          ),

          const SizedBox(height: 10),

          // Title
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.5,
                color: titleColor,
              ),
            ),
          ),

          const SizedBox(height: 12),

          if (items.isEmpty)
            const Text(
              '--',
              style: TextStyle(fontSize: 11.5, color: Color(0xFF64748B)),
            ),

          // Items Bullet List
          for (final item in items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 5),
                  width: 5,
                  height: 5,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 11.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E293B),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
          ],
        ],
      ),
    );
  }

  // ───────────────────────── RECOMMENDATIONS VIEW ─────────────────────────

  Widget _buildRecommendationsView(BuildContext context, bool isNarrow) {
    final recs = _recommendationsResponse?.data.strategicRecommendations;

    final List<String> improveWeaknesses =
        (recs?.improveWeaknesses.isNotEmpty ?? false)
            ? recs!.improveWeaknesses
            : [
                'Practice patience with mindfulness exercises',
                'Join public speaking club',
                'Work on active listening skills',
                'Use daily planner for better consistency',
              ];

    final List<String> utilizeOpportunities =
        (recs?.utilizeOpportunities.isNotEmpty ?? false)
            ? recs!.utilizeOpportunities
            : [
                'Explore leadership development programs',
                'Participate in hackathons and competitions',
                'Network with industry professionals',
                'Take up entrepreneurial projects',
              ];

    final List<String> reduceThreats =
        (recs?.reduceThreats.isNotEmpty ?? false)
            ? recs!.reduceThreats
            : [
                'Follow a strict time management routine',
                'Avoid multitasking and social media distraction',
                'Take regular breaks to avoid burnout',
                'Practice stress management techniques',
              ];

    return Column(
      key: const ValueKey('RecommendationsView'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Improve Weaknesses Card
        _buildRecommendationCard(
          context: context,
          icon: Icons.link_rounded,
          iconBg: const Color(0xFFFFEDD5),
          iconColor: const Color(0xFFEA580C),
          title: 'Improve Weaknesses',
          titleColor: const Color(0xFFEA580C),
          cardBg: const Color(0xFFFFFBEB),
          borderColor: const Color(0xFFFED7AA),
          dotColor: const Color(0xFFEA580C),
          items: improveWeaknesses,
        ),

        const SizedBox(height: 16),

        // 2. Utilize Opportunities Card
        _buildRecommendationCard(
          context: context,
          icon: Icons.star_outline_rounded,
          iconBg: const Color(0xFFDBEAFE),
          iconColor: const Color(0xFF2563EB),
          title: 'Utilize Opportunities',
          titleColor: const Color(0xFF2563EB),
          cardBg: const Color(0xFFEFF6FF),
          borderColor: const Color(0xFFBFDBFE),
          dotColor: const Color(0xFF2563EB),
          items: utilizeOpportunities,
        ),

        const SizedBox(height: 16),

        // 3. Reduce Threats Card
        _buildRecommendationCard(
          context: context,
          icon: Icons.visibility_off_outlined,
          iconBg: const Color(0xFFFFE4E6),
          iconColor: const Color(0xFFE11D48),
          title: 'Reduce Threats',
          titleColor: const Color(0xFFE11D48),
          cardBg: const Color(0xFFFEF2F2),
          borderColor: const Color(0xFFFECDD3),
          dotColor: const Color(0xFFE11D48),
          items: reduceThreats,
        ),

        const SizedBox(height: 80),
      ],
    );
  }

  Widget _buildRecommendationCard({
    required BuildContext context,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required Color titleColor,
    required Color cardBg,
    required Color borderColor,
    required Color dotColor,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: iconBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Text(
                title,
                style: TextStyle(
                  fontSize: context.scaleFont(15),
                  fontWeight: FontWeight.bold,
                  color: titleColor,
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          for (final item in items) ...[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 6),
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: context.scaleFont(12.5),
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1E293B),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ],
      ),
    );
  }
}
