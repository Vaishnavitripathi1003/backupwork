import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/Global/global_class.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/dashboard_report_status_controller.dart';
import '../../../../core/services/finger_channel.dart';
import '../../../../core/services/homedataPreloader.dart';
import '../../../../core/services/sign_up_service.dart';
import '../../../../core/storage/app_pref.dart';
import '../../../../core/storage/user_pref.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/otp_dialog.dart';

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  int _activeTab = 1; // 0: Sign In, 1: Create Account
  bool _rememberMe = true;
  bool _obscurePassword = true;
  String _selectedClass = 'Class 8';

  final _nameController = TextEditingController();
  final _lastnameController = TextEditingController();
  final _emailController =
      TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  static const List<String> _classList = [
    'Class 1',
    'Class 2',
    'Class 3',
    'Class 4',
    'Class 5',
    'Class 6',
    'Class 7',
    'Class 8',
    'Class 9',
    'Class 10',
    'Class 11',
    'Class 12',
  ];

 /* void _onSignUp() async {
    if (_formKey.currentState?.validate() ?? false) {
      final mobile = _emailController.text;
      await signUpService.sendOtp(mobile);

      if (mounted) {

        final firstName = _nameController.text.isNotEmpty ? _nameController.text.toString() : '';
        final lastName = _lastnameController.text.isNotEmpty ? _lastnameController.text.toString() : '';
        debugPrint('name="${_nameController.text}" parts=$firstName last="$lastName"');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (_) => OtpDialog(
            phoneOrEmail: mobile,
            firstName: firstName,
            lastName: lastName,
            email: _emailController.text,
            password: _passwordController.text,
            onVerified: () {
              context.go(AppRoutes.dashboard);
            },
          ),
        );
      }
    }
  }*/
  void _onSignUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final mobile = _emailController.text.trim();
    final success = await signUpService.sendOtp(mobile);

    if (!mounted) return;

    if (!success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(signUpService.errorMessage ?? 'Failed to send OTP'),
          backgroundColor: Colors.red,
        ),
      );
      return; // stay on the sign-up page, don't open the OTP dialog
    }

    final firstName = _nameController.text.trim();
    final lastName = _lastnameController.text.trim();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => OtpDialog(
        phoneOrEmail: mobile,
        firstName: firstName,
        lastName: lastName,
        email: _emailController.text,
        password: _passwordController.text,
        onVerified: () async {
      /*    final prefs = await SharedPreferences.getInstance();
          final userPref = UserPref(prefs);
          final appPref = AppPref(prefs);
     await userPref.clearToken();
          await appPref.clearToken();

          // Clear all SQLite data, Global selections, and cached reports
          await DatabaseHelper.instance.clearAllData();
          GlobalClass.reset();
          await HomeDataPreloader.instance.clear();
          DashboardReportStatusController.instance.cancel();
          try {
            await FingerChannel.clearScanCache();
          } catch (_) {}

          if (mounted) {
          //  Navigator.pop(context); // Close Drawer
            context.go(AppRoutes.signIn); // Navigate to SignIn Page
          }*/

            final prefs = await SharedPreferences.getInstance();
            final userPref = UserPref(prefs);
            final appPref = AppPref(prefs);

            await userPref.clearToken();
            await appPref.clearToken();

            // Clear all SQLite data, Global selections, and cached reports
            await DatabaseHelper.instance.clearAllData();
            GlobalClass.reset();
            await HomeDataPreloader.instance.clear();
            DashboardReportStatusController.instance.cancel();
            try {
              await FingerChannel.clearScanCache();
            } catch (_) {

            }

            if (mounted) {
             // Navigator.pop(context); // Close Drawer
              context.go(AppRoutes.signIn); // Navigate to SignIn Page
            }
          }

        //  context.go(AppRoutes.signIn);
        //},
      ),
    );
  }
  @override
  void dispose() {
    _nameController.dispose();
    _lastnameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = context.isNarrowMobile;

    return Scaffold(
      backgroundColor: const Color(0xFF090D16), // Dark Blue Navy
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: context.responsiveValue(
                mobile: 520,
                tablet: 580,
                desktop: 640,
              ),
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.symmetric(
                horizontal: context.scalePadding(20),
                vertical: context.scalePadding(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Row (Logo + English Language Pill)
               /*   Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: context.responsiveValue(mobile: 44, tablet: 48),
                            height: context.responsiveValue(mobile: 44, tablet: 48),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFF0284C7), Color(0xFF2563EB)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(14),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(0xFF0284C7)
                                      .withValues(alpha: 0.4),
                                  blurRadius: 10,
                                ),
                              ],
                            ),
                            child: Center(
                              child: Icon(
                                Icons.fingerprint_rounded,
                                color: Colors.white,
                                size: context.responsiveValue(mobile: 26, tablet: 28),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'DAKSH',
                                style: TextStyle(
                                  fontSize: context.scaleFont(18),
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: 1.0,
                                ),
                              ),
                              const SizedBox(height: 1),
                              *//*Text(
                                'BIOMETRIC AI',
                                style: TextStyle(
                                  fontSize: context.scaleFont(9.5),
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF38BDF8),
                                  letterSpacing: 0.5,
                                ),
                              ),*//*
                            ],
                          ),
                        ],
                      ),

                      // Language Switcher Pill Button
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.language_rounded,
                              color: Color(0xFF38BDF8),
                              size: 16,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'English',
                              style: TextStyle(
                                fontSize: context.scaleFont(12.5),
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),*/
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Flexible(
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              'assets/images/dakshlogo.png',
                              width: 16,
                              height: 16,
                              fit: BoxFit.contain,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                'DAKSH',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: context.scaleFont(10.5),
                                  fontWeight: FontWeight.w900,
                                  color: const Color(0xFF06B6D4),
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 6),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Dermatoglyphics Brain Mapping Chip
                /*  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E1B4B),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF6366F1).withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.auto_awesome_rounded,
                          color: Color(0xFF38BDF8),
                          size: 13,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'DERMATOGLYPHICS BRAIN MAPPING',
                          style: TextStyle(
                            fontSize: context.scaleFont(10.5),
                            fontWeight: FontWeight.w900,
                            color: const Color(0xFFA5B4FC),
                            letterSpacing: 0.6,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 12),*/

                  // Main Heading Title
                  Text(
                    'Discover Your Inborn Genius',
                    style: TextStyle(
                      fontSize: context.scaleFont(isNarrow ? 22 : 26),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 6),

                  // Heading Subtitle
                /*  Text(
                    'Create an account to begin certified 10–finger biometric  analysis and cognitive mapping.',
                    style: TextStyle(
                      fontSize: context.scaleFont(13),
                      color: const Color(0xFF94A3B8),
                      height: 1.4,
                    ),
                  ),*/

                 // const SizedBox(height: 24),

                  // White Main Card Container
                  Container(
                    padding: EdgeInsets.all(context.scalePadding(20)),
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
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Segmented Tab Switcher (Sign In / Create Account)
                          Container(
                            padding: const EdgeInsets.all(4),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF1F5F9),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() => _activeTab = 0);
                                      context.pop();
                                    },
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _activeTab == 0
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Sign In',
                                          style: TextStyle(
                                            fontSize: context.scaleFont(14),
                                            fontWeight: FontWeight.w800,
                                            color: _activeTab == 0
                                                ? const Color(0xFF4338CA)
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                Expanded(
                                  child: GestureDetector(
                                    onTap: () => setState(() => _activeTab = 1),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                          vertical: 10),
                                      decoration: BoxDecoration(
                                        color: _activeTab == 1
                                            ? Colors.white
                                            : Colors.transparent,
                                        borderRadius: BorderRadius.circular(12),
                                        boxShadow: _activeTab == 1
                                            ? [
                                                BoxShadow(
                                                  color: Colors.black
                                                      .withValues(alpha: 0.06),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                ),
                                              ]
                                            : [],
                                      ),
                                      child: Center(
                                        child: Text(
                                          'Create Account',
                                          style: TextStyle(
                                            fontSize: context.scaleFont(14),
                                            fontWeight: FontWeight.w800,
                                            color: _activeTab == 1
                                                ? const Color(0xFF4338CA)
                                                : const Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(height: 18),

                          /*
                          // Role Toggles (Student vs Parent)
                          Row(
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFEEF2FF),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFF6366F1),
                                        width: 1.8,
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text('👦',
                                              style: TextStyle(fontSize: 16)),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Student',
                                            style: TextStyle(
                                              fontSize: context.scaleFont(13.5),
                                              fontWeight: FontWeight.w800,
                                              color: const Color(0xFF4338CA),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(width: 12),

                              Expanded(
                                child: GestureDetector(
                                  onTap: () {},
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 10, horizontal: 4),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF8FAFC),
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: const Color(0xFFE2E8F0),
                                        width: 1.0,
                                      ),
                                    ),
                                    child: FittedBox(
                                      fit: BoxFit.scaleDown,
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Text('👨‍👩‍👧',
                                              style: TextStyle(fontSize: 16)),
                                          const SizedBox(width: 6),
                                          Text(
                                            'Parent / Guardian',
                                            style: TextStyle(
                                              fontSize: context.scaleFont(13.5),
                                              fontWeight: FontWeight.w700,
                                              color: const Color(0xFF334155),
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

                          const SizedBox(height: 20),
                          */

                          // Full Name Input Field
                          Text(
                            'First Name',
                            style: TextStyle(
                              fontSize: context.scaleFont(13),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _nameController,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _buildInputDecoration(
                              'First Name',
                              Icons.person_outline_rounded,
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please enter full name'
                                : null,
                          ),

                          const SizedBox(height: 20),

                          ///////todo last name added
                          Text(
                            'Last Name',
                            style: TextStyle(
                              fontSize: context.scaleFont(13),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _lastnameController,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _buildInputDecoration(
                              'Last Name',
                              Icons.person_outline_rounded,
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please enter full name'
                                : null,
                          ),


                          const SizedBox(height: 16),

                          // Email or Mobile Number Input Field
                          Text(
                            'Email or Mobile Number',
                            style: TextStyle(
                              fontSize: context.scaleFont(13),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _emailController,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _buildInputDecoration(
                              'Enter Mobile Number or Email',
                              Icons.mail_outline_rounded,
                            ),
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Please enter email or phone'
                                : null,
                          ),

                          const SizedBox(height: 16),

                          // Password Field
                          Text(
                            'Password',
                            style: TextStyle(
                              fontSize: context.scaleFont(13),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 6),
                          TextFormField(
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: _buildInputDecoration(
                              'Enter Password',
                              Icons.lock_outline_rounded,
                              suffixIcon: IconButton(
                                tooltip: _obscurePassword
                                    ? 'Show password'
                                    : 'Hide password',
                                icon: Icon(
                                  _obscurePassword
                                      ? Icons.visibility_off_outlined
                                      : Icons.visibility_outlined,
                                  color: const Color(0xFF64748B),
                                  size: 20,
                                ),
                                onPressed: () => setState(
                                    () => _obscurePassword = !_obscurePassword),
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Password must be at least 6 characters'
                                : null,
                          ),

                          // Current Class / Grade Dropdown
                          const SizedBox(height: 16),
                         /* Text(
                            'Current Class / Grade',
                            style: TextStyle(
                              fontSize: context.scaleFont(13),
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF334155),
                            ),
                          ),
                          const SizedBox(height: 6),*/
                        /*  DropdownButtonFormField<String>(
                            initialValue: _selectedClass,
                            style: const TextStyle(
                              color: Color(0xFF0F172A),
                              fontWeight: FontWeight.w600,
                            ),
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: const Color(0xFFF8FAFC),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide:
                                    const BorderSide(color: Color(0xFFE2E8F0)),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(14),
                                borderSide: const BorderSide(
                                  color: Color(0xFF6366F1),
                                  width: 2.0,
                                ),
                              ),
                            ),
                            items: _classList
                                .map(
                                  (cls) => DropdownMenuItem(
                                    value: cls,
                                    child: Text(cls),
                                  ),
                                )
                                .toList(),
                            onChanged: (val) {
                              if (val != null) {
                                setState(() => _selectedClass = val);
                              }
                            },
                          ),
*/
                          const SizedBox(height: 14),

                          // Options Row (Remember on this phone + 256-bit Secure)
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SizedBox(
                                      width: 22,
                                      height: 22,
                                      child: Checkbox(
                                        value: _rememberMe,
                                        activeColor: const Color(0xFF2563EB),
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        onChanged: (val) => setState(
                                            () => _rememberMe = val ?? false),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Remember on this phone',
                                      style: TextStyle(
                                        fontSize: context.scaleFont(12),
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF475569),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(width: 16),
                                /*Row(
                                  children: [
                                    const Icon(
                                      Icons.verified_user_outlined,
                                      color: Color(0xFF16A34A),
                                      size: 15,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '256-bit Secure',
                                      style: TextStyle(
                                        fontSize: context.scaleFont(11.5),
                                        fontWeight: FontWeight.w800,
                                        color: const Color(0xFF16A34A),
                                      ),
                                    ),
                                  ],
                                ),*/
                              ],
                            ),
                          ),

                          const SizedBox(height: 22),

                          // Create Account & Continue Button
                          SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  colors: [
                                    Color(0xFF4F46E5),
                                    Color(0xFF7C3AED),
                                  ],
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                ),
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFF4F46E5)
                                        .withValues(alpha: 0.40),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ],
                              ),
                              child: ElevatedButton(
                                onPressed: _onSignUp,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.transparent,
                                  shadowColor: Colors.transparent,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: const [
                                    Text(
                                      'Create Account & Continue',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w800,
                                        color: Colors.white,
                                      ),
                                    ),
                                    SizedBox(width: 8),
                                    Icon(
                                      Icons.arrow_forward_rounded,
                                      color: Colors.white,
                                      size: 18,
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _buildInputDecoration(
    String hint,
    IconData icon, {
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8)),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      prefixIcon: Icon(icon, color: const Color(0xFF64748B), size: 20),
      suffixIcon: suffixIcon,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 14,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF6366F1),
          width: 2.0,
        ),
      ),
    );
  }
}
