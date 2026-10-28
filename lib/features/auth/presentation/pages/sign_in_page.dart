import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/services/login_service.dart';
import '../../../../core/utils/responsive.dart';
import '../widgets/otp_dialog.dart';

class SignInPage extends StatefulWidget {
  const SignInPage({super.key});

  @override
  State<SignInPage> createState() => _SignInPageState();
}

class _SignInPageState extends State<SignInPage> {
  int _activeTab = 0; // 0: Sign In, 1: Create Account
  bool _rememberMe = true;
  bool _isLoading = false;
  bool _obscurePassword = true; // password visibility toggle

  // Empty by default. Use _fillDemoStudent / _fillDemoParent for test data.
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  void _onSignIn() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() => _isLoading = true);

      final mobile = _emailController.text.trim();
      final password = _passwordController.text.trim();

      final isSuccess = await loginService.loginUserAndLoadHome(
        mobile: mobile,
        password: password,
      );

      if (mounted) {
        setState(() => _isLoading = false);

        if (isSuccess) {
          // Successful login -> Redirect to Home / Language Selection
          context.go(AppRoutes.languageSelection);
        } else {
          // Show clear error SnackBar if credentials are wrong
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Invalid Mobile or Password. Please try again."),
              backgroundColor: Colors.redAccent,
            ),
          );
        }
      }
    }
  }



  @override
  void dispose() {
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isTiny = constraints.maxWidth < 360;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: context.responsiveValue(
                    mobile: 520,
                    tablet: 580,
                    desktop: 640,
                  ),
                ),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(
                    parent: BouncingScrollPhysics(),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: context.scalePadding(isTiny ? 14 : 20),
                    vertical: context.scalePadding(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top Header Row (Logo + English Language Pill)
                    /*  Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Flexible(
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: context.responsiveValue(
                                      mobile: 44, tablet: 48),
                                  height: context.responsiveValue(
                                      mobile: 44, tablet: 48),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        Color(0xFF0284C7),
                                        Color(0xFF2563EB)
                                      ],
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
                                      size: context.responsiveValue(
                                          mobile: 26, tablet: 28),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'DAKSH',
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: context.scaleFont(18),
                                          fontWeight: FontWeight.w900,
                                          color: Colors.white,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 1),

                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Language Switcher Pill Button
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E293B)
                                  .withValues(alpha: 0.8),
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
                                  maxLines: 1,
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
                    /*  Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E1B4B),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: const Color(0xFF6366F1)
                                  .withValues(alpha: 0.4),
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
                              Flexible(
                                child: Text(
                                  'DERMATOGLYPHICS BRAIN MAPPING',
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: context.scaleFont(10.5),
                                    fontWeight: FontWeight.w900,
                                    color: const Color(0xFFA5B4FC),
                                    letterSpacing: 0.6,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),*/

                      // Main Heading Title
                      Text(
                        'Welcome Back to Daksh',
                        style: TextStyle(
                          fontSize: context.scaleFont(isNarrow ? 22 : 26),
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: -0.5,
                        ),
                      ),

                      const SizedBox(height: 6),

                      // Heading Subtitle
                     /* Text(
                        'Access your student multiple intelligence matrices, brain dominance, and AI career mentor.',
                        style: TextStyle(
                          fontSize: context.scaleFont(13),
                          color: const Color(0xFF94A3B8),
                          height: 1.4,
                        ),
                      ),

                      const SizedBox(height: 24),
*/
                      // White Main Card Container
                      Container(
                        padding: EdgeInsets.all(
                          context.scalePadding(isTiny ? 16 : 20),
                        ),
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
                                        onTap: () =>
                                            setState(() => _activeTab = 0),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 4),
                                          decoration: BoxDecoration(
                                            color: _activeTab == 0
                                                ? Colors.white
                                                : Colors.transparent,
                                            borderRadius:
                                            BorderRadius.circular(12),
                                            boxShadow: _activeTab == 0
                                                ? [
                                              BoxShadow(
                                                color: Colors.black
                                                    .withValues(
                                                    alpha: 0.06),
                                                blurRadius: 8,
                                                offset:
                                                const Offset(0, 2),
                                              ),
                                            ]
                                                : [],
                                          ),
                                          child: Text(
                                            'Sign In',
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize:
                                              context.scaleFont(13.5),
                                              fontWeight: FontWeight.w800,
                                              color: _activeTab == 0
                                                  ? const Color(0xFF4338CA)
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: GestureDetector(
                                        onTap: () {
                                          setState(() => _activeTab = 1);
                                          context.push(AppRoutes.signUp);
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10, horizontal: 4),
                                          decoration: BoxDecoration(
                                            color: _activeTab == 1
                                                ? Colors.white
                                                : Colors.transparent,
                                            borderRadius:
                                            BorderRadius.circular(12),
                                          ),
                                          child: Text(
                                            'Create Account',
                                            textAlign: TextAlign.center,
                                            maxLines: 1,
                                            softWrap: false,
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize:
                                              context.scaleFont(13.5),
                                              fontWeight: FontWeight.w800,
                                              color: _activeTab == 1
                                                  ? const Color(0xFF4338CA)
                                                  : const Color(0xFF64748B),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),

                              const SizedBox(height: 18),

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
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: 'Email or Mobile Number',
                                  hintStyle: const TextStyle(
                                      color: Color(0xFF94A3B8)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  prefixIcon: const Icon(
                                    Icons.mail_outline_rounded,
                                    color: Color(0xFF64748B),
                                    size: 20,
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6366F1),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                validator: (v) => (v == null || v.isEmpty)
                                    ? 'Please enter email or phone'
                                    : null,
                              ),

                              const SizedBox(height: 16),

                              // Password Header Row
                              Row(
                                mainAxisAlignment:
                                MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Password',
                                    style: TextStyle(
                                      fontSize: context.scaleFont(13),
                                      fontWeight: FontWeight.w700,
                                      color: const Color(0xFF334155),
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      context.push(AppRoutes.forgotPassword);
                                    },
                                    child: Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        fontSize: context.scaleFont(12.5),
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF6366F1),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              TextFormField(
                                controller: _passwordController,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onFieldSubmitted: (_) {
                                  if (!_isLoading) _onSignIn();
                                },
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontWeight: FontWeight.w600,
                                ),
                                decoration: InputDecoration(
                                  hintText: '••••••••',
                                  hintStyle: const TextStyle(
                                      color: Color(0xFF94A3B8)),
                                  filled: true,
                                  fillColor: const Color(0xFFF8FAFC),
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                    color: Color(0xFF64748B),
                                    size: 20,
                                  ),
                                  // Show / hide password toggle
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
                                    onPressed: () => setState(() =>
                                    _obscurePassword = !_obscurePassword),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 14,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: Color(0xFFE2E8F0)),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF6366F1),
                                      width: 2.0,
                                    ),
                                  ),
                                ),
                                validator: (v) => (v == null || v.length < 6)
                                    ? 'Password must be at least 6 characters'
                                    : null,
                              ),

                              const SizedBox(height: 14),

                              // Options Row (Remember + Secure)
                              Wrap(
                                alignment: WrapAlignment.spaceBetween,
                                runSpacing: 8,
                                spacing: 12,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: Checkbox(
                                          value: _rememberMe,
                                          activeColor:
                                          const Color(0xFF2563EB),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                            BorderRadius.circular(4),
                                          ),
                                          onChanged: (val) => setState(() =>
                                          _rememberMe = val ?? false),
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
                                 /* Row(
                                    mainAxisSize: MainAxisSize.min,
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

                              const SizedBox(height: 22),

                              // Sign In to Daksh Button
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
                                    onPressed: _isLoading ? null : _onSignIn,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                        BorderRadius.circular(16),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const Center(
                                      child: SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.5,
                                          valueColor:
                                          AlwaysStoppedAnimation<
                                              Color>(Colors.white),
                                        ),
                                      ),
                                    )
                                        : Row(
                                      mainAxisAlignment:
                                      MainAxisAlignment.center,
                                      children: [
                                        Flexible(
                                          child: Text(
                                            'Sign In to Daksh',
                                            maxLines: 1,
                                            overflow:
                                            TextOverflow.ellipsis,
                                            style: TextStyle(
                                              fontSize:
                                              context.scaleFont(16),
                                              fontWeight:
                                              FontWeight.w800,
                                              color: Colors.white,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.arrow_forward_rounded,
                                          color: Colors.white,
                                          size: 18,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),

                              const SizedBox(height: 4),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}