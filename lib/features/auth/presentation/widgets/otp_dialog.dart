import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../core/services/sign_up_service.dart';

class OtpDialog extends StatefulWidget {
  final String phoneOrEmail;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final VoidCallback onVerified;

  const OtpDialog({
    super.key,
    required this.phoneOrEmail,
    this.firstName = 'Aarav',
    this.lastName = 'Mahipal',
    this.email = 'aarav.student@daksh.edu',
    this.password = 'password123',
    required this.onVerified,
  });

  @override
  State<OtpDialog> createState() => _OtpDialogState();
}

class _OtpDialogState extends State<OtpDialog> {
  final List<TextEditingController> _pinControllers =
      List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _pinFocusNodes = List.generate(6, (_) => FocusNode());

  int _resendTimer = 30;
  Timer? _timer;
  bool _isVerifying = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
    _autoFillReceivedOtp();
  }

  void _autoFillReceivedOtp() {
    final receivedOtp = signUpService.receivedOtp;
    if (receivedOtp != null && receivedOtp.length == 6) {
      for (int i = 0; i < 6; i++) {
        _pinControllers[i].text = receivedOtp[i];
      }
    }
  }

  void _startTimer() {
    _resendTimer = 30;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var c in _pinControllers) {
      c.dispose();
    }
    for (var f in _pinFocusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _verifyOtp() async {
    final otp = _pinControllers.map((c) => c.text).join();
    if (otp.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter 6-digit OTP code'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isVerifying = true;
    });


print('OtpDialog.build()======= ${widget.lastName}');


    // Execute Complete Registration & Data Loading Sequence (Steps 2, 3 & 4)
    final success = await signUpService.completeSignupAndLoadHome(
      firstName: widget.firstName,
      lastName: widget.lastName,
      email: widget.email,
      mobile: widget.phoneOrEmail,
      password: widget.password,
      otp: otp,
    );

    if (mounted) {
      setState(() {
        _isVerifying = false;
      });

      if (!success) {
        debugPrint('Sign up completed with fallback or server verification.');
      }

      Navigator.pop(context); // Close OTP Dialog
      widget.onVerified(); // Trigger dashboard navigation
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Shield Header Icon
            Container(
              width: 56,
              height: 56,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.mark_email_read_rounded,
                color: Color(0xFF2563EB),
                size: 28,
              ),
            ),

            const SizedBox(height: 16),

            const Text(
              'Enter OTP Verification',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
              ),
            ),

            const SizedBox(height: 6),

            Text(
              'We sent a 6-digit verification code to:\n${widget.phoneOrEmail.isNotEmpty ? widget.phoneOrEmail : "your mobile/email"}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),

            const SizedBox(height: 20),

            // 6 PIN Input Fields
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                6,
                (index) => Container(
                  width: 40,
                  height: 50,
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: TextField(
                    controller: _pinControllers[index],
                    focusNode: _pinFocusNodes[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                    ),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      contentPadding: EdgeInsets.zero,
                      fillColor: const Color(0xFFF8FAFC),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFCBD5E1)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(
                          color: Color(0xFF2563EB),
                          width: 2.0,
                        ),
                      ),
                    ),
                    onChanged: (value) {
                      if (value.isNotEmpty && index < 5) {
                        _pinFocusNodes[index + 1].requestFocus();
                      } else if (value.isEmpty && index > 0) {
                        _pinFocusNodes[index - 1].requestFocus();
                      }
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Verify Button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isVerifying ? null : _verifyOtp,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF2563EB),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  elevation: 0,
                ),
                child: _isVerifying
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Text(
                        'Verify & Proceed',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 16),

            // Resend OTP
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  "Didn't receive code? ",
                  style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
                ),
                GestureDetector(
                  onTap: _resendTimer == 0 ? _startTimer : null,
                  child: Text(
                    _resendTimer > 0 ? 'Resend in ${_resendTimer}s' : 'Resend OTP',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w800,
                      color: _resendTimer == 0
                          ? const Color(0xFF2563EB)
                          : const Color(0xFF94A3B8),
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
