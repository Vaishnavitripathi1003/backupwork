import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/utils/responsive.dart';
import '../../../data/models/multipleintellegenceResponse.dart';



class MultiIntelligenceHomeDetailScreen extends StatefulWidget {
  final MultipleIntelligence? multipleIntelligence;

  const MultiIntelligenceHomeDetailScreen({super.key, this.multipleIntelligence});

  @override
  State<MultiIntelligenceHomeDetailScreen> createState() =>
      _MultiIntelligenceHomeDetailScreenState();
}

class _MultiIntelligenceHomeDetailScreenState
    extends State<MultiIntelligenceHomeDetailScreen> {
  int? _selectedSliceIndex;

  double _toPercentage(double? val) {
    if (val == null) return 0.0;
    return val <= 1.0 ? (val * 100) : val;
  }

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;

    final mi = widget.multipleIntelligence;

    final kinesthetic = _toPercentage(mi?.kinesthetic.self ?? 0.85);
    final linguistic = _toPercentage(mi?.linguistic.self ?? 0.80);
    final interpersonal = _toPercentage(mi?.interpersonal.self ?? 0.80);
    final logicalMath = _toPercentage(mi?.logicalMathematical.self ?? 0.82);
    final musical = _toPercentage(mi?.musical.self ?? 0.75);
    final intrapersonal = _toPercentage(mi?.intrapersonal.self ?? 0.70);
    final visual = _toPercentage(mi?.visual.self ?? 0.70);
    final naturalist = _toPercentage(mi?.naturalist.self ?? 0.65);

    final avg = ((kinesthetic +
        linguistic +
        interpersonal +
        logicalMath +
        musical +
        intrapersonal +
        visual +
        naturalist) /
        8.0)
        .round();

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: AppTheme.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '8 Multi Intelligence',
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

                  // 2. Overall Intelligence Profile Card
                 // _buildOverallProfileCard(context, isNarrow, avg),

                 // const SizedBox(height: 20),

                  // 3. Wheel Header Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Your 8 Intelligence Scores',
                        style: TextStyle(
                          fontSize: context.scaleFont(16),
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      Text(
                        'Tap any slice',
                        style: TextStyle(
                          fontSize: context.scaleFont(12),
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF6366F1),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // 4. 8 Intelligence Wheel (graph by percent, animated on tap)
                  Center(
                    child: IntelligenceWheel(
                      size: isNarrow ? 280 : 320,
                      selectedIndex: _selectedSliceIndex,
                      onSelected: (i) =>
                          setState(() => _selectedSliceIndex = i),
                      slices: [
                        IntelligenceSlice(
                          title: 'Linguistic',
                          icon: '📖',
                          percent: linguistic,
                          color: const Color(0xFF8B5CF6),
                        ),
                        IntelligenceSlice(
                          title: 'Logical Mathematical',
                          icon: '🧮',
                          percent: logicalMath,
                          color: const Color(0xFFEC4899),
                        ),
                        IntelligenceSlice(
                          title: 'Spatial',
                          icon: '🎲',
                          percent: visual,
                          color: const Color(0xFFF97316),
                        ),
                        IntelligenceSlice(
                          title: 'Bodily Kinesthetic',
                          icon: '🏃',
                          percent: kinesthetic,
                          color: const Color(0xFFF59E0B),
                        ),
                        IntelligenceSlice(
                          title: 'Musical',
                          icon: '🎵',
                          percent: musical,
                          color: const Color(0xFF10B981),
                        ),
                        IntelligenceSlice(
                          title: 'Interpersonal',
                          icon: '👥',
                          percent: interpersonal,
                          color: const Color(0xFF0D9488),
                        ),
                        IntelligenceSlice(
                          title: 'Intrapersonal',
                          icon: '👤',
                          percent: intrapersonal,
                          color: const Color(0xFF2563EB),
                        ),
                        IntelligenceSlice(
                          title: 'Naturalistic',
                          icon: '🍃',
                          percent: naturalist,
                          color: const Color(0xFF6366F1),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 28),

                  // 5. All 8 Intelligence Scores List Header
                  Text(
                    'All 8 Intelligence Scores',
                    style: TextStyle(
                      fontSize: context.scaleFont(16),
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // 6. List of 8 Intelligence Scores Progress Rows
                  _buildScoreRow(
                    context: context,
                    icon: '🏃',
                    iconBg: const Color(0xFFFEF08A),
                    title: 'Bodily Kinesthetic',
                    progress: kinesthetic / 100.0,
                    percent: '${kinesthetic.toStringAsFixed(0)}%',
                    statusTag: 'Very Strong',
                    tagBg: const Color(0xFFDCFCE7),
                    tagText: const Color(0xFF15803D),
                    barColor: const Color(0xFFF59E0B),
                  ),
                  const SizedBox(height: 14),

                  _buildScoreRow(
                    context: context,
                    icon: '📖',
                    iconBg: const Color(0xFFF3E8FF),
                    title: 'Linguistic Intelligence',
                    progress: linguistic / 100.0,
                    percent: '${linguistic.toStringAsFixed(0)}%',
                    statusTag: 'Strong',
                    tagBg: const Color(0xFFDCFCE7),
                    tagText: const Color(0xFF15803D),
                    barColor: const Color(0xFF8B5CF6),
                  ),
                  const SizedBox(height: 14),

                  _buildScoreRow(
                    context: context,
                    icon: '👥',
                    iconBg: const Color(0xFFCCFBF1),
                    title: 'Interpersonal Intelligence',
                    progress: interpersonal / 100.0,
                    percent: '${interpersonal.toStringAsFixed(0)}%',
                    statusTag: 'Strong',
                    tagBg: const Color(0xFFDCFCE7),
                    tagText: const Color(0xFF15803D),
                    barColor: const Color(0xFF0D9488),
                  ),
                  const SizedBox(height: 14),

                  _buildScoreRow(
                    context: context,
                    icon: '🧮',
                    iconBg: const Color(0xFFFFE4E6),
                    title: 'Logical-Mathematical Inte...',
                    progress: logicalMath / 100.0,
                    percent: '${logicalMath.toStringAsFixed(0)}%',
                    statusTag: 'Strong',
                    tagBg: const Color(0xFFDCFCE7),
                    tagText: const Color(0xFF15803D),
                    barColor: const Color(0xFFF43F5E),
                  ),
                  const SizedBox(height: 14),

                  _buildScoreRow(
                    context: context,
                    icon: '🎵',
                    iconBg: const Color(0xFFDCFCE7),
                    title: 'Musical Intelligence',
                    progress: musical / 100.0,
                    percent: '${musical.toStringAsFixed(0)}%',
                    statusTag: 'Strong',
                    tagBg: const Color(0xFFDCFCE7),
                    tagText: const Color(0xFF15803D),
                    barColor: const Color(0xFF10B981),
                  ),
                  const SizedBox(height: 14),

                  _buildScoreRow(
                    context: context,
                    icon: '👤',
                    iconBg: const Color(0xFFDBEAFE),
                    title: 'Intrapersonal Intelligence',
                    progress: intrapersonal / 100.0,
                    percent: '${intrapersonal.toStringAsFixed(0)}%',
                    statusTag: 'Average',
                    tagBg: const Color(0xFFF1F5F9),
                    tagText: const Color(0xFF475569),
                    barColor: const Color(0xFF2563EB),
                  ),
                  const SizedBox(height: 14),

                  _buildScoreRow(
                    context: context,
                    icon: '🎲',
                    iconBg: const Color(0xFFFFEDD5),
                    title: 'Spatial Intelligence',
                    progress: visual / 100.0,
                    percent: '${visual.toStringAsFixed(0)}%',
                    statusTag: 'Average',
                    tagBg: const Color(0xFFF1F5F9),
                    tagText: const Color(0xFF475569),
                    barColor: const Color(0xFFF97316),
                  ),
                  const SizedBox(height: 14),

                  _buildScoreRow(
                    context: context,
                    icon: '🍃',
                    iconBg: const Color(0xFFE0E7FF),
                    title: 'Naturalistic Intelligence',
                    progress: naturalist / 100.0,
                    percent: '${naturalist.toStringAsFixed(0)}%',
                    statusTag: 'Average',
                    tagBg: const Color(0xFFF1F5F9),
                    tagText: const Color(0xFF475569),
                    barColor: const Color(0xFF6366F1),
                  ),

                  const SizedBox(height: 24),

                  // 7. Unlock In-Depth Report Banner
                 /* _buildUnlockBanner(context, isNarrow),

                  const SizedBox(height: 80),*/
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
                  'Overall status shown. Deep analytics, careers & learning plans lock until Premium.',
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

  Widget _buildOverallProfileCard(
      BuildContext context, bool isNarrow, int avgPercent) {
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
                Text(
                  'Overall Intelligence Profile',
                  style: TextStyle(
                    fontSize: context.scaleFont(14),
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Strong in multiple areas',
                  style: TextStyle(
                    fontSize: context.scaleFont(13),
                    fontWeight: FontWeight.bold,
                    color: const Color(0xFF6366F1),
                  ),
                ),
              ],
            ),
          ),

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
                    value: (avgPercent / 100.0).clamp(0.0, 1.0),
                    strokeWidth: 6,
                    backgroundColor: const Color(0xFFE0F2FE),
                    valueColor:
                    const AlwaysStoppedAnimation<Color>(Color(0xFF0284C7)),
                  ),
                ),
                Text(
                  '$avgPercent%',
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

  Widget _buildScoreRow({
    required BuildContext context,
    required String icon,
    required Color iconBg,
    required String title,
    required double progress,
    required String percent,
    required String statusTag,
    required Color tagBg,
    required Color tagText,
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
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: context.scaleFont(13),
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  minHeight: 7,
                  backgroundColor: const Color(0xFFF1F5F9),
                  valueColor: AlwaysStoppedAnimation<Color>(barColor),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 10),
        Text(
          percent,
          style: TextStyle(
            fontSize: context.scaleFont(13),
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(width: 8),

        // Lock Status Tag
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
          decoration: BoxDecoration(
            color: tagBg,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.lock_rounded, size: 10, color: Color(0xFFD97706)),
              const SizedBox(width: 3),
              Text(
                statusTag,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: tagText,
                ),
              ),
            ],
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
              'Unlock In-Depth Report & Exercises 👑',
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

// ---------------------------------------------------------------------------
// Intelligence wheel: same look as the original design.
// On tap the slice pops out and a percent fill animates inside it.
// ---------------------------------------------------------------------------

class IntelligenceSlice {
  final String title;
  final String icon;
  final double percent; // 0-100
  final Color color;

  const IntelligenceSlice({
    required this.title,
    required this.icon,
    required this.percent,
    required this.color,
  });
}

const double _kPopGrow = 10; // how much the tapped slice grows
const double _kPopShift = 5; // how far the tapped slice moves outward

class IntelligenceWheel extends StatefulWidget {
  final double size;
  final List<IntelligenceSlice> slices;
  final int? selectedIndex;
  final ValueChanged<int?> onSelected;

  const IntelligenceWheel({
    super.key,
    required this.size,
    required this.slices,
    required this.selectedIndex,
    required this.onSelected,
  });

  @override
  State<IntelligenceWheel> createState() => _IntelligenceWheelState();
}

class _IntelligenceWheelState extends State<IntelligenceWheel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _select;
  int? _prevIndex;

  // Same center circle size as the original (110 narrow / 130 normal)
  double get _centerSize => widget.size <= 280 ? 110.0 : 130.0;

  @override
  void initState() {
    super.initState();
    _select = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 450),
      value: 1,
    );
  }

  @override
  void didUpdateWidget(covariant IntelligenceWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      _prevIndex = oldWidget.selectedIndex;
      _select.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _select.dispose();
    super.dispose();
  }

  void _handleTap(Offset p) {
    final c = Offset(widget.size / 2, widget.size / 2);
    final d = p - c;
    final dist = d.distance;

    if (dist > widget.size / 2) return;
    if (dist < _centerSize / 2) {
      widget.onSelected(null); // tap the center to clear
      return;
    }

    var angle = atan2(d.dy, d.dx) + pi / 2; // 0 = top, clockwise
    if (angle < 0) angle += 2 * pi;
    final n = widget.slices.length;
    final index = (angle / (2 * pi / n)).floor() % n;
    widget.onSelected(index == widget.selectedIndex ? null : index);
  }

  @override
  Widget build(BuildContext context) {
    final sel = widget.selectedIndex;

    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (d) => _handleTap(d.localPosition),
        child: Stack(
          alignment: Alignment.center,
          clipBehavior: Clip.none,
          children: [
            CustomPaint(
              size: Size.square(widget.size),
              painter: _WheelPainter(
                slices: widget.slices,
                select: _select,
                selectedIndex: sel,
                prevIndex: _prevIndex,
              ),
            ),
            IgnorePointer(
              child: Container(
                width: _centerSize,
                height: _centerSize,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  transitionBuilder: (child, anim) => FadeTransition(
                    opacity: anim,
                    child: ScaleTransition(scale: anim, child: child),
                  ),
                  child: sel == null
                      ? _defaultCenter()
                      : _selectedCenter(widget.slices[sel], sel),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Original center content
  Widget _defaultCenter() {
    return Column(
      key: const ValueKey('default'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Icon(Icons.psychology_outlined, size: 28, color: Color(0xFF6366F1)),
        SizedBox(height: 4),
        Text(
          '8 Multiple\nIntelligences',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _selectedCenter(IntelligenceSlice s, int index) {
    return Column(
      key: ValueKey('sel_$index'),
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(s.icon, style: const TextStyle(fontSize: 20)),
        Text(
          '${s.percent.toStringAsFixed(0)}%',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: s.color,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Text(
            s.title,
            textAlign: TextAlign.center,
            maxLines: 2,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: AppTheme.textPrimary,
              height: 1.1,
            ),
          ),
        ),
      ],
    );
  }
}

class _WheelPainter extends CustomPainter {
  final List<IntelligenceSlice> slices;
  final Animation<double> select;
  final int? selectedIndex;
  final int? prevIndex;

  _WheelPainter({
    required this.slices,
    required this.select,
    required this.selectedIndex,
    required this.prevIndex,
  }) : super(repaint: select);

  Path _sector(Offset c, double r, double a0, double sw) {
    return Path()
      ..moveTo(c.dx, c.dy)
      ..arcTo(Rect.fromCircle(center: c, radius: r), a0, sw, false)
      ..close();
  }

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final radius = min(size.width, size.height) / 2; // full radius, as original
    final n = slices.length;
    final sweepAngle = (2 * pi) / n;
    const startAngleOffset = -pi / 2; // start from top
    final anySelected = selectedIndex != null;
    final t = select.value;

    for (int i = 0; i < n; i++) {
      final s = slices[i];

      double pop = 0;
      if (i == selectedIndex) {
        pop = Curves.easeOutBack.transform(t);
      } else if (i == prevIndex) {
        pop = 1 - Curves.easeOutCubic.transform(t);
      }

      final startAngle = startAngleOffset + (i * sweepAngle);
      final mid = startAngle + sweepAngle / 2;
      final dir = Offset(cos(mid), sin(mid));
      final center = c + dir * (_kPopShift * pop);
      final r = radius + _kPopGrow * pop;
      final drawSweep = sweepAngle - 0.02; // small gap between slices

      final alpha = anySelected ? (0.6 + 0.4 * pop.clamp(0.0, 1.0)) : 1.0;

      // Slice (same as original)
      final fill = Paint()
        ..style = PaintingStyle.fill
        ..isAntiAlias = true
        ..color = s.color.withValues(alpha: alpha);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: r),
        startAngle,
        drawSweep,
        true,
        fill,
      );

      // Percent fill: lighter band from the percent radius to the edge,
      // animating inward when the slice is tapped
      final fillT = pop.clamp(0.0, 1.0);
      if (fillT > 0.01) {
        final pr = r * (s.percent / 100).clamp(0.0, 1.0);
        final innerR = r + (pr - r) * fillT;
        final band = Path.combine(
          PathOperation.difference,
          _sector(center, r, startAngle, drawSweep),
          _sector(center, innerR, startAngle, drawSweep),
        );
        canvas.drawPath(
          band,
          Paint()
            ..style = PaintingStyle.fill
            ..color = Colors.white.withValues(alpha: 0.38 * fillT),
        );

        // White outline of the tapped slice
        canvas.drawArc(
          Rect.fromCircle(center: center, radius: r),
          startAngle,
          drawSweep,
          true,
          Paint()
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.5
            ..isAntiAlias = true
            ..color = Colors.white.withValues(alpha: fillT),
        );
      }

      // Label: icon, name, score (same as original)
      final labelRadius = r * 0.70;
      final labelPos = center + dir * labelRadius;

      final textPainter = TextPainter(
        text: TextSpan(
          children: [
            TextSpan(
              text: '${s.icon}\n',
              style: const TextStyle(fontSize: 12),
            ),
            TextSpan(
              text: '${s.title.replaceFirst(' ', '\n')}\n',
              style: const TextStyle(
                fontSize: 8.5,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                height: 1.1,
              ),
            ),
            TextSpan(
              text: '${s.percent.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w900,
                color: Colors.white,
              ),
            ),
          ],
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      )..layout();

      textPainter.paint(
        canvas,
        Offset(labelPos.dx - textPainter.width / 2,
            labelPos.dy - textPainter.height / 2),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _WheelPainter old) {
    return old.slices != slices ||
        old.selectedIndex != selectedIndex ||
        old.prevIndex != prevIndex;
  }
}