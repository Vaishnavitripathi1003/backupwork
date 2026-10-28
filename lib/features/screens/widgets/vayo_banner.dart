import 'package:flutter/material.dart';
import '../../../core/models/intelligence_models.dart';
import '../../../core/models/user_profile.dart';
import '../../../core/utils/responsive.dart';
import '../ai_counselor_screen.dart';

class VayoBanner extends StatelessWidget {
  final UserProfile currentProfile;

  const VayoBanner({super.key, required this.currentProfile});

  void _openCounselor(BuildContext context, [String? initialPrompt]) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => AICounselorScreen(
          profile: StudentProfile(
            id: currentProfile.id,
            name: currentProfile.name,
            role: currentProfile.role,
            avatar: currentProfile.emoji,
            gender: 'boy',
            grade: currentProfile.role,
            active: true,
          ),
          initialPrompt: initialPrompt,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = context.isNarrowMobile;

    return Container(
      padding: EdgeInsets.all(isNarrow ? 16 : 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E1B4B), // Indigo 950
            Color(0xFF312E81), // Indigo 900
            Color(0xFF4338CA), // Indigo 700
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF312E81).withValues(alpha: 0.35),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: 10,
            right: context.responsiveValue(mobile: 100, tablet: 180),
            child: const Icon(Icons.star_rate_rounded, size: 14, color: Color(0xFFFDE047)),
          ),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top VAYO • AI COUNSELOR Pill
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(Icons.auto_awesome, size: 12, color: Color(0xFFFDE047)),
                    SizedBox(width: 4),
                    Text(
                      'VAYO • AI COUNSELOR',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left Content
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              'Hi ${currentProfile.name}!',
                              style: TextStyle(
                                fontSize: context.scaleFont(20),
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(currentProfile.emoji, style: const TextStyle(fontSize: 20)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "I'm Vayo. I've analyzed your DISC, Personality and SWOT profile. Ask me anything, I'm here to guide your best future.",
                          style: TextStyle(
                            fontSize: context.scaleFont(12),
                            color: const Color(0xFFE0E7FF),
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Chat with Vayo Button
                        ElevatedButton.icon(
                          onPressed: () => _openCounselor(context),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: const Color(0xFF312E81),
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: const Icon(Icons.chat_bubble_rounded, size: 16, color: Color(0xFF4F46E5)),
                          label: Text(
                            'Chat with Vayo',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: context.scaleFont(13),
                              color: const Color(0xFF312E81),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Right Side: Badges & Robot Avatar Box
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Badge 1: Best Career
                      InkWell(
                        onTap: () => _openCounselor(context, 'What are the best careers for my profile?'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text('🎯', style: TextStyle(fontSize: 10)),
                              SizedBox(width: 4),
                              Text(
                                'Best Career',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Badge 2: My Strengths
                      InkWell(
                        onTap: () => _openCounselor(context, 'What are my top cognitive strengths?'),
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text('⭐', style: TextStyle(fontSize: 10)),
                              SizedBox(width: 4),
                              Text(
                                'My Strengths',
                                style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Robot Avatar Box
                      InkWell(
                        onTap: () => _openCounselor(context),
                        borderRadius: BorderRadius.circular(20),
                        child: Container(
                          width: 72,
                          height: 72,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.15),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: 44,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: const Color(0xFF0F172A),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF22D3EE),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF22D3EE),
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF6366F1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: const Text(
                                  'VAYO',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // Footer Note
              Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(text: 'Free Basic AI: '),
                    const TextSpan(
                      text: '3 queries',
                      style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                    const TextSpan(text: ' • Then Live Counselor'),
                  ],
                ),
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFFC7D2FE),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
