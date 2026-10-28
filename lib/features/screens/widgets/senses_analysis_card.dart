/*
import 'package:flutter/material.dart';

import '../../../core/models/reportResponse.dart';
import '../../../data/models/sensesAnalysisResponse.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/unlock_button.dart';
import '../senses_detail_screen.dart';

class SensesAnalysisCard extends StatelessWidget {
  final Senses? currentProfile;

  const SensesAnalysisCard({super.key, required this.currentProfile});

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SensesDetailScreen(senses: currentProfile,),
      ),
    );
  }

  /// 0..1 share -> "88%"
  String _pct(double v) => '${(v * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    final s = currentProfile;

    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: BorderRadius.circular(20),
      child: SectionCard(
        iconWidget: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text('👁️', style: TextStyle(fontSize: 20)),
          ),
        ),
        title: '5 SENSES ANALYSIS',
        badge: StatusBadge.statusOnly(),
      //  subtitle: s != null ? 'Preference: ${s.do}' : 'Preference: --',
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SenseItem(emoji: '👁️', percent: s != null ? _pct(s.see) : '--'),
                    const SizedBox(width: 12),
                    _SenseItem(emoji: '👂', percent: s != null ? _pct(s.listen) : '--'),
                    const SizedBox(width: 12),
                    _SenseItem(emoji: '✋', percent: s != null ? _pct(s.touch) : '--'),
                    const SizedBox(width: 12),
                    _SenseItem(emoji: '👃', percent: s != null ? _pct(s.smell) : '--'),
                    const SizedBox(width: 12),
                    _SenseItem(emoji: '👅', percent: s != null ? _pct(s.taste) : '--'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            UnlockButton(
              label: 'Unlock Senses',
              onTap: () => _openDetail(context),
            ),
          ],
        ),
      ),
    );
  }
}

// _SenseItem stays exactly the same

class _SenseItem extends StatelessWidget {
  final String emoji;
  final String percent;

  const _SenseItem({required this.emoji, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          percent,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}*/
import 'package:daksh/features/screens/widgets/senseAnalysisHomeDetailScreen.dart';
import 'package:flutter/material.dart';

import '../../../data/models/sensesAnalysisResponse.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/unlock_button.dart';
import '../senses_detail_screen.dart';

class SensesAnalysisCard extends StatelessWidget {
  final SensesData? currentProfile;

  const SensesAnalysisCard({super.key, required this.currentProfile});

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => SensesHomeDetailScreen(senses: currentProfile,),
      ),
    );
  }

  /// 0..1 share -> "88%"
  String _pct(double v) => '${(v * 100).round()}%';

  @override
  Widget build(BuildContext context) {
    final s = currentProfile;

    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: BorderRadius.circular(20),
      child: SectionCard(
        iconWidget: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Text('👁️', style: TextStyle(fontSize: 20)),
          ),
        ),
        title: '5 SENSES ANALYSIS',
        badge: StatusBadge.statusOnly(),
        subtitle: s != null ? 'Preference: ${s.dominant}' : 'Preference: --',
        child: Row(
          children: [
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _SenseItem(emoji: '👁️', percent: s != null ? _pct(s.see) : '--'),
                    const SizedBox(width: 12),
                    _SenseItem(emoji: '👂', percent: s != null ? _pct(s.listen) : '--'),
                    const SizedBox(width: 12),
                    _SenseItem(emoji: '✋', percent: s != null ? _pct(s.touch) : '--'),
                    const SizedBox(width: 12),
                    _SenseItem(emoji: '👃', percent: s != null ? _pct(s.smell) : '--'),
                    const SizedBox(width: 12),
                    _SenseItem(emoji: '👅', percent: s != null ? _pct(s.taste) : '--'),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 8),
            UnlockButton(
              label: 'Unlock Senses',
              onTap: () => _openDetail(context),
            ),
          ],
        ),
      ),
    );
  }
}

// _SenseItem stays exactly the same

class _SenseItem extends StatelessWidget {
  final String emoji;
  final String percent;

  const _SenseItem({required this.emoji, required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: const BoxDecoration(
            color: Color(0xFFF8FAFC),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(emoji, style: const TextStyle(fontSize: 18)),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          percent,
          style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }
}