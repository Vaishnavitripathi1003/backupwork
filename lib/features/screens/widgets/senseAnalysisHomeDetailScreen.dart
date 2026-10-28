import 'package:daksh/data/models/sensesAnalysisResponse.dart';
import 'package:flutter/material.dart';

import '../../../core/models/reportResponse.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';


/// Screen for displaying the detailed 5 Senses Analysis & Learning Preferences.
class SensesHomeDetailScreen extends StatefulWidget {
  final SensesData? senses;

  const SensesHomeDetailScreen({super.key, this.senses});

  @override
  State<SensesHomeDetailScreen> createState() => _SensesHomeDetailScreenState();
}

class _SensesHomeDetailScreenState extends State<SensesHomeDetailScreen> {
  double _toPercentage(double? val) {
    if (val == null) return 0.0;
    return val <= 1.0 ? (val * 100) : val;
  }

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;

    final s = widget.senses;

    final vision = _toPercentage(s?.see ?? 0.88);
    final hearing = _toPercentage(s?.listen ?? 0.76);
    final touch = _toPercentage(s?.touch ?? 0.82);
    final smell = _toPercentage(s?.smell ?? 0.58);
    final taste = _toPercentage(s?.taste ?? 0.62);

    // ---- Calculate top sense from values ----
    final sensesMap = <String, double>{
      'Vision': vision,
      'Hearing': hearing,
      'Touch': touch,
      'Smell': smell,
      'Taste': taste,
    };
    final topEntry = sensesMap.entries.reduce((a, b) => b.value > a.value ? b : a);
    final topName = topEntry.key;
    final topVal = topEntry.value;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '5 Senses Analysis',
          style: TextStyle(
            fontSize: context.scaleFont(18),
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        centerTitle: false,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: const [
                  Icon(Icons.lock_rounded, size: 12, color: Color(0xFFD97706)),
                  SizedBox(width: 4),
                  Text(
                    'Preview',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFB45309),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Free Tier Status Teaser Banner
                  _buildStatusTeaserBanner(context, isNarrow),

                  const SizedBox(height: 16),

                  // 2. Top Sense Summary Card
                  _buildTopSenseSummaryCard(context, isNarrow, topName, topVal),

                  const SizedBox(height: 16),

                  // 3. Vision (Visual) Sense Card
                  _buildSenseCard(
                    context: context,
                    iconWidget: const Icon(Icons.remove_red_eye_outlined,
                        color: Color(0xFF2563EB), size: 22),
                    iconBg: const Color(0xFFEFF6FF),
                    title: 'Vision',
                    subtitleTag: '(Visual)',
                    description:
                    'You prefer visual learning through images, diagrams, videos, and graphic mind maps.',
                    percentage: '${vision.toStringAsFixed(0)}%',
                    tagLabel: 'Dominant',
                    tagBg: const Color(0xFF2563EB),
                    tagText: Colors.white,
                    cardBg: const Color(0xFFEFF6FF),
                    borderColor: const Color(0xFFBFDBFE),
                    percentColor: const Color(0xFF2563EB),
                  ),

                  const SizedBox(height: 14),

                  // 4. Hearing (Auditory) Sense Card
                  _buildSenseCard(
                    context: context,
                    iconWidget: const Icon(Icons.graphic_eq_rounded,
                        color: Color(0xFF059669), size: 22),
                    iconBg: const Color(0xFFECFDF5),
                    title: 'Hearing',
                    subtitleTag: '(Auditory)',
                    description:
                    'You learn effectively through listening, discussions, spoken explanations, and auditory lectures.',
                    percentage: '${hearing.toStringAsFixed(0)}%',
                    tagLabel: 'Strong',
                    tagBg: const Color(0xFF059669),
                    tagText: Colors.white,
                    cardBg: const Color(0xFFECFDF5),
                    borderColor: const Color(0xFFA7F3D0),
                    percentColor: const Color(0xFF059669),
                  ),

                  const SizedBox(height: 14),

                  // 5. Touch (Kinesthetic) Sense Card
                  _buildSenseCard(
                    context: context,
                    iconWidget: const Icon(Icons.back_hand_outlined,
                        color: Color(0xFFEA580C), size: 20),
                    iconBg: const Color(0xFFFFEDD5),
                    title: 'Touch',
                    subtitleTag: '(Kinesthetic)',
                    description:
                    'You learn best through hands-on practice, physical activity, and tactile experiences. Physical engagement drives your deepest focus.',
                    percentage: '${touch.toStringAsFixed(0)}%',
                    tagLabel: 'Strong',
                    tagBg: const Color(0xFFEA580C),
                    tagText: Colors.white,
                    cardBg: const Color(0xFFFFFBEB),
                    borderColor: const Color(0xFFFED7AA),
                    percentColor: const Color(0xFFEA580C),
                  ),

                  const SizedBox(height: 14),

                  // 6. Smell (Olfactory) Sense Card
                  _buildSenseCard(
                    context: context,
                    iconWidget: const Icon(Icons.air_rounded,
                        color: Color(0xFF7C3AED), size: 22),
                    iconBg: const Color(0xFFF3E8FF),
                    title: 'Smell',
                    subtitleTag: '(Olfactory)',
                    description:
                    'You have moderate sensitivity to smell-based experiences and olfactory environmental anchors.',
                    percentage: '${smell.toStringAsFixed(0)}%',
                    tagLabel: 'Moderate',
                    tagBg: const Color(0xFF7C3AED),
                    tagText: Colors.white,
                    cardBg: const Color(0xFFFAF5FF),
                    borderColor: const Color(0xFFE9D5FF),
                    percentColor: const Color(0xFF7C3AED),
                  ),

                  const SizedBox(height: 14),

                  // 7. Taste (Gustatory) Sense Card
                  _buildSenseCard(
                    context: context,
                    iconWidget: const Icon(Icons.restaurant_rounded,
                        color: Color(0xFFE11D48), size: 20),
                    iconBg: const Color(0xFFFFE4E6),
                    title: 'Taste',
                    subtitleTag: '(Gustatory)',
                    description:
                    'You have a moderate connection with taste, flavor experiences, and sensory engagement through food and beverages.',
                    percentage: '${taste.toStringAsFixed(0)}%',
                    tagLabel: 'Moderate',
                    tagBg: const Color(0xFFE11D48),
                    tagText: Colors.white,
                    cardBg: const Color(0xFFFEF2F2),
                    borderColor: const Color(0xFFFECDD3),
                    percentColor: const Color(0xFFE11D48),
                  ),

                  const SizedBox(height: 18),

                  // 8. Sensory AI Insight Banner
                  /* _buildSensoryAiInsightBanner(
                      context, isNarrow, topName, topVal),*/

                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Floating Ask Vayo Widget
            /*  const Positioned(
              right: 16,
              bottom: 20,
              child: AskVayoFloatingWidget(),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildStatusTeaserBanner(BuildContext context, bool isNarrow) {
    return Container(
      padding: EdgeInsets.all(isNarrow ? 12 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFBEB),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
      ),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.lock_rounded, size: 20, color: Color(0xFFD97706)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Free Tier: Status Teaser',
                  style: TextStyle(
                    fontSize: context.scaleFont(13),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF92400E),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Sensory percentages shown below. Detailed multi-modal study drills & tactile career links lock until Premium.',
                  style: TextStyle(
                    fontSize: context.scaleFont(11),
                    color: const Color(0xFFB45309),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEA580C),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Unlock',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSenseSummaryCard(
      BuildContext context, bool isNarrow, String topName, double topVal) {
    return Container(
      padding: EdgeInsets.all(isNarrow ? 14 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFFFE4E6),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(Icons.home_outlined, color: Color(0xFFF43F5E), size: 26),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      topName, // bound: top sense name
                      style: TextStyle(
                        fontSize: context.scaleFont(14),
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Top Sense',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFD97706),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'Your strongest sense is ${topName.toLowerCase()}', // bound
                  style: TextStyle(
                    fontSize: context.scaleFont(11.5),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF7C3AED),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Ring Chart Percentage Indicator
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 52,
                  height: 52,
                  child: CircularProgressIndicator(
                    value: (topVal / 100.0).clamp(0.0, 1.0),
                    strokeWidth: 6,
                    backgroundColor: const Color(0xFFE0F2FE),
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                ),
                Text(
                  '${topVal.toStringAsFixed(0)}%',
                  style: TextStyle(
                    fontSize: context.scaleFont(13),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSenseCard({
    required BuildContext context,
    required Widget iconWidget,
    required Color iconBg,
    required String title,
    required String subtitleTag,
    required String description,
    required String percentage,
    required String tagLabel,
    required Color tagBg,
    required Color tagText,
    required Color cardBg,
    required Color borderColor,
    required Color percentColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardBg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Left Sense Icon Container
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(child: iconWidget),
          ),

          const SizedBox(width: 12),

          // Middle Details Column
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: title,
                        style: TextStyle(
                          fontSize: context.scaleFont(15),
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      /*TextSpan(
                        text: ' $subtitleTag',
                        style: TextStyle(
                          fontSize: context.scaleFont(13),
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF64748B),
                        ),
                      ),*/
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: context.scaleFont(11.5),
                    color: const Color(0xFF475569),
                    height: 1.35,
                  ),
                ),
                const SizedBox(height: 10),

                // Tags Row (e.g. Dominant / Strong + Deep Details)
                /* Wrap(
                  spacing: 6,
                  runSpacing: 4,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: tagBg,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        tagLabel,
                        style: TextStyle(
                          fontSize: 10.5,
                          fontWeight: FontWeight.bold,
                          color: tagText,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: const Color(0xFFFDE68A)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(Icons.lock_rounded,
                              size: 10, color: Color(0xFFD97706)),
                          SizedBox(width: 3),
                          Text(
                            'Deep details',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),*/
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right Column (Percentage + Lock Icon Box)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                percentage,
                style: TextStyle(
                  fontSize: context.scaleFont(16),
                  fontWeight: FontWeight.w900,
                  color: percentColor,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Center(
                  child:
                  Icon(Icons.lock_rounded, size: 13, color: Color(0xFFD97706)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSensoryAiInsightBanner(
      BuildContext context, bool isNarrow, String topName, double topVal) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF6366F1), // Indigo
            Color(0xFF8B5CF6), // Purple
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: const [
                    Icon(Icons.star_rate_rounded,
                        size: 18, color: Colors.white),
                    SizedBox(width: 6),
                    Text(
                      'Sensory AI Insight',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text.rich(
                  TextSpan(
                    children: [
                      const TextSpan(text: 'Your strongest sense is '),
                      TextSpan(
                        text: '$topName (${topVal.toStringAsFixed(0)}%)', // bound
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                      const TextSpan(
                        text:
                        '. Multi-sensory memory retention is strongest through this sense.',
                      ),
                    ],
                  ),
                  style: TextStyle(
                    fontSize: context.scaleFont(12),
                    color: const Color(0xFFE0E7FF),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),

          // Sensory Tree Graphic Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(Icons.account_tree_rounded,
                  color: Colors.white, size: 26),
            ),
          ),
        ],
      ),
    );
  }
}
