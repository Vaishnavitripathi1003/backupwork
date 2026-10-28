import 'package:daksh/features/screens/widgets/swot_content.dart';
import 'package:flutter/material.dart';
import '../../../core/models/user_profile.dart';
import '../../../data/models/personalityblenResponse.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/unlock_button.dart';
import '../swot_detail_screen.dart';

class DiscAnalysisCard extends StatelessWidget {
  final UserProfile currentProfile;

  const DiscAnalysisCard({super.key, required this.currentProfile});

  @override
  Widget build(BuildContext context) {
    return SectionCard(
      borderColor: const Color(0xFFA7F3D0),
      iconWidget: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFDCFCE7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text('🧬', style: TextStyle(fontSize: 20)),
        ),
      ),
      title: 'DISC ANALYSIS',
      badge: StatusBadge.completed(),
      subtitle: 'Markers reveal ${currentProfile.archetype}',
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Left Brain', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    Text('48%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF2563EB))),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.48,
                    minHeight: 6,
                    backgroundColor: Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF2563EB)),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Text('Right Brain', style: TextStyle(fontSize: 11, color: Color(0xFF64748B))),
                    Text('52%', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Color(0xFF059669))),
                  ],
                ),
                const SizedBox(height: 4),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: const LinearProgressIndicator(
                    value: 0.52,
                    minHeight: 6,
                    backgroundColor: Color(0xFFF1F5F9),
                    valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF059669)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Brain squircle
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: const Color(0xFF06B6D4),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Text('🧠', style: TextStyle(fontSize: 22)),
            ),
          ),

          const SizedBox(width: 8),
          const UnlockButton(label: 'Unlock DISC'),
        ],
      ),
    );
  }
}

class SwotAnalysisCard extends StatelessWidget {
  final SwotAnalysis swotAnalysis;

  const SwotAnalysisCard({super.key, required this.swotAnalysis});



  void _openSwotDetail(BuildContext context) {
    String Primary=swotAnalysis.combination.toString().split("/").first;
    String secondary=swotAnalysis.combination.toString().split("/").last;
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>  SwotDetailScreen(primary:Primary ,secondary:secondary ,),
      ),
    );
  }

  // 40.0 -> "40%", 5.0 -> "05%"
  String _fmt(double v) => '${v.round().toString().padLeft(2, '0')}%';

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => _openSwotDetail(context),
      borderRadius: BorderRadius.circular(20),
      child: SectionCard(
        borderColor: const Color(0xFFFDE68A),
        iconWidget: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFFEF3C7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text('🛡️', style: TextStyle(fontSize: 20)),
          ),
        ),
        title: 'SWOT ANALYSIS',
        badge: StatusBadge.completed(),
        subtitle: 'Understand strengths, weaknesses and opportunities.',
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SwotStatBox(
                      emoji: '🏆',
                      label: 'Strengths',
                      count: _fmt(swotAnalysis.strengthsPct),
                      countColor: const Color(0xFFD97706),
                      bgColor: const Color(0xFFFFFBEB),
                    ),
                    const SizedBox(width: 8),
                    _SwotStatBox(
                      emoji: '🎗️',
                      label: 'Weaknesses',
                      count: _fmt(swotAnalysis.weaknessesPct),
                      countColor: const Color(0xFFE11D48),
                      bgColor: const Color(0xFFFFF1F2),
                    ),
                    const SizedBox(width: 8),
                    _SwotStatBox(
                      emoji: '🎯',
                      label: 'Opportunities',
                      count: _fmt(swotAnalysis.opportunitiesPct),
                      countColor: const Color(0xFF059669),
                      bgColor: const Color(0xFFECFDF5),
                    ),
                    const SizedBox(width: 8),
                    _SwotStatBox(
                      emoji: '⚠️',
                      label: 'Threats',
                      count: _fmt(swotAnalysis.threatsPct),
                      countColor: const Color(0xFFEA580C),
                      bgColor: const Color(0xFFFFF7ED),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            UnlockButton(
              label: 'Unlock SWOT',
              onTap: () => _openSwotDetail(context),
            ),
          ],
        ),
      ),
    );
  }

}

class _SwotStatBox extends StatelessWidget {
  final String emoji;
  final String label;
  final String count;
  final Color countColor;
  final Color bgColor;

  const _SwotStatBox({
    required this.emoji,
    required this.label,
    required this.count,
    required this.countColor,
    required this.bgColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 84,
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: countColor.withOpacity(0.18)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 18)),
          const SizedBox(height: 4),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: Color(0xFF6B7280),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            count,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: countColor,
            ),
          ),
        ],
      ),
    );
  }
}

