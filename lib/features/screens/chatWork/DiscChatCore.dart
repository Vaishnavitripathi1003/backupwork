// DiscChatCore.dart
// Pure-Dart part of the DISC chat model: text -> token ids (must match training exactly),
// and model predictions -> reply text. No Flutter or TFLite classes here.

import 'dart:math' as math;

// ---------------------------------------------------------------------------
// Tokenizer (must match training exactly)
// ---------------------------------------------------------------------------

class DiscTokenizer {
  DiscTokenizer(this.vocab, this.maxLen) {
    for (var i = 0; i < vocab.length; i++) {
      _index[vocab[i]] = i;
    }
    _fuzzy = vocab
        .skip(2)
        .where((w) => w.length >= 5 && !w.startsWith('code_'))
        .toList();
  }

  final List<String> vocab;
  final int maxLen;
  final Map<String, int> _index = {};
  late final List<String> _fuzzy;
  final Map<String, int> _cache = {};

  static const _notCodeAfter =
      'student|students|engineering|engineer|branch|degree|course|major|'
      'department|dept|graduate|field|category|caste|st|obc|batch|subject|exam|paper|lab|class|semester|sem|year';

  // Dart has no inline (?i:) flag, so the "not followed by a word like 'student'"
  // check is done separately in normalize().
  static final RegExp _reBare = RegExp(r'(?<![A-Za-z])([DISC]{2})(?![A-Za-z])');
  static final RegExp _reNotCodeAfter =
      RegExp('^\\s+(?:$_notCodeAfter)\\b', caseSensitive: false);
  static final RegExp _reSlash =
      RegExp(r'(?<![a-z])([disc])\s*[/\\\-–—&+|]\s*([disc])(?![a-z])');
  static final RegExp _reNon = RegExp(r'[^a-z0-9_%]+');

  List<String> normalize(String text) {
    var t = text.replaceAllMapped(_reBare, (m) {
      if (_reNotCodeAfter.hasMatch(text.substring(m.end))) return m[0]!;
      return ' code_${m[1]!.toLowerCase()} ';
    });
    t = t.toLowerCase().replaceAll('’', "'").replaceAll("'", '');
    t = t.replaceAllMapped(_reSlash, (m) => ' code_${m[1]}${m[2]} ');
    t = t.replaceAll('&', ' and ');
    t = t.replaceAll(_reNon, ' ').trim();
    return t.isEmpty ? <String>[] : t.split(' ');
  }

  List<int> encode(String text) {
    final out = List<int>.filled(maxLen, 0); // 0 = padding
    final toks = normalize(text).take(maxLen).toList();
    for (var i = 0; i < toks.length; i++) {
      out[i] = _tokenId(toks[i]);
    }
    return out;
  }

  int _tokenId(String tok) {
    final direct = _index[tok];
    if (direct != null) return direct;
    final cached = _cache[tok];
    if (cached != null) return cached;
    var best = 1; // <oov>
    var bestD = 1 << 30;
    if (tok.length >= 5) {
      final mx = tok.length >= 8 ? 2 : 1;
      for (final w in _fuzzy) {
        if (w[0] != tok[0] || (w.length - tok.length).abs() > mx) continue;
        final d = damerau(tok, w, mx);
        if (d <= mx && d < bestD) {
          best = _index[w]!;
          bestD = d;
        }
      }
    }
    _cache[tok] = best;
    return best;
  }

  /// Optimal-string-alignment distance; identical to the Python training code.
  static int damerau(String a, String b, int mx) {
    if ((a.length - b.length).abs() > mx) return mx + 1;
    var prev2 = List<int>.filled(b.length + 1, 0);
    var prev = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      final cur = List<int>.filled(b.length + 1, 0);
      cur[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final cost = a[i - 1] == b[j - 1] ? 0 : 1;
        cur[j] = math.min(
            math.min(prev[j] + 1, cur[j - 1] + 1), prev[j - 1] + cost);
        if (i > 1 &&
            j > 1 &&
            a[i - 1] == b[j - 2] &&
            a[i - 2] == b[j - 1]) {
          cur[j] = math.min(cur[j], prev2[j - 2] + 1);
        }
      }
      prev2 = prev;
      prev = cur;
    }
    return prev[b.length];
  }
}

// ---------------------------------------------------------------------------
// Data classes
// ---------------------------------------------------------------------------

/// A reply to show in the chat.
class DiscReply {
  const DiscReply(
    this.text, {
    this.suggestions = const [],
    this.profileCode,
    this.intent = '',
    this.confidence = 0,
  });

  final String text;

  /// Follow-up questions to show as buttons.
  final List<String> suggestions;

  /// e.g. "DI" when the answer is about Dominant–Influential.
  final String? profileCode;

  /// What the model understood, e.g. "strengths", "career", "out_of_scope".
  final String intent;
  final double confidence;
}

class DiscProfileInfo {
  const DiscProfileInfo(this.code, this.slash, this.label, this.archetype);
  final String code;
  final String slash;
  final String label;
  final String archetype;
}

// ---------------------------------------------------------------------------
// Brain: model predictions -> stored answer, with conversation memory
// ---------------------------------------------------------------------------

class DiscChatBrain {
  DiscChatBrain(this.profileLabels, this.intentLabels, this._answers,
      List<DiscProfileInfo> profiles)
      : _profilesByCode = {for (final p in profiles) p.code: p};

  final List<String> profileLabels;
  final List<String> intentLabels;
  final Map<String, String> _answers;
  final Map<String, DiscProfileInfo> _profilesByCode;

  /// Below this the model is unsure; the bot asks the user to rephrase.
  static const double minConfidence = 0.45;
  static const _generalAnswers = {
    'list_profiles',
    'what_is_disc',
    'list_intelligences'
  };
  static const _topicNames = {
    'strengths': 'Strengths of',
    'weaknesses': 'Weaknesses of',
    'career': 'Best careers for',
    'stress': 'Stress response of',
    'motivators': 'What motivates',
    'drains': 'What drains',
    'student': 'Student profile of',
    'relationships': 'Relationships of',
    'growth': 'Growth exercise for',
    'leadership': 'Leadership style of',
    'mentor': 'How to guide',
    'conflict': 'Conflict style of',
  };
  static const _help = 'You can ask me things like:\n• What is D/I?\n'
      '• What are my strengths? (after telling me "I am S/C")\n'
      '• Best careers for Influential–Steady\n• How does C/D handle stress?\n'
      '• How should a parent guide an I/I child?\n'
      '• Which type is most patient?\n• Tell me about Compliant people';

  /// The user's own DISC result, e.g. "DI".
  String? userProfile;
  String? _lastProfile;
  String? _lastIntent;

  void setUserProfile(String? code) {
    final c = code?.toUpperCase().split('').where((ch) => 'DISC'.contains(ch)).join();
    userProfile = (c != null && c.length == 2) ? c : null;
  }

  void reset() {
    _lastProfile = null;
    _lastIntent = null;
  }

  DiscReply welcome() {
    final me = userProfile == null ? null : _profilesByCode[userProfile];
    final text = me != null
        ? "Hi! I'm your DISC personality assistant. Your combination is ${me.label} — ${me.archetype}.\nAsk me anything about your personality, strengths, careers, studies or relationships."
        : "Hi! I'm your DISC personality assistant.\nAsk me about any of the 16 DISC combinations — strengths, weaknesses, careers, study style, stress, relationships, motivation, the 8 intelligences and more.";
    return DiscReply(text,
        suggestions: _starters(),
        profileCode: me?.code,
        intent: 'greeting',
        confidence: 1);
  }

  DiscReply reply(
      String question, int profileIdx, int intentIdx, double confidence) {
    var intent = intentLabels[intentIdx];
    final profile = profileLabels[profileIdx];
    final String? code = profile.length == 2 ? profile : null; // "DI"
    final String? style = profile.endsWith('_led') ? profile : null; // "D_led"

    if (confidence < minConfidence) {
      return DiscReply(
          'Sorry, I didn\'t understand that. Try asking like "What are the strengths of D/I?" or "Which careers suit Steady–Compliant?"',
          suggestions: _starters(),
          intent: 'unknown',
          confidence: confidence);
    }

    // "and S/C?" / "what about I/D?" -> same question as before, other profile
    final n = question.trim().toLowerCase();
    if (intent == 'overview' &&
        _lastIntent != null &&
        (n.startsWith('and ') ||
            n.startsWith('what about') ||
            n.startsWith('how about') ||
            n.startsWith('same for'))) {
      intent = _lastIntent!;
    }

    DiscReply r(String text, List<String> sugg, String? pc) => DiscReply(text,
        suggestions: sugg,
        profileCode: pc,
        intent: intent,
        confidence: confidence);

    switch (intent) {
      case 'greeting':
        return welcome();
      case 'thanks':
        return r("You're welcome! Anything else about your DISC profile?",
            _followUps(), _lastProfile);
      case 'bye':
        return r('Goodbye! Come back anytime to explore your DISC profile.',
            const [], null);
      case 'help':
        return r(_help, _starters(), null);
      case 'identity':
        return r(
            "I'm your DISC personality assistant. I explain the 16 DISC combinations and what they mean for study, work, family life and growth.",
            _starters(),
            null);
      case 'source':
        return r(
            "I'm not able to share that. I'm here to answer questions about the 16 DISC personality combinations — ask me about strengths, careers, study style, stress, relationships and more.",
            _starters(),
            null);
      case 'out_of_scope':
        return r(
            'I can only help with DISC personality questions — the 16 combinations, their strengths, weaknesses, careers, study style, stress, relationships, motivators, growth exercises and 8 intelligences.',
            _starters(),
            null);
      case 'declare_self':
        if (code == null) return _clarifyWhich(intent, confidence);
        userProfile = code;
        _lastProfile = code;
        _lastIntent = null;
        return r("Got it! I'll remember that.\n\n${_answer('$code|overview|self')}",
            _suggestionsFor(code, 'overview'), code);
    }
    if (intent.startsWith('rank_') || _generalAnswers.contains(intent)) {
      return r(_answer('NONE|$intent'), _starters(), null);
    }

    // A question about one profile (or a style group)
    if (style != null) {
      _lastIntent = intent;
      return r(_answer('$style|$intent'), _styleSuggestions(style[0]), null);
    }
    final self = _mentionsSelf(n);
    String target;
    var asSelf = false;
    if (code != null) {
      target = code;
      asSelf = self && code == userProfile;
    } else if (self && userProfile != null) {
      target = userProfile!;
      asSelf = true;
    } else if (self) {
      return r(
          'Tell me your DISC combination first — for example "I am D/I" or "My type is Steady–Compliant".',
          const ['I am D/I', 'I am S/C', 'Show all 16 combinations'],
          null);
    } else if (_lastProfile != null) {
      target = _lastProfile!;
    } else if (userProfile != null) {
      target = userProfile!;
      asSelf = true;
    } else {
      return _clarifyWhich(intent, confidence);
    }
    _lastProfile = target;
    _lastIntent = intent != 'overview' ? intent : null;
    final key = '$target|$intent${asSelf ? '|self' : ''}';
    return r(_answer(key), _suggestionsFor(target, intent), target);
  }

  // -------------------------------------------------------------------------

  String _answer(String key) =>
      _answers[key] ??
      _answers[key.endsWith('|self') ? key.substring(0, key.length - 5) : key] ??
      "Sorry, I don't have that yet.";

  DiscReply _clarifyWhich(String intent, double confidence) => DiscReply(
        'Which DISC combination should I answer for? For example D/I, S/C or Compliant–Steady.',
        suggestions: ['D/I', 'S/C', 'I/S']
            .map((s) => '${_topicNames[intent] ?? 'Tell me about'} $s')
            .toList(),
        intent: intent,
        confidence: confidence,
      );

  bool _mentionsSelf(String n) {
    final t = n.replaceAll(
        RegExp(r'\b(tell|show|give|help|let|explain|teach) me\b'), ' ');
    return RegExp(r'\b(i|im|me|my|mine|myself|mera|meri|mere|mujhe|main)\b')
        .hasMatch(t);
  }

  List<String> _starters() => userProfile != null
      ? const [
          'What are my strengths?',
          'Which careers suit me?',
          'How do I handle stress?',
          'How can I grow?'
        ]
      : const [
          'What is DISC?',
          'Show all 16 combinations',
          'What is D/I?',
          'Which type is most patient?'
        ];

  List<String> _followUps() => _lastProfile != null
      ? _suggestionsFor(_lastProfile!, _lastIntent ?? '')
      : _starters();

  /// Java's String.hashCode, so suggestion picks match the Android app.
  static int _javaHash(String s) {
    var h = 0;
    for (final c in s.codeUnits) {
      h = (h * 31 + c) & 0xFFFFFFFF;
    }
    return h >= 0x80000000 ? h - 0x100000000 : h;
  }

  List<String> _suggestionsFor(String code, String asked) {
    final s = _profilesByCode[code]?.slash ?? code;
    final pool = <MapEntry<String, String>>[
      MapEntry('strengths', 'Strengths of $s'),
      MapEntry('weaknesses', 'Weaknesses of $s'),
      MapEntry('career', 'Best careers for $s'),
      MapEntry('stress', 'How does $s handle stress?'),
      MapEntry('motivators', 'What motivates $s?'),
      MapEntry('mentor', 'How to guide a $s?'),
      MapEntry('student', '$s as a student'),
      MapEntry('relationships', '$s in relationships'),
      MapEntry('growth', 'Growth exercise for $s'),
    ].where((e) => e.key != asked).toList();
    var sum = (_javaHash(code) + _javaHash(asked)) & 0xFFFFFFFF;
    if (sum >= 0x80000000) sum -= 0x100000000;
    final start = sum % pool.length; // Dart % is already non-negative
    return List.generate(3, (i) => pool[(start + i * 2) % pool.length].value);
  }

  List<String> _styleSuggestions(String c) => profileLabels
      .where((l) => l.length == 2 && l[0] == c)
      .take(3)
      .map((l) => 'What is ${_profilesByCode[l]?.slash ?? l}?')
      .toList();
}

