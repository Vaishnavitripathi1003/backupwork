import 'daksh_report_data.dart';

/// Local, report-based Dart chatbot. No MethodChannel or network access.
class DakshChatService {
  Map<String, dynamic> _reports = {};
  String? primary;
  String? secondary;
  String? _lastTopic;

  static const _styles = ['Dominant', 'Influential', 'Steady', 'Compliant'];
  static const _titles = [
    'Your Personality Style', 'What this means about you',
    'Your 8 Intelligences', 'Most Suitable Work Direction',
    'आपकी पर्सनालिटी', 'आपके बारे में', 'आपकी 8', 'आपके लिए सबसे उपयुक्त',
  ];
  static const _intelligences = [
    ['logical', 'numerical', 'math', 'तार्किक', 'संख्यात्मक'],
    ['linguistic', 'language', 'communication', 'भाषाई'],
    ['personal', 'social', 'interpersonal', 'व्यक्तिगत', 'सामाजिक'],
    ['bodily', 'kinesthetic', 'physical', 'शारीरिक'],
    ['visual', 'spatial', 'दृश्य', 'स्थानिक'],
    ['naturalistic', 'nature', 'प्राकृतिक'],
    ['musical', 'music', 'संगीत'],
    ['creative', 'creativity', 'रचनात्मक'],
  ];

  Future<int> initialize() async {
    if (_reports.isNotEmpty) return _reports.length;
    _reports = DakshReportData.reports;
    return _reports.length;
  }

  String? _normalize(String raw) {
    final x = raw.toLowerCase().trim();
    if (x == 'd' || x.startsWith('domin')) return 'Dominant';
    if (x == 'i' || x.startsWith('influen')) return 'Influential';
    if (x == 's' || x.startsWith('stead')) return 'Steady';
    if (x == 'c' || x.startsWith('compl') || x.startsWith('conscien')) return 'Compliant';
    return null;
  }

  void setProfile({required String primary, required String secondary}) {
    final p = _normalize(primary);
    final s = _normalize(secondary);
    if (p == null || s == null) throw ArgumentError('Invalid DISC styles: $_styles');
    this.primary = p;
    this.secondary = s;
    _lastTopic = null;
  }

  void clearProfile() {
    primary = null;
    secondary = null;
    _lastTopic = null;
  }

  bool get hasProfile => primary != null && secondary != null;

  Future<String> ask(String question) async {
    await initialize();
    final q = question.trim();
    if (q.isEmpty) return 'Please enter your question.';
    final lower = q.toLowerCase();
    final hindi = RegExp(r'[\u0900-\u097f]').hasMatch(q);

    // Explicit profile updates: Primary Style: Dominant Secondary Style: Influential
    final labeled = RegExp(
      r'primary\s*(?:style)?\s*[:=\-]?\s*(dominant|influential|steady|compliant|dominate|steadiness|compliance|conscientiousness)'
      r'[\s,;\S]*?secondary\s*(?:style)?\s*[:=\-]?\s*(dominant|influential|steady|compliant|dominate|steadiness|compliance|conscientiousness)',
      caseSensitive: false,
    ).firstMatch(q);
    if (labeled != null) {
      setProfile(primary: labeled.group(1)!, secondary: labeled.group(2)!);
    } else if (!hasProfile) {
      final found = RegExp(r'\b(dominant|influential|steady|compliant)\b', caseSensitive: false)
          .allMatches(q).map((m) => m.group(1)!).toList();
      if (found.length >= 2) setProfile(primary: found[0], secondary: found[1]);
    }

    if (RegExp(r'^(hi|hello|hey|namaste|namaskar|hlo|good morning|good evening|नमस्ते)[!. ]*$', caseSensitive: false).hasMatch(q)) {
      return hasProfile
          ? (hindi ? 'नमस्ते! आपकी DISC प्रोफ़ाइल $primary / $secondary है। अपनी पर्सनालिटी, 8 बुद्धिमत्ता या करियर के बारे में पूछें।' : 'Hello! Your DISC profile is $primary / $secondary. Ask about your personality, 8 intelligences, or career direction.')
          : 'Hello! Please enter your DISC styles first, for example: Primary Style: Dominant Secondary Style: Influential';
    }
    if (!hasProfile) {
      return hindi
          ? 'सटीक जवाब के लिए Primary Style और Secondary Style बताएं। उदाहरण: Primary Style: Dominant Secondary Style: Influential'
          : 'Please provide your DISC Primary and Secondary styles first. Example: Primary Style: Dominant Secondary Style: Influential';
    }
    final key = '${hindi ? 'hi' : 'en'}_${primary}_$secondary';
    final raw = _reports[key];
    if (raw is! List) return 'Report unavailable for $primary / $secondary ($key).';
    final lines = raw.map((v) => v.toString()).toList();
    String topic = 'full';
    if (RegExp(r'^(more|tell me more|aur batao|aur btao|explain more|और बताओ)$', caseSensitive: false).hasMatch(lower) && _lastTopic != null) {
      topic = _lastTopic!;
    } else if (RegExp(r'8\s*(types?\s*(of)?\s*)?(intelligen|buddhi)|all\s*8|आठ|8\s*बुद्धि', caseSensitive: false).hasMatch(lower)) {
      topic = 'intelligences';
    } else if (RegExp(r'career|work|job|suitable|profession|kaam|कार्य|करियर|रोजगार', caseSensitive: false).hasMatch(lower)) {
      topic = 'career';
    } else if (RegExp(r'personality|nature|strength|weakness|mere bare|about me|स्वभाव|पर्सनालिटी|व्यक्तित्व', caseSensitive: false).hasMatch(lower)) {
      topic = 'personality';
    } else {
      for (var i = 0; i < _intelligences.length; i++) {
        if (_intelligences[i].any((word) => lower.contains(word))) {
          topic = 'intel_$i';
          break;
        }
      }
    }
    _lastTopic = topic;
    if (topic == 'full') return _format(lines);

    // These source reports use one heading per paragraph. Find section boundaries
    // by the heading text, preserving the report's actual wording and scores.
    bool isMajor(String s) => _titles.any((t) => s.toLowerCase().contains(t.toLowerCase()));
    bool isIntel(String s) => RegExp(r'^\d+[.．]\s*').hasMatch(s) ||
        (s.contains('Intelligence') && s.contains('Level:'));
    int start = -1;
    int end = lines.length;
    if (topic == 'personality') {
      start = lines.indexWhere((s) => s.toLowerCase().contains(hindi ? 'पर्सनालिटी' : 'your personality style'));
      if (start < 0) start = 1;
      end = lines.indexWhere((s) => s.toLowerCase().contains(hindi ? '8 प्रकार' : 'your 8 intelligences'));
      if (end <= start) end = lines.length;
    } else if (topic == 'career') {
      start = lines.indexWhere((s) => RegExp(r'most suitable work direction|सबसे उपयुक्त कार्य दिशा', caseSensitive: false).hasMatch(s));
      if (start >= 0) {
        end = lines.length;
      }
    } else {
      final intelStart = lines.indexWhere((s) => RegExp(r'your 8 intelligences|8 प्रकार की बुद्धिमत्ता', caseSensitive: false).hasMatch(s));
      if (topic == 'intelligences') {
        start = intelStart;
        if (start >= 0) {
          end = lines.indexWhere((s) => RegExp(r'most suitable work direction|सबसे उपयुक्त कार्य दिशा', caseSensitive: false).hasMatch(s));
          if (end <= start) end = lines.length;
        }
      } else if (topic.startsWith('intel_')) {
        final index = int.parse(topic.substring(6));
        final intelHeads = <int>[];
        for (var i = intelStart + 1; i < lines.length; i++) {
          if (isMajor(lines[i]) && i > intelStart + 1) break;
          if (isIntel(lines[i])) intelHeads.add(i);
        }
        if (index < intelHeads.length) {
          start = intelHeads[index];
          end = index + 1 < intelHeads.length ? intelHeads[index + 1] : lines.length;
          for (var i = start + 1; i < end; i++) {
            if (isMajor(lines[i])) { end = i; break; }
          }
        }
      }
    }
    if (start < 0 || end <= start) {
      return hindi ? 'इस विषय का अलग अनुभाग रिपोर्ट में नहीं मिला। कृपया पूर्ण रिपोर्ट देखें।' : 'No matching section was found in this report. Try “full report”.';
    }
    return _format(lines.sublist(start, end));
  }

  String _format(List<String> lines) => lines.map((line) {
    if (_titles.any((s) => line.toLowerCase().contains(s.toLowerCase()))) return '\n## $line';
    if (RegExp(r'^\d+[.．]\s*').hasMatch(line)) return '\n### $line';
    return line;
  }).join('\n').trim();
}
