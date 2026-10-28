import 'dart:convert';
import 'package:http/http.dart' as http;

/// Native Gemini AI Counselor Service for Flutter
class GeminiCounselorService {
  final String apiKey;
  final String model;

  GeminiCounselorService({
    required this.apiKey,
    this.model = 'gemini-2.5-flash',
  });

  /// Sends a counseling query to Gemini and returns the counselor's psychological advice
  Future<String> askCounselor({
    required String userQuery,
    required String studentName,
    required String topIntelligence,
    required String brainDominance,
  }) async {
    if (apiKey.isEmpty) {
      return "Hello $studentName! I'm your Daksh AI Career & Psychological Mentor. Based on your strong $topIntelligence profile and $brainDominance dominance, you have exceptional cognitive agility. To activate live AI mentoring, please ensure your Gemini API key is configured.";
    }

    final url = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models/$model:generateContent?key=$apiKey',
    );

    final systemPrompt = '''
You are "Vayo", an empathetic, expert psychological counselor and career strategist for the Daksh platform.
The student you are advising is:
- Name: $studentName
- Primary Intelligence: $topIntelligence
- Brain Dominance: $brainDominance

Provide encouraging, psychologically grounded, actionable career guidance. Keep answers structured with:
1. Core Insight
2. Recommended Career Pathways
3. Immediate Skill Practice Drill
''';

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': '$systemPrompt\n\nStudent Question: $userQuery'}
              ]
            }
          ],
          'generationConfig': {
            'temperature': 0.7,
            'maxOutputTokens': 1000,
          }
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final candidates = data['candidates'] as List?;
        if (candidates != null && candidates.isNotEmpty) {
          final content = candidates[0]['content'];
          final parts = content['parts'] as List?;
          if (parts != null && parts.isNotEmpty) {
            return parts[0]['text'] as String;
          }
        }
      }
      return "I analyzed your cognitive profile ($topIntelligence). Focus on interdisciplinary learning, data reasoning, and structured projects to maximize your potential.";
    } catch (e) {
      return "Counselor response error: ${e.toString()}";
    }
  }
}
