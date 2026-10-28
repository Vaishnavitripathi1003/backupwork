import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';
import 'widgets/ask_vayo_overlay.dart';

/// Complete Assessments Battery Screen matching the design screenshots.
class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Completed, 2: Recommended

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;

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

                  const SizedBox(height: 16),

                  // 2. Personality Type 100% Free Banner
                  _buildPersonalityFreeBanner(context, isNarrow),

                  const SizedBox(height: 16),

                  // 3. Filter Pills Row
                  _buildFilterPillsRow(context, isNarrow),

                  const SizedBox(height: 16),

                  // 4. Assessment Battery Cards
                  if (_selectedFilterIndex == 0 || _selectedFilterIndex == 1) ...[
                    // Test 1: DISC Behavioral Personality Blend
                    _buildAssessmentCard(
                      context: context,
                      category: 'PSYCHOLOGICAL',
                      badgeWidget: _buildTag('✨ 100% Free', const Color(0xFFECFDF5), const Color(0xFF059669)),
                      title: 'DISC Behavioral Personality Blend',
                      subtitle: 'Dominate 65% / Influential 35%',
                      subtitleColor: const Color(0xFF7C3AED),
                      emojiIcon: '🎯',
                      iconBgColor: const Color(0xFFFCE7F3),
                      isLocked: false,
                    ),

                    const SizedBox(height: 12),

                    // Test 2: DISC Behavioral & Cognitive Analysis
                    _buildAssessmentCard(
                      context: context,
                      category: 'COGNITIVE',
                      badgeWidget: _buildLockedBadge(),
                      title: 'DISC Behavioral & Cognitive Analysis',
                      subtitle: '96% Accuracy (Preview)',
                      subtitleColor: const Color(0xFF059669),
                      emojiIcon: '🧬',
                      iconBgColor: const Color(0xFFDCFCE7),
                      isLocked: true,
                    ),

                    const SizedBox(height: 12),

                    // Test 3: Howard Gardner 8 Multi-Intelligence
                    _buildAssessmentCard(
                      context: context,
                      category: 'COGNITIVE',
                      badgeWidget: _buildLockedBadge(),
                      title: 'Howard Gardner 8 Multi–Intelligence',
                      subtitle: '76% Overall (Status Preview)',
                      subtitleColor: const Color(0xFF6366F1),
                      emojiIcon: '🔹',
                      iconBgColor: const Color(0xFFE0F2FE),
                      isLocked: true,
                    ),

                    const SizedBox(height: 12),

                    // Test 4: 5 Senses Sensory Learning Preference
                    _buildAssessmentCard(
                      context: context,
                      category: 'SENSORY',
                      badgeWidget: _buildLockedBadge(),
                      title: '5 Senses Sensory Learning Preference',
                      subtitle: '88% Visual Dominant',
                      subtitleColor: const Color(0xFF2563EB),
                      emojiIcon: '👁️',
                      iconBgColor: const Color(0xFFE0F2FE),
                      isLocked: true,
                    ),

                    const SizedBox(height: 12),

                    // Test 5: SWOT Personal Aptitude Matrix
                    _buildAssessmentCard(
                      context: context,
                      category: 'BEHAVIORAL',
                      badgeWidget: _buildLockedBadge(),
                      title: 'SWOT Personal Aptitude Matrix',
                      subtitle: '12 Strengths, 5 Weaknesses',
                      subtitleColor: const Color(0xFFD97706),
                      emojiIcon: '🛡️',
                      iconBgColor: const Color(0xFFFEF3C7),
                      isLocked: true,
                    ),

                    const SizedBox(height: 12),
                  ],

                  if (_selectedFilterIndex == 0 || _selectedFilterIndex == 2) ...[
                    // Test 6: Stream & Career Suitable Test
                    _buildAssessmentCard(
                      context: context,
                      category: 'CAREER',
                      badgeWidget: _buildTag('Recommended', const Color(0xFFEEF2FF), const Color(0xFF4F46E5)),
                      title: 'Stream & Career Suitable Test',
                      subtitle: 'Recommended for 9th–11th',
                      subtitleColor: const Color(0xFF4F46E5),
                      emojiIcon: '🎓',
                      iconBgColor: const Color(0xFFEEF2FF),
                      isLocked: false,
                    ),
                  ],

                  const SizedBox(height: 80), // Bottom navigation padding
                ],
              ),
            ),

            // Floating Ask Vayo Widget
         /*   const Positioned(
              right: 12,
              bottom: 16,
              child: AskVayoFloatingWidget(),
            ),*/
          ],
        ),
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, bool isNarrow) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Assessments Battery',
                style: TextStyle(
                  fontSize: context.scaleFont(22),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Diagnostic tests for Rahul',
                style: TextStyle(
                  fontSize: context.scaleFont(12),
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(width: 8),

        // Quick Test Button
        ElevatedButton.icon(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4F46E5),
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: isNarrow ? 10 : 14,
              vertical: 8,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          icon: const Icon(Icons.bolt_rounded, size: 16, color: Color(0xFFFDE047)),
          label: Text(
            'Quick Test',
            style: TextStyle(
              fontSize: context.scaleFont(11.5),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalityFreeBanner(BuildContext context, bool isNarrow) {
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
        borderRadius: BorderRadius.circular(20),
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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: const Color(0xFFFCE7F3),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Text('🎯', style: TextStyle(fontSize: 20)),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Personality Type is 100% Free',
                  style: TextStyle(
                    fontSize: context.scaleFont(12.5),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF312E81),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Other element statuses are previewed. Unlock Premium to access full detailed batteries.',
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
              padding: EdgeInsets.symmetric(
                horizontal: isNarrow ? 8 : 12,
                vertical: 8,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Unlock All',
                  style: TextStyle(
                    fontSize: context.scaleFont(11),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 2),
                const Text('👑', style: TextStyle(fontSize: 10)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterPillsRow(BuildContext context, bool isNarrow) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: [
          _buildFilterChip('All (6)', 0),
          const SizedBox(width: 8),
          _buildFilterChip('Completed (5)', 1),
          const SizedBox(width: 8),
          _buildFilterChip('Recommended (1)', 2),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, int index) {
    final bool isSelected = _selectedFilterIndex == index;

    return InkWell(
      onTap: () => setState(() => _selectedFilterIndex = index),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF4F46E5) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF4F46E5) : const Color(0xFFE2E8F0),
            width: 1.2,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: context.scaleFont(12),
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            color: isSelected ? Colors.white : const Color(0xFF475569),
          ),
        ),
      ),
    );
  }

  Widget _buildAssessmentCard({
    required BuildContext context,
    required String category,
    required Widget badgeWidget,
    required String title,
    required String subtitle,
    required Color subtitleColor,
    required String emojiIcon,
    required Color iconBgColor,
    required bool isLocked,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
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
          // Emoji Icon
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Center(
              child: Text(emojiIcon, style: const TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      category,
                      style: TextStyle(
                        fontSize: context.scaleFont(10.5),
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                    const SizedBox(width: 6),
                    badgeWidget,
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: context.scaleFont(13),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: context.scaleFont(11),
                    fontWeight: FontWeight.bold,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 8),

          // Right Icon (Arrow or Lock)
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: isLocked
                  ? const Icon(Icons.lock_rounded, size: 14, color: Color(0xFFD97706))
                  : const Icon(Icons.chevron_right_rounded, size: 20, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLockedBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.lock_rounded, size: 9, color: Color(0xFFD97706)),
          SizedBox(width: 2),
          Text(
            'Locked',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.bold,
              color: Color(0xFFD97706),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 9,
          fontWeight: FontWeight.bold,
          color: textColor,
        ),
      ),
    );
  }
}
