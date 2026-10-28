import 'package:flutter/material.dart';
import '../../../core/utils/responsive.dart';

/// Compact, responsive Upgrade & Paywall modal.
///
/// - Header, scrollable body and pay button are separate, so the Pay button
///   is always visible, even on small phones or in landscape.
/// - The two breakdown cards sit side by side and stack on very narrow widths.
/// - Text scaling is capped, so large system fonts cannot overflow the layout.
class UpgradePlanModal extends StatefulWidget {
  const UpgradePlanModal({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => const UpgradePlanModal(),
    );
  }

  @override
  State<UpgradePlanModal> createState() => _UpgradePlanModalState();
}

class _Plan {
  final String title;
  final String? badge;
  final String subtitle;
  final String originalPrice;
  final String price;

  const _Plan({
    required this.title,
    this.badge,
    required this.subtitle,
    required this.originalPrice,
    required this.price,
  });
}

class _UpgradePlanModalState extends State<UpgradePlanModal> {
  static const List<_Plan> _plans = [
    _Plan(
      title: 'Family VIP Pack',
      badge: 'Best Value',
      subtitle: 'Up to 5 members • All reports + Live Counselor slot',
      originalPrice: '₹2,999',
      price: '₹999',
    ),
    _Plan(
      title: 'Single Student Pass',
      subtitle: '1 student • Lifetime access to all reports',
      originalPrice: '₹1,499',
      price: '₹499',
    ),
  ];

  static const List<String> _freeItems = [
    'Full Personality Blend',
    'Primary & Secondary Traits',
    'Basic Element Statuses',
    '3 Free Basic Vayo AI queries',
  ];

  static const List<String> _paidItems = [
    '8 Multi Intelligence Wheel',
    '5 Senses Deep Analysis',
    'Full Brain Dominance Traits',
    '32–Page Certified PDF Dossier',
    'Unlimited AI + Live Counselor',
  ];

  int _selectedPlanIndex = 0; // 0: Family VIP Pack, 1: Single Student Pass

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.sizeOf(context);
    final scaler = MediaQuery.textScalerOf(context).clamp(maxScaleFactor: 1.2);

    return MediaQuery(
      data: MediaQuery.of(context).copyWith(textScaler: scaler),
      child: Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.symmetric(
          horizontal: context.scalePadding(10),
          vertical: context.scalePadding(14),
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: 480,
            maxHeight: size.height * 0.9,
          ),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.28),
                  blurRadius: 28,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildHeader(context),

                  // Scrollable middle part
                  Flexible(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildBreakdown(context),
                          const SizedBox(height: 12),
                          for (int i = 0; i < _plans.length; i++) ...[
                            _buildPlanCard(context, i),
                            if (i != _plans.length - 1)
                              const SizedBox(height: 8),
                          ],
                        ],
                      ),
                    ),
                  ),

                  // Pay button always visible
                  _buildFooter(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------

  Widget _buildHeader(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 14, 10, 14),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF312E81),
            Color(0xFF3730A3),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crown
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
            ),
            child: const Center(
              child: Text('👑', style: TextStyle(fontSize: 22)),
            ),
          ),

          const SizedBox(width: 12),

          // Texts
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFFDE047).withValues(alpha: 0.4),
                    ),
                  ),
                  child: const Text(
                    '⚡ Freemium Plan Architecture',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFDE047),
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Unlock Full Cognitive Suite',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.scaleFont(18),
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'Free plan includes full Personality Type. Unlock all 8 Intelligences, 5 Senses, Brain Dominance & Live Sessions.',
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.scaleFont(11.5),
                    color: const Color(0xFFC7D2FE),
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),

          // Close
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.only(left: 6),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded,
                  color: Colors.white, size: 16),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Freemium breakdown
  // ---------------------------------------------------------------------

  Widget _buildBreakdown(BuildContext context) {
    final free = _breakdownBox(
      emoji: '✨',
      title: 'Free Forever',
      items: _freeItems,
      bg: const Color(0xFFFAF5FF),
      border: const Color(0xFFE9D5FF),
      titleColor: const Color(0xFF6B21A8),
      textColor: const Color(0xFF7E22CE),
    );
    final paid = _breakdownBox(
      emoji: '🔒',
      title: 'Unlocks on Pay',
      items: _paidItems,
      bg: const Color(0xFFEFF6FF),
      border: const Color(0xFFBFDBFE),
      titleColor: const Color(0xFF1D4ED8),
      textColor: const Color(0xFF1E40AF),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'CURRENT FREEMIUM BREAKDOWN',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: context.scaleFont(10),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3E8FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'BASIC FREE TIER',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    color: Color(0xFF7C3AED),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Side by side normally, stacked on very narrow widths
          LayoutBuilder(
            builder: (context, constraints) {
              final stacked = constraints.maxWidth < 320;
              if (stacked) {
                return Column(
                  children: [free, const SizedBox(height: 8), paid],
                );
              }
              return IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: free),
                    const SizedBox(width: 8),
                    Expanded(child: paid),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _breakdownBox({
    required String emoji,
    required String title,
    required List<String> items,
    required Color bg,
    required Color border,
    required Color titleColor,
    required Color textColor,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 12)),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    color: titleColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final item in items) _bullet(item, textColor),
        ],
      ),
    );
  }

  Widget _bullet(String text, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('• ',
              style: TextStyle(
                  fontSize: 10.5, fontWeight: FontWeight.bold, color: color)),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w600,
                color: color,
                height: 1.2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Plan cards
  // ---------------------------------------------------------------------

  Widget _buildPlanCard(BuildContext context, int index) {
    final plan = _plans[index];
    final isSelected = _selectedPlanIndex == index;

    return GestureDetector(
      onTap: () => setState(() => _selectedPlanIndex = index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFF5F3FF) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
            isSelected ? const Color(0xFF6366F1) : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.2,
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Selection dot
            Icon(
              isSelected
                  ? Icons.radio_button_checked_rounded
                  : Icons.radio_button_unchecked_rounded,
              size: 18,
              color: isSelected
                  ? const Color(0xFF6366F1)
                  : const Color(0xFFCBD5E1),
            ),
            const SizedBox(width: 10),

            // Title + subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 2,
                    children: [
                      Text(
                        plan.title,
                        style: TextStyle(
                          fontSize: context.scaleFont(13.5),
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF0F172A),
                        ),
                      ),
                      if (plan.badge != null)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFEF08A),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            plan.badge!,
                            style: const TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF854D0E),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    plan.subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: Color(0xFF64748B),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(width: 8),

            // Prices (scale down instead of overflowing)
            ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 80),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      plan.price,
                      style: TextStyle(
                        fontSize: context.scaleFont(19),
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      plan.originalPrice,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF94A3B8),
                        decoration: TextDecoration.lineThrough,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Footer (Pay button)
  // ---------------------------------------------------------------------

  Widget _buildFooter(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: Color(0xFFE2E8F0))),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SizedBox(
        height: 48,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [
                Color(0xFF6366F1),
                Color(0xFF7C3AED),
                Color(0xFF9333EA),
              ],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF7C3AED).withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: ElevatedButton(
            onPressed: () {
              final messenger = ScaffoldMessenger.of(context);
              Navigator.pop(context);
              messenger.showSnackBar(
                const SnackBar(
                  content: Text('✓ Redirecting to Secure Razorpay Gateway...'),
                  backgroundColor: Color(0xFF22C55E),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                'Pay & Unlock Everything Now ✨',
                maxLines: 1,
                style: TextStyle(
                  fontSize: context.scaleFont(14.5),
                  fontWeight: FontWeight.w800,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}