import 'package:flutter/material.dart';

enum StatusBadgeType {
  completed,
  statusOnly,
  free,
  freePass,
  topOneOnly,
  custom,
}

class StatusBadge extends StatelessWidget {
  final String text;
  final StatusBadgeType type;
  final IconData? icon;

  const StatusBadge({
    super.key,
    required this.text,
    this.type = StatusBadgeType.statusOnly,
    this.icon,
  });

  factory StatusBadge.completed({String text = 'Completed'}) => StatusBadge(
        text: text,
        type: StatusBadgeType.completed,
        icon: Icons.check_circle_outline_rounded,
      );

  factory StatusBadge.statusOnly({String text = 'Status Only'}) => StatusBadge(
        text: text,
        type: StatusBadgeType.statusOnly,
        icon: Icons.lock_outline_rounded,
      );

  factory StatusBadge.free({String text = '100% FREE'}) => StatusBadge(
        text: text,
        type: StatusBadgeType.free,
        icon: Icons.auto_awesome,
      );

  factory StatusBadge.freePass({String text = 'Free Pass'}) => StatusBadge(
        text: text,
        type: StatusBadgeType.freePass,
        icon: Icons.check_rounded,
      );

  factory StatusBadge.topOneOnly({String text = 'Top 1 Only'}) => StatusBadge(
        text: text,
        type: StatusBadgeType.topOneOnly,
        icon: Icons.lock_outline_rounded,
      );

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;
    Color borderColor;

    switch (type) {
      case StatusBadgeType.completed:
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF059669);
        borderColor = const Color(0xFFA7F3D0);
        break;
      case StatusBadgeType.statusOnly:
      case StatusBadgeType.topOneOnly:
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        borderColor = const Color(0xFFFDE68A);
        break;
      case StatusBadgeType.free:
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF059669);
        borderColor = const Color(0xFF6EE7B7);
        break;
      case StatusBadgeType.freePass:
        bgColor = const Color(0xFFE0F2FE);
        textColor = const Color(0xFF0284C7);
        borderColor = const Color(0xFFBAE6FD);
        break;
      default:
        bgColor = const Color(0xFFF1F5F9);
        textColor = const Color(0xFF475569);
        borderColor = const Color(0xFFE2E8F0);
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: textColor),
            const SizedBox(width: 3),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
