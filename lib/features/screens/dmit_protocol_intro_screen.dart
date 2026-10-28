import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/Global/global_class.dart';
import '../../core/database/database_helper.dart';
import '../../core/native/biometric_scanner.dart';
import '../../core/storage/user_pref.dart';
import '../../core/utils/responsive.dart';
import 'biometric_scanner_screen.dart';

class DmitProtocolIntroScreen extends StatefulWidget {
  final String? candidateName;

  const DmitProtocolIntroScreen({super.key, this.candidateName});

  @override
  State<DmitProtocolIntroScreen> createState() =>
      _DmitProtocolIntroScreenState();
}

class _DmitProtocolIntroScreenState extends State<DmitProtocolIntroScreen> {
  String _candidateName = 'Candidate';

  @override
  void initState() {
    super.initState();
    _loadCandidateName();
  }

  Future<void> _loadCandidateName() async {
    if (widget.candidateName != null && widget.candidateName!.isNotEmpty) {
      setState(() => _candidateName = widget.candidateName!);
      return;
    }

    try {
      final memberId = GlobalClass.selected_member;
      if (memberId.isNotEmpty) {
        final user = await DatabaseHelper.instance.getMemberById(memberId);
        if (user != null) {
          final name = (user.dataName != null && user.dataName!.isNotEmpty)
              ? user.dataName!
              : (user.firstName != null && user.firstName!.isNotEmpty)
                  ? user.firstName!
                  : 'Candidate';
          if (mounted) setState(() => _candidateName = name);
        }
      }
    } catch (e) {
      debugPrint('Error loading candidate name: $e');
    }
  }

/*  Future<void> _proceedToScanner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = UserPref(prefs).getToken() ?? '';
      final memberId = GlobalClass.selected_member;

      debugPrint("Starting scanner -> token: ${token.isNotEmpty}, memberId: $memberId");

      if (token.isNotEmpty && memberId.isNotEmpty) {
        final isSuccess = await BiometricScanner.start10FingerScan(
          token: token,
          userDataId: memberId,
        );

        if (mounted) {
          if (isSuccess) {
            // 1) Update SQLite user_table isReportGenerated = 1
            await DatabaseHelper.instance.updateReportGeneratedStatus(memberId, true);

            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('✓ All 10 Fingerprints Uploaded to Server!'),
                  backgroundColor: Color(0xFF22C55E),
                ),
              );
              Navigator.pop(context, true); // Return true to HomeScreen
            }
          } else {
            // Fallback in-app scanner if native scanner fails or is cancelled
            *//*Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => BiometricScannerScreen(
                  candidateName: _candidateName,
                ),
              ),
            );*//*
          }
        }
      } else {
        // Fallback in-app scanner when token or member ID is missing
        if (mounted) {
          *//*Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => BiometricScannerScreen(
                candidateName: _candidateName,
              ),
            ),
          );*//*
        }
      }
    } catch (e) {
      debugPrint('Error starting scanner: $e');
      if (mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (_) => BiometricScannerScreen(
              candidateName: _candidateName,
            ),
          ),
        );
      }
    }
  }*/

  Future<void> _proceedToScanner() async {
    try {
      // STEP 1: Check camera permission
      PermissionStatus cameraStatus = await Permission.camera.status;

      debugPrint("Camera permission status: $cameraStatus");

      // STEP 2: Request permission dynamically
      if (!cameraStatus.isGranted) {
        cameraStatus = await Permission.camera.request();

        debugPrint("Camera permission after request: $cameraStatus");
      }

      if (!mounted) return;

      // STEP 3: Handle permanently denied permission
      if (cameraStatus.isPermanentlyDenied) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Camera permission is permanently denied. Enable it in Settings.',
            ),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'SETTINGS',
              textColor: Colors.white,
              onPressed: () {
                openAppSettings();
              },
            ),
          ),
        );
        return;
      }

      // STEP 4: Handle denied or restricted permission
      if (!cameraStatus.isGranted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Camera permission is required for fingerprint scanning.',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      debugPrint("Camera permission granted. Starting scanner...");

      // STEP 5: Get token and member ID
      final prefs = await SharedPreferences.getInstance();
      final token = UserPref(prefs).getToken() ?? '';
      final memberId = GlobalClass.selected_member;

      debugPrint(
        "Starting scanner -> token: ${token.isNotEmpty}, memberId: $memberId",
      );

      if (!mounted) return;

      if (token.isNotEmpty && memberId.isNotEmpty) {
        // STEP 6: Open native scanner
        final isSuccess = await BiometricScanner.start10FingerScan(
          token: token,
          userDataId: memberId,
        );

        debugPrint("Biometric scanner result: $isSuccess");

        if (!mounted) return;

        if (isSuccess) {
          // Upload succeeded; report readiness is verified separately via
          // findIsReportGeneratedByUserDataId. Never mark ready here.
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✓ All 10 Fingerprints Uploaded to Server!'),
              backgroundColor: Color(0xFF22C55E),
            ),
          );

          Navigator.pop(context, true);
        } else {
          debugPrint("Native scanner failed or was cancelled");

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Fingerprint scan was not completed.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        debugPrint("Token or Member ID is missing");

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User session or member ID is missing.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e, stackTrace) {
      debugPrint("Error starting scanner: $e");
      debugPrint("Scanner stack trace: $stackTrace");

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Scanner error: $e'),
            backgroundColor: Colors.red,
          ),
        );

        // Optional fallback scanner:
        // Navigator.of(context).push(
        //   MaterialPageRoute(
        //     builder: (_) => BiometricScannerScreen(
        //       candidateName: _candidateName,
        //     ),
        //   ),
        // );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Color(0xFF0F172A)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Column(
          children: [
            Text(
              'DERMATOGLYPHICS PROTOCOL',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                color: Color(0xFF6366F1),
                letterSpacing: 0.8,
              ),
            ),
            SizedBox(height: 2),
          ],
        ),
        centerTitle: true,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Color(0xFFEEF2FF),
                shape: BoxShape.circle,
              ),
              child: const Text('🧬', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. Top Hero Card
                    _buildHeroCard(context, isNarrow),

                    const SizedBox(height: 20),

                    // 2. Section Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '6 TRANSFORMATIVE ADVANTAGES',
                          style: TextStyle(
                            fontSize: context.scaleFont(11),
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFF0F172A),
                            letterSpacing: 0.6,
                          ),
                        ),
                        const Text(
                          'Personalized for You',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF6366F1),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // 3. Advantages Cards
                    _buildAdvantageCard(
                      iconWidget: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFEF3C7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.lightbulb_outlined,
                            color: Color(0xFFD97706), size: 22),
                      ),
                      title: 'Inborn Strengths vs Acquired Skills',
                      badgeLabel: 'Genetic Talents',
                      badgeBg: const Color(0xFFF1F5F9),
                      badgeText: const Color(0xFF475569),
                      description:
                          'Decode natural genetic potential and innate cognitive strengths that remain stable throughout life.',
                    ),

                    const SizedBox(height: 12),

                    _buildAdvantageCard(
                      iconWidget: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFE0F2FE),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.layers_outlined,
                            color: Color(0xFF0284C7), size: 22),
                      ),
                      title: 'Optimal Sensory Learning Style (VAK)',
                      badgeLabel: 'Learning Velocity',
                      badgeBg: const Color(0xFFF1F5F9),
                      badgeText: const Color(0xFF475569),
                      description:
                          'Identify whether you retain best through Visual (charts), Auditory (lectures), or Kinesthetic (hands-on tactile doing).',
                    ),

                    const SizedBox(height: 12),

                    _buildAdvantageCard(
                      iconWidget: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3E8FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.psychology_outlined,
                            color: Color(0xFF9333EA), size: 22),
                      ),
                      title: 'Hemispheric Brain Dominance',
                      badgeLabel: 'Neuro-Balance',
                      badgeBg: const Color(0xFFF1F5F9),
                      badgeText: const Color(0xFF475569),
                      description:
                          'Discover Left Brain (sequential logic & math) vs Right Brain (creative spatial imagination) balance.',
                    ),

                    const SizedBox(height: 12),

                    _buildAdvantageCard(
                      iconWidget: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFECFDF5),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.explore_outlined,
                            color: Color(0xFF059669), size: 22),
                      ),
                      title: 'Precision Stream & Career Roadmapping',
                      badgeLabel: 'Career Fit',
                      badgeBg: const Color(0xFFF1F5F9),
                      badgeText: const Color(0xFF475569),
                      description:
                          'Avoid costly trial-and-error in Class 9–11; pinpoint alignment for PCM, PCB, Commerce, or Humanities.',
                    ),

                    const SizedBox(height: 12),

                    _buildAdvantageCard(
                      iconWidget: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFFFE4E6),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.show_chart_rounded,
                            color: Color(0xFFE11D48), size: 22),
                      ),
                      title: 'EQ, IQ, AQ & CQ Quotient Profiling',
                      badgeLabel: 'Mental Agility',
                      badgeBg: const Color(0xFFF1F5F9),
                      badgeText: const Color(0xFF475569),
                      description:
                          'Measure Emotional, Intellectual, Adversity (grit & resilience), and Creative quotients.',
                    ),

                    const SizedBox(height: 12),

                    _buildAdvantageCard(
                      iconWidget: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: const BoxDecoration(
                          color: Color(0xFFF3E8FF),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.favorite_outline_rounded,
                            color: Color(0xFF7C3AED), size: 22),
                      ),
                      title: 'Stress Reduction & Parent Harmony',
                      badgeLabel: 'Wellbeing',
                      badgeBg: const Color(0xFFF1F5F9),
                      badgeText: const Color(0xFF475569),
                      description:
                          'Replace parental expectations with scientific clarity, preventing exam fatigue and student burnout.',
                    ),

                    const SizedBox(height: 14),

                    // Zero Raw Biometric Storage Card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFA7F3D0)),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.verified_user_outlined,
                                color: Color(0xFF059669), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text(
                                  'Zero Raw Biometric Storage',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF065F46),
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Fingerprint patterns are immediately converted into mathematical ridge counts (TRC & ATD angles). No fingerprint images are ever stored or transmitted.',
                                  style: TextStyle(
                                    fontSize: 11.5,
                                    color: Color(0xFF047857),
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Sticky Bottom Action Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, -4),
                  ),
                ],
              ),
              child: SizedBox(
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF6366F1),
                        Color(0xFF4F46E5),
                        Color(0xFF7C3AED),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF4F46E5).withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _proceedToScanner,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.fingerprint_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 6),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Proceed to 10–Finger Biometric Scan',
                              style: TextStyle(
                                fontSize: context.scaleFont(13.5),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 4),
                        const Icon(Icons.arrow_forward_rounded,
                            color: Colors.white, size: 18),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeroCard(BuildContext context, bool isNarrow) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E1B4B),
            Color(0xFF312E81),
            Color(0xFF1E1B4B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E1B4B).withValues(alpha: 0.35),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF0284C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'SCIENTIFIC FOUNDATION',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 0.6,
              ),
            ),
          ),

          const SizedBox(height: 12),

          Text(
            '10–Finger Biometric Brain Mapping for $_candidateName',
            style: TextStyle(
              fontSize: context.scaleFont(20),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              height: 1.25,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'Medical neuroscience proves that fingerprint epidermal ridges form synchronously with the cerebral neocortex during the 13th to 19th week of intrauterine gestation.',
            style: TextStyle(
              fontSize: 12.5,
              color: Color(0xFFC7D2FE),
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Text(
                  '✓ 10 Cerebral Lobes Mapped',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF38BDF8),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                  border:
                      Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: const Text(
                  '✓ 100% Non–Invasive',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF34D399),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAdvantageCard({
    required Widget iconWidget,
    required String title,
    required String badgeLabel,
    required Color badgeBg,
    required Color badgeText,
    required String description,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE2E8F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          iconWidget,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: badgeBg,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badgeLabel,
                        style: TextStyle(
                          fontSize: 9.5,
                          fontWeight: FontWeight.bold,
                          color: badgeText,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  description,
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: Color(0xFF64748B),
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
