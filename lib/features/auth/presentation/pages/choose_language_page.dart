import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/localization/language_manager.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../../core/storage/user_pref.dart';
import '../../../../core/utils/responsive.dart';

class ChooseLanguagePage extends StatefulWidget {
  const ChooseLanguagePage({super.key});

  @override
  State<ChooseLanguagePage> createState() => _ChooseLanguagePageState();
}

class _ChooseLanguagePageState extends State<ChooseLanguagePage> {
  int _selectedIndex = 0; // 0: English, 1: Hindi, 2: Gujarati, 3: Marathi

  static const List<Map<String, String>> _languages = [
    {
      'code': 'en',
      'short': 'En',
      'title': 'English',
      'titleNative': 'English',
      'subtitle': 'Welcome! • Default',
    },
    {
      'code': 'hi',
      'short': 'हि',
      'title': 'हिन्दी',
      'titleNative': 'Hindi',
      'subtitle': 'नमस्ते! • उत्तर / मध्य भारत',
    },
  ];

  void _onContinue() async {
    final selectedLang = _languages[_selectedIndex];
    final code = selectedLang['code'] ?? 'en';

    // Save language preference globally
    await LanguageManager.instance.setLanguage(code);

    if (mounted) {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = context.isNarrowMobile;
    final selectedLang = _languages[_selectedIndex];

    return Scaffold(
      backgroundColor: const Color(0xFF090D16), // Dark Navy Slate
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
                vertical: context.scalePadding(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Top Header Bar (Globe Icon + STEP 2 OF ONBOARDING Chip)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B).withValues(alpha: 0.8),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.15),
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.language_rounded,
                            color: Color(0xFF38BDF8),
                            size: 24,
                          ),
                        ),
                      ),

                      // Step Chip
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F3854),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: const Color(0xFF38BDF8).withValues(alpha: 0.4),
                          ),
                        ),
                        child: const Text(
                          'STEP 2 OF ONBOARDING',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF38BDF8),
                            letterSpacing: 0.8,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // Heading
                  Text(
                    'Choose Your Language',
                    style: TextStyle(
                      fontSize: context.scaleFont(isNarrow ? 22 : 26),
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // Subtitle Description
                  Text(
                    'Select your preferred tongue for  instructions, reports, and AI counseling.',
                    style: TextStyle(
                      fontSize: context.scaleFont(13.5),
                      color: const Color(0xFF94A3B8),
                      height: 1.4,
                    ),
                  ),

                  const SizedBox(height: 28),

                  // Language Options Cards List
                  ...List.generate(_languages.length, (index) {
                    final item = _languages[index];
                    final isSelected = _selectedIndex == index;

                    return GestureDetector(
                      onTap: () => setState(() => _selectedIndex = index),
                      child: Container(
                        margin: const EdgeInsets.only(bottom: 14),
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: isSelected
                              ? const LinearGradient(
                                  colors: [
                                    Color(0xFF3B82F6),
                                    Color(0xFF6366F1),
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                )
                              : null,
                          color: isSelected ? null : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFF818CF8)
                                : const Color(0xFF334155),
                            width: isSelected ? 2.0 : 1.0,
                          ),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: const Color(0xFF3B82F6)
                                        .withValues(alpha: 0.35),
                                    blurRadius: 16,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          children: [
                            // Short Code Avatar Box
                            Container(
                              width: 44,
                              height: 44,
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? Colors.white.withValues(alpha: 0.20)
                                    : const Color(0xFF334155),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  item['short']!,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w800,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),

                            const SizedBox(width: 14),

                            // Language Titles & Subtitle
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        item['title']!,
                                        style: TextStyle(
                                          fontSize: context.scaleFont(16),
                                          fontWeight: FontWeight.w800,
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        '(${item['titleNative']!})',
                                        style: TextStyle(
                                          fontSize: context.scaleFont(13),
                                          color: isSelected
                                              ? Colors.white70
                                              : const Color(0xFF94A3B8),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    item['subtitle']!,
                                    style: TextStyle(
                                      fontSize: context.scaleFont(11.5),
                                      color: isSelected
                                          ? const Color(0xFFE0F2FE)
                                          : const Color(0xFF64748B),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Selection Radio / Checkmark Icon
                            Icon(
                              isSelected
                                  ? Icons.check_circle_rounded
                                  : Icons.radio_button_unchecked_rounded,
                              color: isSelected
                                  ? Colors.white
                                  : const Color(0xFF64748B),
                              size: 22,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Bottom Status Info Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.volume_up_rounded,
                            color: Color(0xFF38BDF8),
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Selected: ',
                            style: TextStyle(
                              fontSize: context.scaleFont(12.5),
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                          Text(
                            '${selectedLang['title']} (${selectedLang['titleNative']})',
                            style: TextStyle(
                              fontSize: context.scaleFont(12.5),
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Changeable anytime',
                        style: TextStyle(
                          fontSize: context.scaleFont(11.5),
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // Continue Button
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color(0xFF4F46E5),
                            Color(0xFF06B6D4),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF06B6D4).withValues(alpha: 0.35),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ],
                      ),
                      child: ElevatedButton(
                        onPressed: _onContinue,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          shadowColor: Colors.transparent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Continue in ${selectedLang['titleNative']} ',
                              style: TextStyle(
                                fontSize: context.scaleFont(16),
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
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

                  const SizedBox(height: 16),

                  // Back Link Button
                  Center(
                    child: TextButton(
                      onPressed: () {
                        if (context.canPop()) {
                          context.pop();
                        } else {
                          context.go(AppRoutes.signIn);
                        }
                      },
                      child: const Text(
                        '← Back',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF94A3B8),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
