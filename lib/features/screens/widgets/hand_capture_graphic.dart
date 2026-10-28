import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:path_drawing/path_drawing.dart';

enum HandCaptureType {
  leftThumb,
  rightThumb,
  leftFingers,
  rightFingers,
  leftIndex,
  leftMiddle,
  leftRing,
  leftLittle,
  rightIndex,
  rightMiddle,
  rightRing,
  rightLittle;

  bool get isRight => name.startsWith('right');

  bool get isThumb => this == leftThumb || this == rightThumb;

  bool get isCluster => this == leftFingers || this == rightFingers;

  (double, double)? get band => switch (this) {
    leftIndex || rightIndex => (85.0, 112.8),
    leftMiddle || rightMiddle => (112.8, 136.7),
    leftRing || rightRing => (136.7, 160.7),
    leftLittle || rightLittle => (160.7, 190.0),
    _ => null,
  };
}

class HandCaptureGraphic extends StatelessWidget {
  final HandCaptureType type;
  final double size;
  final VoidCallback? onTap;

  const HandCaptureGraphic({
    super.key,
    required this.type,
    this.size = 100,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final graphic = SizedBox(
      width: size * 1.3,
      height: size,
      child: CustomPaint(
        painter: _HandPainter(type: type),
      ),
    );

    if (onTap == null) return graphic;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: graphic,
    );
  }
}

class _HandPainter extends CustomPainter {
  final HandCaptureType type;

  _HandPainter({required this.type});

  static const double _viewport = 240;

  static const String _handPathData =
  r'''M111.4,58.16a10.4,10.4 0,0 0,-4.9 1.25q-22.6,12.89 -45.07,26a23,23 0,0 0,-4.36 3.86,75.81 75.81,0 0,0 -16.65,24.1A54.93,54.93,0 0 0,35.74 135c0,1.44 0.06,2.88 0.19,4.33 1.57,17.16 10.3,29.5 25.79,37a55.85,55.85 0,0 0,23.52 5.44c9.75,0.19 19.51,0.1 29.26,0.11q23.82,0 47.65,0a9.24,9.24 0,0 0,9.43 -9.16,9.34 9.34,0 0,0 -0.61,-3.31 9.13,9.13 0,0 0,-8.48 -5.91L129.11,163.5v-5.58L183,157.92c4.52,0 8.12,-2.58 9.28,-6.62a9.94,9.94 0,0 0,0.38 -2.66c0,-5 -4.08,-9.13 -9.7,-9.14q-20.13,0 -40.27,0L129.13,139.5v-5.54h65.65a9.17,9.17 0,0 0,9.48 -9.18v0a9.21,9.21 0,0 0,-9.45 -9.21q-32.09,0 -64.16,0h-1.54v-5.54h1.48q25.51,0 51,0a9.19,9.19 0,1 0,0.12 -18.38L98.05,91.65a2.78,2.78 0,0 1,-2.77 -2.09,2.91 2.91,0 0,1 -0.11,-0.76 2.74,2.74 0,0 1,1.52 -2.38q6.21,-3.61 12.45,-7.2l6.48,-3.74a8.74,8.74 0,0 0,4.56 -7.73,10.46 10.46,0 0,0 -0.34,-2.61C118.79,60.8 115.73,58.15 111.4,58.16ZM111.4,61.66c3.3,0 4.57,2.29 5,4.22a7.34,7.34 0,0 1,0.23 1.76,5.26 5.26 0,0 1 -2.83,4.7c-1.47,0.87 -2.95,1.72 -4.44,2.57l-2,1.17 -3.45,2q-4.5,2.59 -9,5.21a6.27,6.27 0,0 0,3 11.75h83.82a5.65,5.65 0,0 1,5.52 4.1,5.68 5.68 0,0 1 -5.65,7.28c-5.35,0 -10.69,0 -16,0h-40L125.6,119L194.8,119a5.71,5.71 0,0 1,6 5.71v0a5.66,5.66 0,0 1,-6 5.69L125.63,130.4v12.54h57.31c3.53,0 6.2,2.43 6.2,5.64a6.23,6.23 0,0 1,-0.25 1.69c-0.73,2.56 -2.94,4.08 -5.91,4.09L125.61,154.36v12.58h36.88a5.65,5.65 0,0 1,5.2 3.64,5.85 5.85 0,0 1 0.39,2.08 5.75,5.75 0,0 1,-5.94 5.66L107.22,178.32c-7.19,0 -14.62,0 -21.92,-0.12a52.56,52.56 0,0 1,-22.06 -5.09C48.67,166.07 40.87,154.9 39.42,139c-0.12,-1.32 -0.18,-2.67 -0.18,-4a51.18,51.18 0,0 1,4.4 -20.21,72.25 72.25 0,0 1,15.9 -23c0.25,-0.24 0.49,-0.49 0.73,-0.74a15.79,15.79 0,0 1,2.93 -2.57c11.14,-6.51 22.33,-13 33.39,-19.33l11.64,-6.66A6.82,6.82 0,0 1,111.4 61.66Z''';

  static const String _thumbTipPathData =
  r'''M111.4,61.66a6.82,6.82 0,0 0,-3.17 0.79L96.59,69.11l7.35,9 3.45,-2 2,-1.17c1.49,-0.85 3,-1.7 4.44,-2.57a5.26,5.26 0,0 0,2.83 -4.7,7.34 7.34 0,0 0,-0.23,-1.76C116,64 114.7,61.66 111.4,61.66Z''';

  static final Path _handPath = parseSvgPathData(_handPathData);
  static final Path _thumbTipPath = parseSvgPathData(_thumbTipPathData);

  static const double _fingerTipStartX = 172;

  // Slightly softened dark + vivid accent
  static const Color _darkColor = Color(0xFF1E293B);
  static const Color _redColor = Color(0xFFF43F5E);

  @override
  void paint(Canvas canvas, Size size) {
    final bool isRight = type.isRight;

    // Soft drop shadow under the hand
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.08)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    final darkPaint = Paint()
      ..color = _darkColor
      ..style = PaintingStyle.fill;

    final redPaint = Paint()
      ..color = _redColor
      ..style = PaintingStyle.fill;

    final highlightPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..style = PaintingStyle.fill;

    final double scale = math.min(size.width, size.height) / _viewport;
    final double dx = (size.width - _viewport * scale) / 2;
    final double dy = (size.height - _viewport * scale) / 2;

    canvas.save();
    canvas.translate(dx, dy);
    canvas.scale(scale);

    if (isRight) {
      canvas.translate(_viewport, 0);
      canvas.scale(-1, 1);
    }

    // Shadow (offset slightly)
    canvas.save();
    canvas.translate(0, 4);
    canvas.drawPath(_handPath, shadowPaint);
    canvas.restore();

    // Hand body
    canvas.drawPath(_handPath, darkPaint);

    // Subtle top highlight for depth
    canvas.save();
    canvas.clipPath(_handPath);
    canvas.drawRect(
      const Rect.fromLTRB(0, 0, _viewport, 110),
      highlightPaint,
    );
    canvas.restore();

    if (type.isThumb) {
      canvas.drawPath(_thumbTipPath, redPaint);
      // glow around thumb tip
      final glow = Paint()
        ..color = _redColor.withOpacity(0.35)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawPath(_thumbTipPath, glow);
    } else {
      final (top, bottom) = type.band ?? (80.0, 200.0);
      canvas.save();
      canvas.clipPath(_handPath);

      // glow
      final glow = Paint()
        ..color = _redColor.withOpacity(0.30)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawRect(
        Rect.fromLTRB(_fingerTipStartX - 2, top - 2, _viewport, bottom + 2),
        glow,
      );

      canvas.drawRect(
        Rect.fromLTRB(_fingerTipStartX, top, _viewport, bottom),
        redPaint,
      );
      canvas.restore();
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _HandPainter oldDelegate) {
    return oldDelegate.type != type;
  }
}