/*
import 'package:flutter/material.dart';
import '../../core/models/reportResponse.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'widgets/ask_vayo_overlay.dart';

/// Screen for displaying the detailed Brain Dominance Hemispheric Breakdown.
class BrainDominanceDetailScreen extends StatefulWidget {
  final BrainDominance? brainDominance;

  const BrainDominanceDetailScreen({super.key, this.brainDominance});

  @override
  State<BrainDominanceDetailScreen> createState() =>
      _BrainDominanceDetailScreenState();
}

class _BrainDominanceDetailScreenState
    extends State<BrainDominanceDetailScreen> {

  double _toPercentage(double? val) {
    if (val == null) return 0.0;
    return val <= 1.0 ? (val * 100) : val;
  }

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;

    final bd = widget.brainDominance;

    final rightBrain =
        _toPercentage(bd?.rightBrain ?? 0.62);
    final leftBrain =
        _toPercentage(bd?.leftBrain ?? 0.38);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Brain Dominance',
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

                  const SizedBox(height: 14),

                  // 2. Subtitle Note
                  Center(
                    child: Text(
                      'Understand which side of your brain you naturally use more.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.scaleFont(12.5),
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Overall Brain Balance Card
                  _buildOverallBalanceCard(
                      context, isNarrow, rightBrain, leftBrain),

                  const SizedBox(height: 20),

                  // 4. Brain Hemispheres Graphic Comparison Section
                  _buildBrainComparisonSection(
                      context, isNarrow, rightBrain, leftBrain),

                  const SizedBox(height: 20),

                  // 5. Natural Usage Insight Box
                  _buildNaturalUsageBox(context, isNarrow, rightBrain > leftBrain),

                  const SizedBox(height: 20),

                  // 6. Brain Trait Scores Progress List
                  _buildTraitProgressRow(
                    context: context,
                    icon: '💡',
                    iconBg: const Color(0xFFFAF5FF),
                    title: 'Imagination',
                    progress: rightBrain / 100.0,
                    percent: '${rightBrain.toStringAsFixed(0)}%',
                    barColor: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 14),

                  _buildTraitProgressRow(
                    context: context,
                    icon: '❤️',
                    iconBg: const Color(0xFFFFE4E6),
                    title: 'Intuition',
                    progress: (rightBrain * 0.9) / 100.0,
                    percent: '${(rightBrain * 0.9).toStringAsFixed(0)}%',
                    barColor: const Color(0xFFF43F5E),
                  ),
                  const SizedBox(height: 14),

                  _buildTraitProgressRow(
                    context: context,
                    icon: '🎨',
                    iconBg: const Color(0xFFFEF08A),
                    title: 'Creativity',
                    progress: (rightBrain * 0.95) / 100.0,
                    percent: '${(rightBrain * 0.95).toStringAsFixed(0)}%',
                    barColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 14),

                  _buildTraitProgressRow(
                    context: context,
                    icon: '⚙️',
                    iconBg: const Color(0xFFEFF6FF),
                    title: 'Logic',
                    progress: leftBrain / 100.0,
                    percent: '${leftBrain.toStringAsFixed(0)}%',
                    barColor: const Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 14),

                  _buildTraitProgressRow(
                    context: context,
                    icon: '📊',
                    iconBg: const Color(0xFFECFDF5),
                    title: 'Analysis',
                    progress: (leftBrain * 0.9) / 100.0,
                    percent: '${(leftBrain * 0.9).toStringAsFixed(0)}%',
                    barColor: const Color(0xFF10B981),
                  ),

                  const SizedBox(height: 24),

                  // 7. Unlock Full Brain Report Banner
                  _buildUnlockBanner(context, isNarrow),

                  const SizedBox(height: 80),
                ],
              ),
            ),

            // Floating Ask Vayo Widget
          */
/*  const Positioned(
              right: 16,
              bottom: 20,
              child: AskVayoFloatingWidget(),
            ),*//*

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
              child: Icon(Icons.lock_rounded,
                  size: 20, color: Color(0xFFD97706)),
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
                  'Hemispheric balance shown below. Deep analytical vs creative cognitive drills lock until Premium.',
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
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
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

  Widget _buildOverallBalanceCard(
      BuildContext context, bool isNarrow, double right, double left) {
    final isRightDominant = right >= left;
    final dominantTitle = isRightDominant
        ? 'Right Brain Dominant'
        : 'Left Brain Dominant';
    final dominantVal = isRightDominant ? right : left;

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
              child:
              Center(
                child: Text('🧠', style: TextStyle(fontSize: 30)),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Brain Balance',
                  style: TextStyle(
                    fontSize: context.scaleFont(14),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dominantTitle,
                  style: TextStyle(
                    fontSize: context.scaleFont(13),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),

          // Ring Chart Indicator
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
                    value: (dominantVal / 100.0).clamp(0.0, 1.0),
                    strokeWidth: 6,
                    backgroundColor: const Color(0xFFE0F2FE),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                ),
                Text(
                  '${dominantVal.toStringAsFixed(0)}%',
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

  Widget _buildBrainComparisonSection(
      BuildContext context, bool isNarrow, double right, double left) {
    return Container(
      padding: EdgeInsets.symmetric(
          vertical: isNarrow ? 12 : 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Brain Column
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Left Brain',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${left.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: context.scaleFont(22),
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF2563EB),
                ),
              ),
              const Text(
                'Analytical',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.track_changes_rounded,
                      color: Color(0xFF2563EB), size: 22),
                ),
              ),
            ],
          ),

          // Center Glowing Brain Sphere
          Container(
            width: isNarrow ? 120 : 140,
            height: isNarrow ? 120 : 140,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  const Color(0xFFF3E8FF),
                  const Color(0xFFFAF5FF).withValues(alpha: 0.5),
                  Colors.white.withValues(alpha: 0.0),
                ],
                radius: 0.85,
              ),
            ),
            child: const Center(
              child: Text('🧠', style: TextStyle(fontSize: 54)),
            ),
          ),

          // Right Brain Column
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Right Brain',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${right.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: context.scaleFont(22),
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFFEC4899),
                ),
              ),
              const Text(
                'Creative',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFFCE7F3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.lightbulb_outline_rounded,
                      color: Color(0xFFEC4899), size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNaturalUsageBox(
      BuildContext context, bool isNarrow, bool isRightDominant) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isNarrow ? 14 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
      ),
      child: Column(
        children: [
          Text(
            isRightDominant
                ? 'You use your Right Brain more naturally.'
                : 'You use your Left Brain more naturally.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.scaleFont(13.5),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isRightDominant
                ? 'You are imaginative, intuitive and creative.'
                : 'You are logical, analytical and detail-oriented.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.scaleFont(12),
              color: const Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitProgressRow({
    required BuildContext context,
    required String icon,
    required Color iconBg,
    required String title,
    required double progress,
    required String percent,
    required Color barColor,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: context.responsiveValue(mobile: 90, tablet: 120),
          child: Text(
            title,
            style: TextStyle(
              fontSize: context.scaleFont(13),
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          percent,
          style: TextStyle(
            fontSize: context.scaleFont(13),
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockBanner(BuildContext context, bool isNarrow) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 14 : 18,
        vertical: isNarrow ? 14 : 16,
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
        borderRadius: BorderRadius.circular(18),
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
          const Icon(Icons.lock_rounded, size: 16, color: Color(0xFFFEF08A)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Unlock Full Brain Report & Drills 👑',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.scaleFont(12.5),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
*/
import 'package:flutter/material.dart';
import '../../core/models/reportResponse.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'widgets/ask_vayo_overlay.dart';

/// Screen for displaying the detailed Brain Dominance Hemispheric Breakdown.
class BrainDominanceDetailScreen extends StatefulWidget {
  final BrainDominance? brainDominance;

  const BrainDominanceDetailScreen({super.key, this.brainDominance});

  @override
  State<BrainDominanceDetailScreen> createState() =>
      _BrainDominanceDetailScreenState();
}

class _BrainDominanceDetailScreenState
    extends State<BrainDominanceDetailScreen> {
  // Hemisphere colors (used by the brain graphic AND the Left/Right columns)
  static const Color _leftColor = Color(0xFF2563EB); // blue  - Left / Analytical
  static const Color _rightColor = Color(0xFFEC4899); // pink - Right / Creative

  double _toPercentage(double? val) {
    if (val == null) return 0.0;
    return val <= 1.0 ? (val * 100) : val;
  }

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;

    final bd = widget.brainDominance;

    final rightBrain = _toPercentage(bd?.rightBrain ?? 0.62);
    final leftBrain = _toPercentage(bd?.leftBrain ?? 0.38);

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Brain Dominance',
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

                  const SizedBox(height: 14),

                  // 2. Subtitle Note
                  Center(
                    child: Text(
                      'Understand which side of your brain you naturally use more.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.scaleFont(12.5),
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 3. Overall Brain Balance Card
                  _buildOverallBalanceCard(
                      context, isNarrow, rightBrain, leftBrain),

                  const SizedBox(height: 20),

                  // 4. Brain Hemispheres Graphic Comparison Section
                  _buildBrainComparisonSection(
                      context, isNarrow, rightBrain, leftBrain),

                  const SizedBox(height: 20),

                  // 5. Natural Usage Insight Box
                  _buildNaturalUsageBox(
                      context, isNarrow, rightBrain > leftBrain),

                  const SizedBox(height: 20),

                  // 6. Brain Trait Scores Progress List
                  _buildTraitProgressRow(
                    context: context,
                    icon: '💡',
                    iconBg: const Color(0xFFFAF5FF),
                    title: 'Imagination',
                    progress: rightBrain / 100.0,
                    percent: '${rightBrain.toStringAsFixed(0)}%',
                    barColor: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 14),

                  _buildTraitProgressRow(
                    context: context,
                    icon: '❤️',
                    iconBg: const Color(0xFFFFE4E6),
                    title: 'Intuition',
                    progress: (rightBrain * 0.9) / 100.0,
                    percent: '${(rightBrain * 0.9).toStringAsFixed(0)}%',
                    barColor: const Color(0xFFF43F5E),
                  ),
                  const SizedBox(height: 14),

                  _buildTraitProgressRow(
                    context: context,
                    icon: '🎨',
                    iconBg: const Color(0xFFFEF08A),
                    title: 'Creativity',
                    progress: (rightBrain * 0.95) / 100.0,
                    percent: '${(rightBrain * 0.95).toStringAsFixed(0)}%',
                    barColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 14),

                  _buildTraitProgressRow(
                    context: context,
                    icon: '⚙️',
                    iconBg: const Color(0xFFEFF6FF),
                    title: 'Logic',
                    progress: leftBrain / 100.0,
                    percent: '${leftBrain.toStringAsFixed(0)}%',
                    barColor: const Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 14),

                  _buildTraitProgressRow(
                    context: context,
                    icon: '📊',
                    iconBg: const Color(0xFFECFDF5),
                    title: 'Analysis',
                    progress: (leftBrain * 0.9) / 100.0,
                    percent: '${(leftBrain * 0.9).toStringAsFixed(0)}%',
                    barColor: const Color(0xFF10B981),
                  ),

                  const SizedBox(height: 24),

                  // 7. Unlock Full Brain Report Banner
                //  _buildUnlockBanner(context, isNarrow),

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
              child: Icon(Icons.lock_rounded,
                  size: 20, color: Color(0xFFD97706)),
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
                  'Hemispheric balance shown below. Deep analytical vs creative cognitive drills lock until Premium.',
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
              padding:
              const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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

  Widget _buildOverallBalanceCard(
      BuildContext context, bool isNarrow, double right, double left) {
    final isRightDominant = right >= left;
    final dominantTitle =
    isRightDominant ? 'Right Brain Dominant' : 'Left Brain Dominant';
    final dominantVal = isRightDominant ? right : left;
    final dominantColor = isRightDominant ? _rightColor : _leftColor;

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
              child: Text('🧠', style: TextStyle(fontSize: 30)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Overall Brain Balance',
                  style: TextStyle(
                    fontSize: context.scaleFont(14),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  dominantTitle,
                  style: TextStyle(
                    fontSize: context.scaleFont(13),
                    fontWeight: FontWeight.bold,
                    color: dominantColor,
                  ),
                ),
              ],
            ),
          ),

          // Ring Chart Indicator
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
                    value: (dominantVal / 100.0).clamp(0.0, 1.0),
                    strokeWidth: 6,
                    backgroundColor: dominantColor.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(dominantColor),
                  ),
                ),
                Text(
                  '${dominantVal.toStringAsFixed(0)}%',
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

  Widget _buildBrainComparisonSection(
      BuildContext context, bool isNarrow, double right, double left) {
    return Container(
      padding:
      EdgeInsets.symmetric(vertical: isNarrow ? 12 : 16, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Left Brain Column
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Left Brain',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${left.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: context.scaleFont(22),
                  fontWeight: FontWeight.w900,
                  color: _leftColor,
                ),
              ),
              const Text(
                'Analytical',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFEFF6FF),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.track_changes_rounded,
                      color: _leftColor, size: 22),
                ),
              ),
            ],
          ),

          // Center Two-Tone Brain (left = blue, right = pink)
          _buildColoredBrain(
            size: isNarrow ? 120 : 140,
            left: left,
            right: right,
          ),

          // Right Brain Column
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Right Brain',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '${right.toStringAsFixed(0)}%',
                style: TextStyle(
                  fontSize: context.scaleFont(22),
                  fontWeight: FontWeight.w900,
                  color: _rightColor,
                ),
              ),
              const Text(
                'Creative',
                style: TextStyle(fontSize: 11, color: Color(0xFF64748B)),
              ),
              const SizedBox(height: 10),
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: Color(0xFFFCE7F3),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.lightbulb_outline_rounded,
                      color: _rightColor, size: 22),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Brain emoji split down the middle: left half blue, right half pink.
  /// The color strength of each half follows its percentage.
  Widget _buildColoredBrain({
    required double size,
    required double left,
    required double right,
  }) {
    // Stronger color for the side with the higher percentage
    double intensity(double pct) =>
        (0.35 + 0.55 * (pct / 100.0)).clamp(0.35, 0.9);

    final leftTint = _leftColor.withValues(alpha: intensity(left));
    final rightTint = _rightColor.withValues(alpha: intensity(right));

    final isRightDominant = right >= left;
    final glowColor = isRightDominant ? _rightColor : _leftColor;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Soft glow behind the brain, in the dominant side's color
          Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  glowColor.withValues(alpha: 0.18),
                  glowColor.withValues(alpha: 0.06),
                  Colors.white.withValues(alpha: 0.0),
                ],
                radius: 0.85,
              ),
            ),
          ),

          // Brain emoji tinted with a hard split: left blue, right pink
          ShaderMask(
            blendMode: BlendMode.srcATop,
            shaderCallback: (Rect bounds) {
              return LinearGradient(
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
                colors: [leftTint, leftTint, rightTint, rightTint],
                stops: const [0.0, 0.5, 0.5, 1.0],
              ).createShader(bounds);
            },
            child: Text(
              '🧠',
              style: TextStyle(fontSize: size * 0.42),
            ),
          ),

          // Thin center divider between hemispheres
          Container(
            width: 1.5,
            height: size * 0.40,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.9),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNaturalUsageBox(
      BuildContext context, bool isNarrow, bool isRightDominant) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isNarrow ? 14 : 16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFBFDBFE), width: 1),
      ),
      child: Column(
        children: [
          Text(
            isRightDominant
                ? 'You use your Right Brain more naturally.'
                : 'You use your Left Brain more naturally.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.scaleFont(13.5),
              fontWeight: FontWeight.bold,
              color: const Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isRightDominant
                ? 'You are imaginative, intuitive and creative.'
                : 'You are logical, analytical and detail-oriented.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: context.scaleFont(12),
              color: const Color(0xFF3B82F6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTraitProgressRow({
    required BuildContext context,
    required String icon,
    required Color iconBg,
    required String title,
    required double progress,
    required String percent,
    required Color barColor,
  }) {
    return Row(
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: iconBg,
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(icon, style: const TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: context.responsiveValue(mobile: 90, tablet: 120),
          child: Text(
            title,
            style: TextStyle(
              fontSize: context.scaleFont(13),
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: const Color(0xFFF1F5F9),
              valueColor: AlwaysStoppedAnimation<Color>(barColor),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          percent,
          style: TextStyle(
            fontSize: context.scaleFont(13),
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildUnlockBanner(BuildContext context, bool isNarrow) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 14 : 18,
        vertical: isNarrow ? 14 : 16,
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
        borderRadius: BorderRadius.circular(18),
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
          const Icon(Icons.lock_rounded, size: 16, color: Color(0xFFFEF08A)),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              'Unlock Full Brain Report & Drills 👑',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.scaleFont(12.5),
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}