import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../screens/camerawork/camera_scan_screen.dart';
import '../../../screens/widgets/hand_capture_graphic.dart';

typedef CaptureCard = ({String label, HandCaptureType type});

class CapturePage extends StatefulWidget {
  final String scanMode; // 'thumb_4finger' or 'single_fingertip'

  const CapturePage({
    super.key,
    this.scanMode = 'thumb_4finger',
  });

  @override
  State<CapturePage> createState() => _CapturePageState();
}

class _CapturePageState extends State<CapturePage> {
  bool get _isSingle => widget.scanMode == 'single_fingertip';

  // Set of captured finger types that have been accepted
  final Set<HandCaptureType> _capturedFingers = {};

  Future<void> _openCameraScan(String fingerTitle, HandCaptureType type) async {
    // Open Camera Scan Screen and await review result (true if accepted)
     const platform = MethodChannel('com.example.fingerprintworkdemo/native');

    try {
      // Check permissions and request if needed, then open the scan screen
      final bool hasPermission = await platform.invokeMethod('hasCameraPermission');
      if (!hasPermission) {
        final bool granted = await platform.invokeMethod('requestCameraPermission');
        if (!granted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Camera permission is required!')),
          );
          return;
        }
      }

      // Start the actual compose native scan activity
      final result = await platform.invokeMethod('startScan', {'mode': 'group'});
      print('Result from native scan: $result');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan Finished!')),
      );
    } on PlatformException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to open camera: ${e.message}')),
      );
    }

    /*if (result == true) {
      setState(() {
        _capturedFingers.add(type);
      });
    }*/
  }

  List<CaptureCard> _getCardsForScanMode() {
    if (_isSingle) {
      return const [
        (label: 'Left Thumb', type: HandCaptureType.leftThumb),
        (label: 'Left Index', type: HandCaptureType.leftIndex),
        (label: 'Left Middle', type: HandCaptureType.leftMiddle),
        (label: 'Left Ring', type: HandCaptureType.leftRing),
        (label: 'Left Little', type: HandCaptureType.leftLittle),
        (label: 'Right Thumb', type: HandCaptureType.rightThumb),
        (label: 'Right Index', type: HandCaptureType.rightIndex),
        (label: 'Right Middle', type: HandCaptureType.rightMiddle),
        (label: 'Right Ring', type: HandCaptureType.rightRing),
        (label: 'Right Little', type: HandCaptureType.rightLittle),
      ];
    }
    return const [
      (label: 'Left Thumb', type: HandCaptureType.leftThumb),
      (label: 'Right Thumb', type: HandCaptureType.rightThumb),
      (label: 'L-Hand Fingers', type: HandCaptureType.leftFingers),
      (label: 'R-Hand Fingers', type: HandCaptureType.rightFingers),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final cards = _getCardsForScanMode();

    return Scaffold(
      backgroundColor: const Color(0xFFF1F5F9),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1F5F9),
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Color(0xFF0F172A),
            size: 20,
          ),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          _isSingle ? 'Single Fingertip Capture' : 'Capture',
          style: TextStyle(
            fontSize: context.scaleFont(20),
            fontWeight: FontWeight.w800,
            color: const Color(0xFF38BDF8),
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFFF8FAFC),
                  Color(0xFFE2E8F0),
                ],
              ),
            ),
          ),

          // Decorative soft circles
          Positioned(
            top: -140,
            left: -80,
            child: _softCircle(260, const Color(0xFFBAE6FD).withValues(alpha: 0.35)),
          ),
          Positioned(
            top: 120,
            right: -110,
            child: _softCircle(280, const Color(0xFF7DD3FC).withValues(alpha: 0.22)),
          ),
          Positioned(
            bottom: -150,
            left: -60,
            child: _softCircle(260, const Color(0xFF38BDF8).withValues(alpha: 0.14)),
          ),

          // Main content
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scalePadding(20),
                    vertical: context.scalePadding(16),
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: context.responsiveValue(
                          mobile: 520,
                          tablet: 600,
                          desktop: 680,
                        ),
                      ),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),

                          // Mode chip
                          _buildModeChip(),

                          const SizedBox(height: 16),

                          // Cards grid
                          GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                              childAspectRatio: 0.95,
                            ),
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: cards.length,
                            itemBuilder: (context, index) {
                              final item = cards[index];
                              return _buildCaptureCard(
                                label: item.label,
                                type: item.type,
                              );
                            },
                          ),

                          const SizedBox(height: 24),

                          // Instruction footer
                          _buildInstruction(),

                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _softCircle(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildModeChip() {
    final int capturedCount = _capturedFingers.length;
    final int totalCount = _isSingle ? 10 : 4;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: const Color(0xFF38BDF8).withValues(alpha: 0.35),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF38BDF8).withValues(alpha: 0.10),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: capturedCount == totalCount
                  ? const Color(0xFF22C55E)
                  : const Color(0xFF38BDF8),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$capturedCount / $totalCount Captured',
            style: TextStyle(
              fontSize: context.scaleFont(12.5),
              fontWeight: FontWeight.w700,
              color: capturedCount == totalCount
                  ? const Color(0xFF15803D)
                  : const Color(0xFF0369A1),
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstruction() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            size: 18,
            color: Color(0xFF38BDF8),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              _isSingle
                  ? 'Tap each finger to scan individual fingertips'
                  : 'Click all fingers before scan',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: context.scaleFont(13),
                fontWeight: FontWeight.w600,
                color: AppColors.onboardingTextBody,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaptureCard({
    required String label,
    required HandCaptureType type,
  }) {
    final bool isCaptured = _capturedFingers.contains(type);

    return Stack(
      children: [
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: isCaptured
                  ? const Color(0xFF22C55E)
                  : const Color(0xFFE2E8F0),
              width: isCaptured ? 2.0 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: isCaptured
                    ? const Color(0xFF22C55E).withValues(alpha: 0.15)
                    : const Color(0xFF0F172A).withValues(alpha: 0.07),
                blurRadius: 22,
                spreadRadius: 0,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(22),
            child: InkWell(
              onTap: () => _openCameraScan(label, type),
              borderRadius: BorderRadius.circular(22),
              splashColor: const Color(0xFF38BDF8).withValues(alpha: 0.10),
              highlightColor: const Color(0xFF38BDF8).withValues(alpha: 0.05),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Hand graphic with halo
                    Expanded(
                      child: Center(
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              width: 96,
                              height: 96,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    isCaptured
                                        ? const Color(0xFF22C55E).withValues(alpha: 0.20)
                                        : const Color(0xFF38BDF8).withValues(alpha: 0.18),
                                    const Color(0xFF38BDF8).withValues(alpha: 0.0),
                                  ],
                                ),
                              ),
                            ),
                            HandCaptureGraphic(
                              type: type,
                              size: 80,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Label
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: context.scaleFont(14),
                        fontWeight: FontWeight.w700,
                        color: isCaptured
                            ? const Color(0xFF15803D)
                            : AppColors.onboardingTextTitle,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Green Tick Checkmark Badge on Top Right
        if (isCaptured)
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Color(0xFF22C55E),
                    blurRadius: 8,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.check_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
      ],
    );
  }
}
