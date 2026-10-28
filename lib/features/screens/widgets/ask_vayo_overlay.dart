import 'package:flutter/material.dart';
import '../chatWork/disc_chat/disc_chat_screen.dart';


class AskVayoFloatingWidget extends StatefulWidget {
  final String? primary;
  final String? secondary;

  const AskVayoFloatingWidget(this.primary, this.secondary, {super.key});

  @override
  State<AskVayoFloatingWidget> createState() => _AskVayoFloatingWidgetState();
}

class _AskVayoFloatingWidgetState extends State<AskVayoFloatingWidget> {
  final bool _isVisible = true;

  static String getProfileCode({
    required String primary,
    required String secondary,
  }) {
    const Map<String, String> discMapping = {
      'dominant': 'D',
      'dominance': 'D',
      'influential': 'I',
      'influence': 'I',
      'steady': 'S',
      'steadiness': 'S',
      'compliant': 'C',
      'compliance': 'C',
      'd': 'D',
      'i': 'I',
      's': 'S',
      'c': 'C',
    };

    String normalize(String value) {
      return value.trim().replaceAll(RegExp(r'\s+'), ' ').toLowerCase();
    }

    final String? primaryCode = discMapping[normalize(primary)];
    final String? secondaryCode = discMapping[normalize(secondary)];

    if (primaryCode == null || secondaryCode == null) {
      throw ArgumentError(
        'Invalid DISC styles: primary=$primary, secondary=$secondary',
      );
    }

    return '$primaryCode$secondaryCode';
  }

  void _openCounselor(BuildContext context) {
    String? profileCode;
    final p = widget.primary;
    final s = widget.secondary;
    if (p != null && p.isNotEmpty && s != null && s.isNotEmpty) {
      try {
        profileCode = getProfileCode(primary: p, secondary: s);
      } catch (_) {
        profileCode = null;
      }
    }
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DiscChatScreen(profileCode: profileCode),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVisible) return const SizedBox.shrink();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () => _openCounselor(context),
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF0284C7),
                Color(0xFF2563EB),
                Color(0xFF7C3AED),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.3),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF2563EB).withValues(alpha: 0.40),
                blurRadius: 16,
                spreadRadius: 1,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Robot Avatar Circle
              Container(
                width: 44,
                height: 44,
                decoration: const BoxDecoration(
                  color: Color(0xFF090D16),
                  shape: BoxShape.circle,
                ),
                child: CustomPaint(
                  painter: _VayoRobotAvatarPainter(),
                ),
              ),

              const SizedBox(width: 10),

              // Text & Badge Column
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'vayo',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(width: 6),
                      // AI Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 5,
                          vertical: 1.5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF00E5FF),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: const Text(
                          'AI',
                          style: TextStyle(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF090D16),
                            height: 1.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 1),
                  const Text(
                    'Online',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFBAE6FD),
                      height: 1.1,
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 6),
            ],
          ),
        ),
      ),
    );
  }
}

/// Custom Painter for Vayo's Robot Avatar Face
class _VayoRobotAvatarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);

    // 1. Top Cyan Glowing Dot
    final cyanPaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(Offset(center.dx, center.dy - 13), 2.5, cyanPaint);

    // 2. Visor Rect Outer Outline
    final visorOutlinePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2;

    final visorRect = Rect.fromCenter(
      center: Offset(center.dx, center.dy - 2),
      width: 22,
      height: 11,
    );
    final visorRRect = RRect.fromRectAndRadius(visorRect, const Radius.circular(3.5));

    final visorFillPaint = Paint()
      ..color = const Color(0xFF030712)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(visorRRect, visorFillPaint);
    canvas.drawRRect(visorRRect, visorOutlinePaint);

    // 3. Cyan Robot Eyes (Two Rectangles/Dots inside Visor)
    final eyePaint = Paint()
      ..color = const Color(0xFF00E5FF)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 6, center.dy - 4, 4, 3.5),
        const Radius.circular(1),
      ),
      eyePaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx + 2, center.dy - 4, 4, 3.5),
        const Radius.circular(1),
      ),
      eyePaint,
    );

    // 4. Purple/Blue Mouth Line
    final mouthPaint = Paint()
      ..color = const Color(0xFF818CF8)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTWH(center.dx - 5, center.dy + 8, 10, 2.5),
        const Radius.circular(1.5),
      ),
      mouthPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
