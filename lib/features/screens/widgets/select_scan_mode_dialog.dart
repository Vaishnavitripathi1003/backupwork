

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../data/models/finger_scan_status_model.dart';
import '../../../../data/models/user_models.dart';
import '../../../core/Global/global_class.dart';
import '../../../core/database/database_helper.dart';
import '../../../core/native/biometric_scanner.dart';
import '../../../core/native/native_scan.dart';
import '../../../core/network/api_service.dart';
import '../../../core/storage/user_pref.dart';
import '../../../core/utils/responsive.dart';

class SelectScanModeDialog extends StatefulWidget {
  const SelectScanModeDialog({super.key});

  @override
  State<SelectScanModeDialog> createState() => _SelectScanModeDialogState();
}

class _SelectScanModeDialogState extends State<SelectScanModeDialog> {
  int _selectedMode = 0; // 0: Thumb + 4-Fingers Mode, 1: Single Fingertip Mode

  void _onSelectMode(int mode) async {
    setState(() {
      _selectedMode = mode;
    });

    Navigator.pop(context); // Close dialog

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = UserPref(prefs).getToken() ?? '';
      final memberId = GlobalClass.selected_member;

      if (token.isNotEmpty && memberId.isNotEmpty) {
        print("groupScan Called ${_selectedMode}");
        final bool isSuccess = mode == 0
            ? await BiometricScanner.startGroupScan(
                token: token,
                userDataId: memberId,
              )
            : await BiometricScanner.start10FingerScan(
                token: token,
                userDataId: memberId,
              );

        if (isSuccess && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ Fingerprints uploaded successfully to server!'),
              backgroundColor: Color(0xFF22C55E),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } else {
        // Fallback to NativeScan if token or member ID is not set
        final scanModeKey = mode == 1 ? 'single' : 'group';
        final results = await NativeScan.startScan(mode: scanModeKey);
        if (results.isNotEmpty && mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Scan completed! ${results.length} fingers captured.'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    } on PlatformException catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scan error: ${e.message}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = context.isNarrowMobile;

    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(
        horizontal: context.scalePadding(20),
        vertical: context.scalePadding(24),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(28),
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: context.responsiveValue(
            mobile: 440,
            tablet: 480,
            desktop: 520,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(context.scalePadding(22.0)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row: Fingerprint Icon + Title + Close Button
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    Icons.fingerprint_rounded,
                    color: const Color(0xFF2563EB),
                    size: isNarrow ? 24 : 28,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Select Scan Mode',
                      style: TextStyle(
                        fontSize: context.scaleFont(20),
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Icon(
                      Icons.close_rounded,
                      color: const Color(0xFF94A3B8),
                      size: isNarrow ? 20 : 24,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Subtitle Instructions
              Text(
                'Choose how you want to capture fingerprints for this assessment:',
                style: TextStyle(
                  fontSize: context.scaleFont(13),
                  color: const Color(0xFF64748B),
                  height: 1.4,
                ),
              ),

              const SizedBox(height: 18),

              // Option 1 Card: Thumb + 4-Fingers Mode
              _buildModeCard(
                context,
                isSelected: _selectedMode == 0,
                icon: Icons.touch_app_rounded,
                title: 'Thumb + 4-Fingers Mode',
                subtitle: '4 Guided Steps (Thumb & 4-Finger Clusters)',
                accuracyText: '98.2% High Accuracy',
                timeText: 'Est. ~1 min completion time',
                onTap: () => _onSelectMode(0),
              ),

              const SizedBox(height: 14),

              // Option 2 Card: Single Fingertip Mode RECOMMENDED
              _buildModeCard(
                context,
                isSelected: _selectedMode == 1,
                icon: Icons.fingerprint_rounded,
                title: 'Single Fingertip Mode ⭐',
                tagline: 'RECOMMENDED',
                subtitle: '10 Guided Steps (Each Finger Scanned Separately)',
                accuracyText: '99.8% Maximum Biometric Accuracy',
                timeText: 'Est. ~2.5 mins completion time',
                onTap: () => _onSelectMode(1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModeCard(
    BuildContext context, {
    required bool isSelected,
    required IconData icon,
    required String title,
    String? tagline,
    required String subtitle,
    required String accuracyText,
    required String timeText,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(context.scalePadding(16)),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? const Color(0xFF2563EB) : const Color(0xFFE2E8F0),
            width: isSelected ? 2.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFF2563EB).withValues(alpha: 0.12),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icon Badge Circle
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFDBEAFE),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    color: const Color(0xFF2563EB),
                    size: 24,
                  ),
                ),

                const SizedBox(width: 12),

                // Title & Subtitle Column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              title,
                              style: TextStyle(
                                fontSize: context.scaleFont(15),
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF0F172A),
                              ),
                            ),
                          ),
                          if (isSelected)
                            const Icon(
                              Icons.check_circle_rounded,
                              color: Color(0xFF2563EB),
                              size: 20,
                            ),
                        ],
                      ),
                      if (tagline != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          tagline,
                          style: TextStyle(
                            fontSize: context.scaleFont(11),
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: context.scaleFont(12),
                          color: const Color(0xFF64748B),
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Badges Row
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFE0F2FE),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    accuracyText,
                    style: TextStyle(
                      fontSize: context.scaleFont(11.5),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1D4ED8),
                    ),
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    timeText,
                    style: TextStyle(
                      fontSize: context.scaleFont(11.5),
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF15803D),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
