import 'package:flutter/material.dart';
import '../../../core/models/user_profile.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/unlock_button.dart';

import 'package:flutter/material.dart';
import '../../../data/models/careerMatchResponse.dart'; // apne model file ka sahi path
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/unlock_button.dart';

class CareerMatchCard extends StatelessWidget {
  final CareerData? career;

  const CareerMatchCard(this.career, {super.key});

  @override
  Widget build(BuildContext context) {
    final tops = career?.topCareers(1) ?? const <CareerScore>[];
    final top = tops.isEmpty ? null : tops.first;

    final name = top?.name ?? '--';
    final percentText = top?.percent ?? '--';
    final progress = (top?.score ?? 0.0).clamp(0.0, 1.0).toDouble();

    return SectionCard(
      iconWidget: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: const Color(0xFFFEF3C7),
          borderRadius: BorderRadius.circular(10),
        ),
        child: const Center(
          child: Text('💼', style: TextStyle(fontSize: 20)),
        ),
      ),
      title: 'CAREER MATCH',
      badge: StatusBadge.topOneOnly(),
      subtitle: 'Top careers matching your cognitive and sensory profile.',
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Top Match',
                  style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 2),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        name,
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      percentText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF059669),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 6,
                    backgroundColor: const Color(0xFFF1F5F9),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF059669)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          const UnlockButton(label: 'Unlock Matches'),
        ],
      ),
    );
  }
}

class PremiumUpgradeBanner extends StatelessWidget {
  const PremiumUpgradeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF312E81), Color(0xFF4338CA), Color(0xFF6D28D9)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF4338CA).withValues(alpha: 0.3),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('👑', style: TextStyle(fontSize: 22)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Unlock Your True Potential',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Upgrade to Premium to unlock 8 Intelligences, 5 Senses & Counselor',
                  style: TextStyle(
                    fontSize: 11,
                    color: Color(0xFFC7D2FE),
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFEF08A),
              foregroundColor: const Color(0xFF78350F),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              '👑 Upgrade',
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
