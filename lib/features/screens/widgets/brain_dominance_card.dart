/*
import 'package:flutter/material.dart';


import '../../../core/models/reportResponse.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/unlock_button.dart';
import '../brain_dominance_detail_screen.dart';

class BrainDominanceCard extends StatelessWidget {
  final BrainDominance? currentProfile;

  const BrainDominanceCard({super.key, required this.currentProfile});

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>  BrainDominanceDetailScreen(brainDominance: currentProfile,),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = currentProfile;
    final left = b?.leftBrain ?? 0.0;
    final right = b?.rightBrain ?? 0.0;

    // Same text style as before; swap this line if you want the old wording.
    final subtitle = b == null
        ? '--'
        : (right >= left ? 'Right Brain Dominant' : 'Left Brain Dominant');

    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: BorderRadius.circular(20),
      child: SectionCard(
        iconWidget: Container(
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
        title: 'BRAIN DOMINANCE',
        badge: StatusBadge.statusOnly(),
        subtitle: subtitle,
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        b != null ? '${(left * 100).round()}%' : '--',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4338CA),
                        ),
                      ),
                      const Text(
                        'Left Brain',
                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Donut Chart with lock
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
                            value: right.clamp(0.0, 1.0).toDouble(),
                            strokeWidth: 6,
                            backgroundColor: const Color(0xFF6366F1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFA855F7)),
                          ),
                        ),
                        const Icon(Icons.lock_rounded,
                            size: 14, color: Color(0xFFD97706)),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Text(
                        b != null ? '${(right * 100).round()}%' : '--',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7E22CE),
                        ),
                      ),
                      const Text(
                        'Right Brain',
                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            UnlockButton(
              label: 'Unlock Brain',
              onTap: () => _openDetail(context),
            ),
          ],
        ),
      ),
    );
  }
}*/
import 'package:flutter/material.dart';
import '../../../data/models/brainDominanceResponse.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/unlock_button.dart';
import '../brain_dominance_detail_screen.dart';
import 'BrainDominanceHomedetail.dart';

class BrainDominanceCard extends StatelessWidget {
  final BrainDominanceData? currentProfile;

  const BrainDominanceCard({super.key, required this.currentProfile});

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BrainDominanceHomeDetailScreen(brainDominance: currentProfile),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = currentProfile;
    final left = b?.leftBrain ?? 0.0;
    final right = b?.rightBrain ?? 0.0;

    // Same text style as before; swap this line if you want the old wording.
    final subtitle = b == null
        ? '--'
        : (right >= left ? 'Right Brain Dominant' : 'Left Brain Dominant');

    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: BorderRadius.circular(20),
      child: SectionCard(
        iconWidget: Container(
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
        title: 'BRAIN DOMINANCE',
        badge: StatusBadge.statusOnly(),
        subtitle: subtitle,
        child: Row(
          children: [
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Column(
                    children: [
                      Text(
                        b != null ? '${(left * 100).round()}%' : '--',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF4338CA),
                        ),
                      ),
                      const Text(
                        'Left Brain',
                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),

                  // Donut Chart with lock
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
                            value: right.clamp(0.0, 1.0).toDouble(),
                            strokeWidth: 6,
                            backgroundColor: const Color(0xFF6366F1),
                            valueColor: const AlwaysStoppedAnimation<Color>(
                                Color(0xFFA855F7)),
                          ),
                        ),
                        const Icon(Icons.lock_rounded,
                            size: 14, color: Color(0xFFD97706)),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),
                  Column(
                    children: [
                      Text(
                        b != null ? '${(right * 100).round()}%' : '--',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF7E22CE),
                        ),
                      ),
                      const Text(
                        'Right Brain',
                        style: TextStyle(fontSize: 10, color: Color(0xFF64748B)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            UnlockButton(
              label: 'Unlock Brain',
              onTap: () => _openDetail(context),
            ),
          ],
        ),
      ),
    );
  }
}