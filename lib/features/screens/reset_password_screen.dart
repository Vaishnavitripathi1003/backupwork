import 'dart:convert';
import 'package:flutter/material.dart';
import '../../../../core/network/api_service.dart';

// Request Model for verifyOtp
class PasswordResetRequest {
  final String otp;
  final String password;
  final String token;

  PasswordResetRequest({
    required this.otp,
    required this.password,
    required this.token,
  });

  Map<String, dynamic> toJson() {
    return {
      'otp': otp,
      'password': password,
      'token': token,
    };
  }
}

// Response Model
class SignUpVerificationResponse {
  final String? message;
  final int? statusCode;
  final String? token;
  final String? error;

  SignUpVerificationResponse({
    this.message,
    this.statusCode,
    this.token,
    this.error,
  });

  factory SignUpVerificationResponse.fromJson(Map<String, dynamic> json) {
    return SignUpVerificationResponse(
      message: json['message'] as String?,
      statusCode: json['status_code'] as int?,
      token: json['token'] as String?,
      error: json['error'] as String?,
    );
  }
}

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final ApiService _apiService = ApiService();

  // Controllers
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _otpController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // State
  bool _isLoading = false;
  bool _showOtpInterface = false; // Controls Step 1 vs Step 2 UI
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;
  String? _tempToken;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showSnackBar(String message, {bool isError = true}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.redAccent : const Color(0xFF16A34A),
      ),
    );
  }

  // Step 1: Validate phone & call sendOtp API
  Future<void> _validateForm1() async {
    final phone = _phoneController.text.trim();

    if (phone.length != 10) {
      debugPrint('[FORGOT_PASSWORD] ⚠️ Invalid phone number length: ${phone.length}');
      _showSnackBar("Phone number must be 10 digits");
      return;
    }

    debugPrint('[FORGOT_PASSWORD] 🚀 Calling sendOtp API for mobile: $phone');
    setState(() => _isLoading = true);

    try {
      final res = await _apiService.resetPasswordVerification(mobile: phone);
      debugPrint('[FORGOT_PASSWORD] 📥 Raw sendOtp HTTP Status: ${res.statusCode}');
      debugPrint('[FORGOT_PASSWORD] 📥 Raw sendOtp Body: ${res.data}');

      final json = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : jsonDecode(res.data.toString());
      final response = SignUpVerificationResponse.fromJson(json);

      if (response.token != null && response.token!.isNotEmpty) {
        _tempToken = response.token;
        debugPrint('[FORGOT_PASSWORD] ✅ OTP sent successfully. Temp Token: $_tempToken');
        _showSnackBar(
          response.message ?? "OTP sent successfully",
          isError: false,
        );
        setState(() {
          _showOtpInterface = true; // Switch to Step 2 UI
        });
      } else if (response.error != null) {
        debugPrint('[FORGOT_PASSWORD] ❌ sendOtp Error: ${response.error}');
        _showSnackBar(response.error!);
      } else {
        debugPrint('[FORGOT_PASSWORD] ❌ Unknown sendOtp Error: ${response.message}');
        _showSnackBar(response.message ?? "Error sending OTP");
      }
    } catch (e, stack) {
      debugPrint('[FORGOT_PASSWORD] 💥 sendOtp Exception: $e\n$stack');
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // Step 2: Validate OTP/Password & call verifyOtp API
  Future<void> _validateForm2() async {
    final otp = _otpController.text.trim();
    final newPassword = _newPasswordController.text.trim();
    final confirmPassword = _confirmPasswordController.text.trim();

    if (otp.length < 4) {
      debugPrint('[FORGOT_PASSWORD] ⚠️ Invalid OTP length: ${otp.length}');
      _showSnackBar("OTP is not valid");
      return;
    }

    if (newPassword.length < 6) {
      debugPrint('[FORGOT_PASSWORD] ⚠️ Password too short: ${newPassword.length}');
      _showSnackBar("Password must be at least 6 characters");
      return;
    }

    if (newPassword != confirmPassword) {
      debugPrint('[FORGOT_PASSWORD] ⚠️ Passwords do not match');
      _showSnackBar("Passwords do not match");
      return;
    }

    if (_tempToken == null) {
      debugPrint('[FORGOT_PASSWORD] ⚠️ Session token is null');
      _showSnackBar("Session expired. Please try again.");
      return;
    }

    debugPrint('[FORGOT_PASSWORD] 🚀 Calling verifyOtp API with token: $_tempToken, OTP: $otp');
    setState(() => _isLoading = true);

    try {
      final res = await _apiService.verifyOtp(
        auth: _tempToken!,
        password: newPassword,
        otp: otp,
        token: _tempToken!,
      );

      debugPrint('[FORGOT_PASSWORD] 📥 Raw verifyOtp HTTP Status: ${res.statusCode}');
      debugPrint('[FORGOT_PASSWORD] 📥 Raw verifyOtp Body: ${res.data}');

      final json = res.data is Map<String, dynamic>
          ? res.data as Map<String, dynamic>
          : jsonDecode(res.data.toString());
      final response = SignUpVerificationResponse.fromJson(json);

      if (res.statusCode == 200 || response.message == "Password reset successfully") {
        debugPrint('[FORGOT_PASSWORD] 🎉 Password reset successful!');
        _showSnackBar("Password reset successfully", isError: false);
        if (mounted) Navigator.pop(context); // Go back to Login Screen
      } else if (response.message != null) {
        debugPrint('[FORGOT_PASSWORD] ❌ verifyOtp Failed Message: ${response.message}');
        _showSnackBar(response.message!);
      } else if (response.error != null) {
        debugPrint('[FORGOT_PASSWORD] ❌ verifyOtp Error: ${response.error}');
        _showSnackBar(response.error!);
      } else {
        debugPrint('[FORGOT_PASSWORD] ❌ Unknown verifyOtp Error');
        _showSnackBar("Failed to reset password");
      }
    } catch (e, stack) {
      debugPrint('[FORGOT_PASSWORD] 💥 verifyOtp Exception: $e\n$stack');
      _showSnackBar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF090D16), // Dark Blue Navy matching Daksh theme
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Forgot Password",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 540),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Container(
                padding: const EdgeInsets.all(24.0),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 30,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: AnimatedCrossFade(
                  duration: const Duration(milliseconds: 300),
                  crossFadeState: _showOtpInterface
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  firstChild: _buildStep1PhoneInput(),
                  secondChild: _buildStep2OtpAndPasswordInput(),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // UI Step 1: Mobile Input View
  Widget _buildStep1PhoneInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Reset Password",
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 6),
        const Text(
          "Enter the phone number associated with your account and we’ll send code to reset your password",
          style: TextStyle(color: Color(0xFF64748B), height: 1.4),
        ),
        const SizedBox(height: 24),
        const Text("Phone number", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
        const SizedBox(height: 8),
        TextField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          maxLength: 10,
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            counterText: "",
            hintText: "Enter 10-digit mobile number",
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: const Icon(Icons.phone_android_rounded, color: Color(0xFF64748B), size: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _validateForm1,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                  : const Text("CONFIRM", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }

  // UI Step 2: OTP & New Password View
  Widget _buildStep2OtpAndPasswordInput() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Verify OTP & Reset Password",
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFF0F172A)),
        ),
        const SizedBox(height: 6),
        const Text(
          "Enter the OTP sent to your registered mobile number and set your new password.",
          style: TextStyle(color: Color(0xFF64748B), height: 1.4),
        ),
        const SizedBox(height: 20),
        const Text("OTP", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        TextField(
          controller: _otpController,
          keyboardType: TextInputType.number,
          maxLength: 6,
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "Enter OTP",
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: const Icon(Icons.security_rounded, color: Color(0xFF64748B), size: 20),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text("New Password", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        TextField(
          controller: _newPasswordController,
          obscureText: _obscureNewPassword,
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "New Password",
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureNewPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF64748B), size: 20,
              ),
              onPressed: () => setState(() => _obscureNewPassword = !_obscureNewPassword),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 14),
        const Text("Confirm Password", style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF334155))),
        const SizedBox(height: 6),
        TextField(
          controller: _confirmPasswordController,
          obscureText: _obscureConfirmPassword,
          style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w600),
          decoration: InputDecoration(
            hintText: "Confirm Password",
            hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            prefixIcon: const Icon(Icons.lock_outline_rounded, color: Color(0xFF64748B), size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscureConfirmPassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                color: const Color(0xFF64748B), size: 20,
              ),
              onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF6366F1), width: 2.0),
            ),
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _validateForm2,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                shadowColor: Colors.transparent,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              ),
              child: _isLoading
                  ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                  : const Text("SUBMIT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
            ),
          ),
        ),
      ],
    );
  }
}
