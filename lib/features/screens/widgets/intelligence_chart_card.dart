/*

import 'package:flutter/material.dart';

import '../../../core/models/reportResponse.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/unlock_button.dart';
import '../multi_intelligence_detail_screen.dart';
import 'multipleintellegencehome.dart';

class IntelligenceChartCard extends StatelessWidget {
  /// Data from findReportByUserParam (multiple_intelligence).
  /// If null (not loaded yet / failed) the old placeholder bars are shown.
  final MultipleIntelligence? multipleIntelligenceData;

  const IntelligenceChartCard({super.key, this.multipleIntelligenceData});

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiIntelligenceDetailScreen(multipleIntelligence: multipleIntelligenceData,),
      ),
    );
  }

  List<_BarData> _bars() {
    final d = multipleIntelligenceData;

    // Placeholder (original values) when there is no data
    if (d == null) {
      debugPrint(
     "binding multiple data dummy"    );
      return const [
        _BarData(0.60, Color(0xFF60A5FA), '📖', 0),
        _BarData(0.75, Color(0xFF06B6D4), '🔢', 0),
        _BarData(0.85, Color(0xFF34D399), '🧠', 0),
        _BarData(0.55, Color(0xFFFBBF24), '👥', 0),
        _BarData(0.95, Color(0xFFF472B6), '🎵', 0),
        _BarData(1.00, Color(0xFF38BDF8), '🏃', 0),
        _BarData(0.70, Color(0xFF818CF8), '🍦', 0),
        _BarData(0.80, Color(0xFF2DD4BF), '🌿', 0),
      ];
    }

    // "self" scores are shares (0..1) of the total, so they are small.
    // Scale every bar relative to the highest one so the chart is readable.
    final raw = <double>[


      d.linguistic.self,
      d.logicalMathematical.self,
      d.intrapersonal.self,
      d.interpersonal.self,
      d.musical.self,
      d.kinesthetic.self,
      d.visual.self,
      d.naturalist.self,
    ];
    final maxVal = raw.reduce((a, b) => a > b ? a : b);

    double ratio(double v) {
      if (maxVal <= 0) return 0.08;
      final r = v / maxVal;
      return r < 0.08 ? 0.08 : r; // keep a tiny bar visible for 0 values
    }

    const colors = [
      Color(0xFF60A5FA),
      Color(0xFF06B6D4),
      Color(0xFF34D399),
      Color(0xFFFBBF24),
      Color(0xFFF472B6),
      Color(0xFF38BDF8),
      Color(0xFF818CF8),
      Color(0xFF2DD4BF),
    ];
    const icons = ['📖', '🔢', '🧠', '👥', '🎵', '🏃', '🍦', '🌿'];

    return List.generate(
      raw.length,
          (i) => _BarData(ratio(raw[i]), colors[i], icons[i], raw[i] * 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bars = _bars();

    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: BorderRadius.circular(20),
      child: SectionCard(
        iconWidget: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.diamond_outlined, color: Color(0xFF0284C7), size: 22),
          ),
        ),
        title: '8 MULTIPLE INTELLIGENCE',
        badge: StatusBadge.statusOnly(),
        subtitle: '8 key intelligences with learning styles & career alignments.',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Bar chart
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = 0; i < bars.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _BarColumn(
                        heightRatio: bars[i].ratio,
                        color: bars[i].color,
                        icon: bars[i].icon,
                        percent: multipleIntelligenceData == null
                            ? null
                            : bars[i].percent,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            UnlockButton(
              label: 'Unlock Matrix',
              onTap: () => _openDetail(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarData {
  final double ratio;
  final Color color;
  final String icon;
  final double percent;
  const _BarData(this.ratio, this.color, this.icon, this.percent);
}

class _BarColumn extends StatelessWidget {
  final double heightRatio;
  final Color color;
  final String icon;
  final double? percent; // null -> no label (placeholder mode)

  const _BarColumn({
    required this.heightRatio,
    required this.color,
    required this.icon,
    this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (percent != null) ...[
          Text(
            '${percent!.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 3),
        ],
        Container(
          width: 12,
          height: 60 * heightRatio,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(icon, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}*/
import 'package:daksh/data/models/multipleintellegenceResponse.dart';
import 'package:flutter/material.dart';
import '../../../shared/widgets/section_card.dart';
import '../../../shared/widgets/status_badge.dart';
import '../../../shared/widgets/unlock_button.dart';
import '../multi_intelligence_detail_screen.dart';
import 'multipleintellegencehome.dart';

class IntelligenceChartCard extends StatelessWidget {
  /// Data from findReportByUserParam (multiple_intelligence).
  /// If null (not loaded yet / failed) the old placeholder bars are shown.
  final MultipleIntelligence? multipleIntelligenceData;

  const IntelligenceChartCard({super.key, this.multipleIntelligenceData});

  void _openDetail(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => MultiIntelligenceHomeDetailScreen(multipleIntelligence: multipleIntelligenceData,),
      ),
    );
  }

  List<_BarData> _bars() {
    final d = multipleIntelligenceData;

    // Placeholder (original values) when there is no data
    if (d == null) {
      debugPrint(
          "binding multiple data dummy"    );
      return const [
        _BarData(0.60, Color(0xFF60A5FA), '📖', 0),
        _BarData(0.75, Color(0xFF06B6D4), '🔢', 0),
        _BarData(0.85, Color(0xFF34D399), '🧠', 0),
        _BarData(0.55, Color(0xFFFBBF24), '👥', 0),
        _BarData(0.95, Color(0xFFF472B6), '🎵', 0),
        _BarData(1.00, Color(0xFF38BDF8), '🏃', 0),
        _BarData(0.70, Color(0xFF818CF8), '🍦', 0),
        _BarData(0.80, Color(0xFF2DD4BF), '🌿', 0),
      ];
    }

    // "self" scores are shares (0..1) of the total, so they are small.
    // Scale every bar relative to the highest one so the chart is readable.
    final raw = <double>[


      d.linguistic.self,
      d.logicalMathematical.self,
      d.intrapersonal.self,
      d.interpersonal.self,
      d.musical.self,
      d.kinesthetic.self,
      d.visual.self,
      d.naturalist.self,
    ];
    final maxVal = raw.reduce((a, b) => a > b ? a : b);

    double ratio(double v) {
      if (maxVal <= 0) return 0.08;
      final r = v / maxVal;
      return r < 0.08 ? 0.08 : r; // keep a tiny bar visible for 0 values
    }

    const colors = [
      Color(0xFF60A5FA),
      Color(0xFF06B6D4),
      Color(0xFF34D399),
      Color(0xFFFBBF24),
      Color(0xFFF472B6),
      Color(0xFF38BDF8),
      Color(0xFF818CF8),
      Color(0xFF2DD4BF),
    ];
    const icons = ['📖', '🔢', '🧠', '👥', '🎵', '🏃', '🍦', '🌿'];

    return List.generate(
      raw.length,
          (i) => _BarData(ratio(raw[i]), colors[i], icons[i], raw[i] * 100),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bars = _bars();

    return InkWell(
      onTap: () => _openDetail(context),
      borderRadius: BorderRadius.circular(20),
      child: SectionCard(
        iconWidget: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: const Color(0xFFE0F2FE),
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.diamond_outlined, color: Color(0xFF0284C7), size: 22),
          ),
        ),
        title: '8 MULTIPLE INTELLIGENCE',
        badge: StatusBadge.statusOnly(),
        subtitle: '8 key intelligences with learning styles & career alignments.',
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // Bar chart
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    for (int i = 0; i < bars.length; i++) ...[
                      if (i > 0) const SizedBox(width: 8),
                      _BarColumn(
                        heightRatio: bars[i].ratio,
                        color: bars[i].color,
                        icon: bars[i].icon,
                        percent: multipleIntelligenceData == null
                            ? null
                            : bars[i].percent,
                      ),
                    ],
                  ],
                ),
              ),
            ),
            const SizedBox(width: 12),
            UnlockButton(
              label: 'Unlock Matrix',
              onTap: () => _openDetail(context),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarData {
  final double ratio;
  final Color color;
  final String icon;
  final double percent;
  const _BarData(this.ratio, this.color, this.icon, this.percent);
}

class _BarColumn extends StatelessWidget {
  final double heightRatio;
  final Color color;
  final String icon;
  final double? percent; // null -> no label (placeholder mode)

  const _BarColumn({
    required this.heightRatio,
    required this.color,
    required this.icon,
    this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (percent != null) ...[
          Text(
            '${percent!.toStringAsFixed(0)}%',
            style: const TextStyle(
              fontSize: 8.5,
              fontWeight: FontWeight.w700,
              color: Color(0xFF64748B),
            ),
          ),
          const SizedBox(height: 3),
        ],
        Container(
          width: 12,
          height: 60 * heightRatio,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        const SizedBox(height: 6),
        Text(icon, style: const TextStyle(fontSize: 10)),
      ],
    );
  }
}