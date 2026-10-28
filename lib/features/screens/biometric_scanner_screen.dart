import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/utils/responsive.dart';

/// Screen 2: "10-Fingerprint Capture Biometric Scanner" optimized embedded camera view inside target box.
class BiometricScannerScreen extends StatefulWidget {
  final String candidateName;

  const BiometricScannerScreen({
    super.key,
    this.candidateName = 'Aarav',
  });

  @override
  State<BiometricScannerScreen> createState() => _BiometricScannerScreenState();
}

class _BiometricScannerScreenState extends State<BiometricScannerScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isScanning = false;
  bool _isTorchOn = true;
  bool _isAutoCapture = false;

  bool _isLeftHand = true; // true = Left Hand (L1-L5), false = Right Hand (R1-R5)
  int _selectedFingerIndex = 0; // 0 to 4 (Thumb, Index, Middle, Ring, Little)
  final Set<String> _scannedFingerKeys = {}; // Set of keys like "L1", "L2", "R1", etc.
  final Map<String, String> _scannedFingerPatterns = {}; // Map of finger code to detected pattern

  static const List<Map<String, String>> _leftFingers = [
    {
      'code': 'L1',
      'label': 'Thumb',
      'fullTitle': 'Left Thumb',
      'brainMapping': 'Right Prefrontal (Leadership & Vision)',
    },
    {
      'code': 'L2',
      'label': 'Index',
      'fullTitle': 'Left Index Finger',
      'brainMapping': 'Right Frontal (Logic & Spatial Reasoning)',
    },
    {
      'code': 'L3',
      'label': 'Middle',
      'fullTitle': 'Left Middle Finger',
      'brainMapping': 'Right Parietal (Kinesthetic & Motor Skills)',
    },
    {
      'code': 'L4',
      'label': 'Ring',
      'fullTitle': 'Left Ring Finger',
      'brainMapping': 'Right Temporal (Auditory & Musical Perception)',
    },
    {
      'code': 'L5',
      'label': 'Little',
      'fullTitle': 'Left Little Finger',
      'brainMapping': 'Right Occipital (Visual & Graphic Perception)',
    },
  ];

  static const List<Map<String, String>> _rightFingers = [
    {
      'code': 'R1',
      'label': 'Thumb',
      'fullTitle': 'Right Thumb',
      'brainMapping': 'Left Prefrontal (Management & Action Planning)',
    },
    {
      'code': 'R2',
      'label': 'Index',
      'fullTitle': 'Right Index Finger',
      'brainMapping': 'Left Frontal (Linguistic & Language Analysis)',
    },
    {
      'code': 'R3',
      'label': 'Middle',
      'fullTitle': 'Right Middle Finger',
      'brainMapping': 'Left Parietal (Fine Motor & Tactile Control)',
    },
    {
      'code': 'R4',
      'label': 'Ring',
      'fullTitle': 'Right Ring Finger',
      'brainMapping': 'Left Temporal (Phonetic & Audio Processing)',
    },
    {
      'code': 'R5',
      'label': 'Little',
      'fullTitle': 'Right Little Finger',
      'brainMapping': 'Left Occipital (Visual Identification & Detail)',
    },
  ];

  List<Map<String, String>> get _currentFingerList =>
      _isLeftHand ? _leftFingers : _rightFingers;

  Map<String, String> get _activeFinger =>
      _currentFingerList[_selectedFingerIndex];

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isNotEmpty) {
        final backCamera = cameras.firstWhere(
          (cam) => cam.lensDirection == CameraLensDirection.back,
          orElse: () => cameras.first,
        );

        _cameraController = CameraController(
          backCamera,
          ResolutionPreset.max, // Maximum sensor resolution for fingertip ridge clarity
          enableAudio: false,
          imageFormatGroup: ImageFormatGroup.jpeg,
        );

        await _cameraController!.initialize();

        // Enable Torch Flash for maximum skin illumination & ridge contrast
        try {
          await _cameraController!.setFlashMode(
              _isTorchOn ? FlashMode.torch : FlashMode.off);
        } catch (e) {
          debugPrint('Torch setting error: $e');
        }

        // Lock Center Macro Auto-Focus & Exposure
        try {
          await _cameraController!.setFocusMode(FocusMode.auto);
          await _cameraController!.setFocusPoint(const Offset(0.5, 0.5));
          await _cameraController!.setExposurePoint(const Offset(0.5, 0.5));
        } catch (e) {
          debugPrint('Focus setting error: $e');
        }

        if (mounted) {
          setState(() {
            _isCameraInitialized = true;
          });
        }
      }
    } catch (e) {
      debugPrint('In-app camera initialization error: $e');
    }
  }

  Future<void> _toggleTorch() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized) return;

    setState(() {
      _isTorchOn = !_isTorchOn;
    });

    try {
      await _cameraController!
          .setFlashMode(_isTorchOn ? FlashMode.torch : FlashMode.off);
    } catch (e) {
      debugPrint('Torch toggle exception: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  String _mapFingerCodeToStepName(String code) {
    switch (code) {
      case 'L1':
        return 'LEFT_THUMB_IND';
      case 'L2':
        return 'LEFT_INDEX_IND';
      case 'L3':
        return 'LEFT_MIDDLE_IND';
      case 'L4':
        return 'LEFT_RING_IND';
      case 'L5':
        return 'LEFT_LITTLE_IND';
      case 'R1':
        return 'RIGHT_THUMB_IND';
      case 'R2':
        return 'RIGHT_INDEX_IND';
      case 'R3':
        return 'RIGHT_MIDDLE_IND';
      case 'R4':
        return 'RIGHT_RING_IND';
      case 'R5':
        return 'RIGHT_LITTLE_IND';
      default:
        return 'LEFT_THUMB_IND';
    }
  }

  Future<void> _captureActiveFinger() async {
    if (_isScanning) return;

    setState(() {
      _isScanning = true;
    });

    final currentCode = _activeFinger['code']!;

    try {
      if (_cameraController != null && _cameraController!.value.isInitialized) {
        // Step 1: Ensure Torch is on for maximum skin illumination & ridge contrast
        try {
          if (_isTorchOn) {
            await _cameraController!.setFlashMode(FlashMode.torch);
          }
        } catch (_) {}

        // Step 2: Lock center focus & exposure on fingertip pad inside target box
        try {
          await _cameraController!.setFocusPoint(const Offset(0.5, 0.5));
          await _cameraController!.setExposurePoint(const Offset(0.5, 0.5));
          await _cameraController!.setFocusMode(FocusMode.auto);
        } catch (_) {}

        await Future.delayed(const Duration(milliseconds: 200));

        try {
          await _cameraController!.setFocusMode(FocusMode.locked);
        } catch (_) {}

        // Step 3: Capture image directly from the camera inside the target box
        final file = await _cameraController!.takePicture();
        debugPrint('Embedded camera captured image at: ${file.path}');

        // Step 4: Classify image via native AI processor
        const platform = MethodChannel('com.example.fingerprintworkdemo/native');
        final stepName = _mapFingerCodeToStepName(currentCode);
        try {
          await platform.invokeMethod('classifyImage', {
            'path': file.path,
            'step': stepName,
          });
        } catch (e) {
          debugPrint('Classify MethodChannel exception: $e');
        }

        try {
          await _cameraController!.setFocusMode(FocusMode.auto);
        } catch (_) {}
      }
    } catch (e) {
      debugPrint('In-app camera picture capture exception: $e');
    }

    if (!mounted) return;

    setState(() {
      _scannedFingerKeys.add(currentCode);
      _isScanning = false;

      // Auto-advance step-wise in upper block (L1 -> L2 -> L3 -> L4 -> L5 -> R1...)
      if (_selectedFingerIndex < 4) {
        _selectedFingerIndex++;
      } else if (_isLeftHand) {
        // Switch to Right Hand R1
        _isLeftHand = false;
        _selectedFingerIndex = 0;
      }
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('✓ Scanned $currentCode (${_activeFinger['fullTitle']})!'),
        backgroundColor: const Color(0xFF15803D),
        duration: const Duration(milliseconds: 1200),
      ),
    );

    // If all 10 fingers captured
    if (_scannedFingerKeys.length >= 10) {
      _showAllScannedSuccessDialog();
    }
  }

  void _showAllScannedSuccessDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
          side: const BorderSide(color: Color(0xFF00E5FF), width: 1.5),
        ),
        title: Column(
          children: const [
            Icon(Icons.check_circle_rounded, color: Color(0xFF22C55E), size: 48),
            SizedBox(height: 10),
            Text(
              'All 10 Fingers Scanned!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        content: Text(
          '10–Fingerprint calibration complete for ${widget.candidateName}. You can now review the certified holistic report.',
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12.5,
            color: Color(0xFF94A3B8),
            height: 1.4,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.pop(ctx); // Close Dialog
                Navigator.pop(context); // Return to Home
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'View Holistic Report',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double padding = context.scalePadding(16.0);
    final isNarrow = context.isNarrowMobile;

    final scannedCount = _scannedFingerKeys.length;
    final scannedPercent = (scannedCount / 10.0 * 100).round();

    return Scaffold(
      backgroundColor: const Color(0xFF0B132B), // Dark Navy Background
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B132B),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          children: [
            const Text(
              'BIOMETRIC SCANNER',
              style: TextStyle(
                fontSize: 9.5,
                fontWeight: FontWeight.w900,
                color: Color(0xFF00E5FF),
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              '10–Fingerprint Capture',
              style: TextStyle(
                fontSize: context.scaleFont(16),
                fontWeight: FontWeight.w800,
                color: Colors.white,
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          // Torch Flash Toggle Button
          IconButton(
            onPressed: _toggleTorch,
            icon: Icon(
              _isTorchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
              color: _isTorchOn ? const Color(0xFFFDE047) : Colors.white60,
              size: 20,
            ),
          ),
          // Auto / Manual Capture Toggle Chip
          GestureDetector(
            onTap: () => setState(() => _isAutoCapture = !_isAutoCapture),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: _isAutoCapture
                    ? const Color(0xFF00E5FF)
                    : const Color(0xFF0284C7),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(
                    _isAutoCapture ? Icons.auto_awesome : Icons.touch_app_rounded,
                    size: 12,
                    color: _isAutoCapture ? const Color(0xFF0F172A) : Colors.white,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _isAutoCapture ? 'Auto' : 'Manual',
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.bold,
                      color: _isAutoCapture ? const Color(0xFF0F172A) : Colors.white,
                    ),
                  ),
                ],
              ),
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
                padding: EdgeInsets.symmetric(horizontal: padding, vertical: 12),
                child: Column(
                  children: [
                    // 1. Top Status & Progress Card
                    _buildTopStatusCard(context, scannedCount, scannedPercent),

                    const SizedBox(height: 18),

                    // 2. 5 Finger Selector Pills Row (L1-L5 / R1-R5 in upper block)
                    _buildFingerSelectorRow(),

                    const SizedBox(height: 18),

                    // 3. Active Finger Status Box
                    _buildActiveFingerStatusCard(),

                    const SizedBox(height: 20),

                    // 4. Central Target Scanner Box with Live Embedded Camera
                    _buildCameraTargetBox(isNarrow),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),

            // Bottom Sticky Primary Button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: const BoxDecoration(
                color: Color(0xFF0B132B),
              ),
              child: SizedBox(
                height: 50,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [
                        Color(0xFF4F46E5),
                        Color(0xFF0284C7),
                        Color(0xFF00E5FF),
                      ],
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0284C7).withValues(alpha: 0.45),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isScanning ? null : _captureActiveFinger,
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
                        const Icon(Icons.crop_free_rounded,
                            color: Colors.white, size: 20),
                        const SizedBox(width: 8),
                        Flexible(
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              _isScanning
                                  ? 'Capturing ${_activeFinger['code']}...'
                                  : 'Scan ${_activeFinger['fullTitle']} (${_activeFinger['code']})',
                              style: TextStyle(
                                fontSize: context.scaleFont(14),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
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

  Widget _buildTopStatusCard(
      BuildContext context, int scannedCount, int scannedPercent) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$scannedCount of 10 Fingers Scanned',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              Text(
                '$scannedPercent%',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF00E5FF),
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          // Progress Bar
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (scannedCount / 10.0).clamp(0.0, 1.0),
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.1),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(Color(0xFF00E5FF)),
            ),
          ),

          const SizedBox(height: 14),

          // Hand Switch Pills
          Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isLeftHand = true;
                    _selectedFingerIndex = 0;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: _isLeftHand
                          ? const Color(0xFF4F46E5)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        'Left Hand (L1 – L5)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() {
                    _isLeftHand = false;
                    _selectedFingerIndex = 0;
                  }),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    decoration: BoxDecoration(
                      color: !_isLeftHand
                          ? const Color(0xFF4F46E5)
                          : Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Center(
                      child: Text(
                        'Right Hand (R1 – R5)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFingerSelectorRow() {
    return Row(
      children: List.generate(_currentFingerList.length, (index) {
        final finger = _currentFingerList[index];
        final code = finger['code']!;
        final label = finger['label']!;
        final isSelected = _selectedFingerIndex == index;
        final isScanned = _scannedFingerKeys.contains(code);

        return Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _selectedFingerIndex = index),
            child: Container(
              margin: EdgeInsets.only(right: index < 4 ? 6 : 0),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF4338CA)
                    : Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isSelected
                      ? const Color(0xFF00E5FF)
                      : isScanned
                          ? const Color(0xFF22C55E)
                          : Colors.transparent,
                  width: isSelected ? 1.8 : 1.0,
                ),
              ),
              child: Column(
                children: [
                  Text(
                    code,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w900,
                      color: isSelected
                          ? Colors.white
                          : isScanned
                              ? const Color(0xFF22C55E)
                              : Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    label,
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white60,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: isScanned
                          ? const Color(0xFF22C55E)
                          : isSelected
                              ? const Color(0xFF00E5FF)
                              : Colors.white30,
                      shape: BoxShape.circle,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildActiveFingerStatusCard() {
    final code = _activeFinger['code']!;
    final fullTitle = _activeFinger['fullTitle']!;
    final mapping = _activeFinger['brainMapping']!;
    final isScanned = _scannedFingerKeys.contains(code);
    final pattern = _scannedFingerPatterns[code];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E293B).withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0284C7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      code,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    fullTitle,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: isScanned
                      ? const Color(0xFF15803D)
                      : const Color(0xFF1E1B4B),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isScanned
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF6366F1),
                  ),
                ),
                child: Text(
                  isScanned
                      ? (pattern != null ? '✓ $pattern' : '✓ Scanned')
                      : 'Ready to Scan',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.bold,
                    color: isScanned
                        ? const Color(0xFF86EFAC)
                        : const Color(0xFFC7D2FE),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              const Icon(Icons.memory_rounded,
                  color: Color(0xFF00E5FF), size: 14),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Maps to: $mapping',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFF94A3B8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraTargetBox(bool isNarrow) {
    final double boxSize = isNarrow ? 220 : 250;

    return GestureDetector(
      onTapDown: (details) async {
        // Touch-to-focus on camera inside target box
        if (_cameraController != null &&
            _cameraController!.value.isInitialized) {
          try {
            final x = details.localPosition.dx / boxSize;
            final y = details.localPosition.dy / boxSize;
            await _cameraController!
                .setFocusPoint(Offset(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0)));
            await _cameraController!
                .setExposurePoint(Offset(x.clamp(0.0, 1.0), y.clamp(0.0, 1.0)));
          } catch (_) {}
        }
      },
      onTap: _captureActiveFinger,
      child: Container(
        width: boxSize,
        height: boxSize,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: _isScanning
                ? const Color(0xFF22C55E)
                : const Color(0xFF00E5FF),
            width: 2.5,
          ),
          boxShadow: [
            BoxShadow(
              color: _isScanning
                  ? const Color(0xFF22C55E).withValues(alpha: 0.4)
                  : const Color(0xFF00E5FF).withValues(alpha: 0.3),
              blurRadius: 24,
              spreadRadius: 2,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(25),
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Live Camera Preview Feed inside Target Box
              if (_isCameraInitialized &&
                  _cameraController != null &&
                  _cameraController!.value.isInitialized)
                Positioned.fill(
                  child: CameraPreview(_cameraController!),
                )
              else
                Container(
                  color: const Color(0xFF0F172A),
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF00E5FF),
                      strokeWidth: 2,
                    ),
                  ),
                ),

              // Semi-transparent Overlay Grid / Scanner Reticle
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.45),
                    ],
                    radius: 0.85,
                  ),
                ),
              ),

              // Center Fingerprint Outline / Flash Indicator
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isScanning
                        ? Icons.check_circle_rounded
                        : Icons.fingerprint_rounded,
                    color: _isScanning
                        ? const Color(0xFF22C55E)
                        : const Color(0xFF00E5FF).withValues(alpha: 0.85),
                    size: 70,
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFF00E5FF).withValues(alpha: 0.6),
                      ),
                    ),
                    child: Text(
                      _isScanning
                          ? 'CAPTURING...'
                          : 'TAP TO SCAN (${_activeFinger['code']})',
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF00E5FF),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
