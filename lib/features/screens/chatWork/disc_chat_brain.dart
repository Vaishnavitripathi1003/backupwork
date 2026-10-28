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

  /// Follow-up questions to show as tappable chips.
  final List<String> suggestions;

  /// e.g. "DI" when the answer is about Dominant–Influential.
  final String? profileCode;

  /// What the model understood, e.g. "strengths", "career", "out_of_scope".
  final String intent;
  final double confidence;
}

class DiscProfileInfo {
  const DiscProfileInfo(this.code, this.slash, this.label, this.archetype);
  final String code, slash, label, archetype;
}

/// Turns the model's two predictions into the right stored answer, with conversation memory.
class DiscChatBrain {
  DiscChatBrain(this.profileLabels, this.intentLabels, this._answers, List<DiscProfileInfo> profiles)
      : _profiles = {for (final p in profiles) p.code: p};

  /// Below this the model is unsure; the bot asks the user to rephrase.
  static const double minConfidence = 0.45;

  final List<String> profileLabels;
  final List<String> intentLabels;
  final Map<String, String> _answers;
  final Map<String, DiscProfileInfo> _profiles;

  String? _userProfile;
  String? _lastProfile;
  String? _lastIntent;

  /// The user's own DISC result, e.g. "DI".
  String? get userProfile => _userProfile;

  void setUserProfile(String? code) {
    final c = code?.toUpperCase().split('').where((ch) => 'DISC'.contains(ch)).join();
    _userProfile = (c != null && c.length == 2) ? c : null;
  }

  void reset() {
    _lastProfile = null;
    _lastIntent = null;
  }

  DiscReply welcome() {
    final me = _userProfile == null ? null : _profiles[_userProfile];
    final text = me != null
        ? "Hi! I'm your DISC personality assistant. Your combination is ${me.label} — ${me.archetype}.\n"
            'Ask me anything about your personality, strengths, careers, studies or relationships.'
        : "Hi! I'm your DISC personality assistant.\n"
            'Ask me about any of the 16 DISC combinations — strengths, weaknesses, careers, study style, '
            'stress, relationships, motivation, the 8 intelligences and more.';
    return DiscReply(text, suggestions: _starters(), profileCode: me?.code, intent: 'greeting', confidence: 1);
  }

  DiscReply reply(String question, int profileIdx, int intentIdx, double confidence) {
    var intent = intentLabels[intentIdx];
    final profile = profileLabels[profileIdx];
    final code = profile.length == 2 ? profile : null; // "DI" (not "D_led" / "NONE")
    final style = profile.endsWith('_led') ? profile : null; // "D_led"

    if (confidence < minConfidence) {
      return DiscReply(
        "Sorry, I didn't understand that. Try asking like \"What are the strengths of D/I?\" "
        'or "Which careers suit Steady–Compliant?"',
        suggestions: _starters(),
        intent: 'unknown',
        confidence: confidence,
      );
    }

    // "and S/C?" / "what about I/D?" → same question as before, for another profile
    final n = question.trim().toLowerCase();
    if (intent == 'overview' &&
        _lastIntent != null &&
        (n.startsWith('and ') || n.startsWith('what about') || n.startsWith('how about') || n.startsWith('same for'))) {
      intent = _lastIntent!;
    }

    DiscReply simple(String text, [List<String>? chips]) =>
        DiscReply(text, suggestions: chips ?? _starters(), intent: intent, confidence: confidence);

    switch (intent) {
      case 'greeting':
        return welcome();
      case 'thanks':
        return DiscReply("You're welcome! Anything else about your DISC profile?",
            suggestions: _followUps(), profileCode: _lastProfile, intent: intent, confidence: confidence);
      case 'bye':
        return simple('Goodbye! Come back anytime to explore your DISC profile.', const []);
      case 'help':
        return simple(_help);
      case 'identity':
        return simple("I'm your DISC personality assistant. I explain the 16 DISC combinations and what they "
            'mean for study, work, family life and growth.');
      case 'source':
        return simple("I'm not able to share that. I'm here to answer questions about the 16 DISC personality "
            'combinations — ask me about strengths, careers, study style, stress, relationships and more.');
      case 'out_of_scope':
        return simple('I can only help with DISC personality questions — the 16 combinations, their strengths, '
            'weaknesses, careers, study style, stress, relationships, motivators, growth exercises and 8 intelligences.');
      case 'declare_self':
        if (code == null) return _clarifyWhich(intent, confidence);
        _userProfile = code;
        _lastProfile = code;
        _lastIntent = null;
        return DiscReply("Got it! I'll remember that.\n\n${_answer('$code|overview|self')}",
            suggestions: _suggestionsFor(code, 'overview'), profileCode: code, intent: intent, confidence: confidence);
    }
    if (intent.startsWith('rank_') || _generalAnswers.contains(intent)) {
      return simple(_answer('NONE|$intent'));
    }

    // A style group ("Dominant people")
    if (style != null) {
      _lastIntent = intent;
      return DiscReply(_answer('$style|$intent'),
          suggestions: _styleSuggestions(style[0]), intent: intent, confidence: confidence);
    }

    // One profile
    final self = _mentionsSelf(n);
    String target;
    var asSelf = false;
    if (code != null) {
      target = code;
      asSelf = self && code == _userProfile;
    } else if (self && _userProfile != null) {
      target = _userProfile!;
      asSelf = true;
    } else if (self) {
      return DiscReply('Tell me your DISC combination first — for example "I am D/I" or "My type is Steady–Compliant".',
          suggestions: const ['I am D/I', 'I am S/C', 'Show all 16 combinations'], intent: intent, confidence: confidence);
    } else if (_lastProfile != null) {
      target = _lastProfile!;
    } else if (_userProfile != null) {
      target = _userProfile!;
      asSelf = true;
    } else {
      return _clarifyWhich(intent, confidence);
    }
    _lastProfile = target;
    _lastIntent = intent == 'overview' ? null : intent;
    final key = '$target|$intent${asSelf ? '|self' : ''}';
    return DiscReply(_answer(key),
        suggestions: _suggestionsFor(target, intent), profileCode: target, intent: intent, confidence: confidence);
  }

  // ---------------------------------------------------------------------------------------

  String _answer(String key) =>
      _answers[key] ?? _answers[key.replaceAll(RegExp(r'\|self$'), '')] ?? "Sorry, I don't have that yet.";

  DiscReply _clarifyWhich(String intent, double confidence) => DiscReply(
        'Which DISC combination should I answer for? For example D/I, S/C or Compliant–Steady.',
        suggestions: ['D/I', 'S/C', 'I/S'].map((c) => '${_topicNames[intent] ?? 'Tell me about'} $c').toList(),
        intent: intent,
        confidence: confidence,
      );

  static final RegExp _tellMe = RegExp(r'\b(tell|show|give|help|let|explain|teach) me\b');
  static final RegExp _selfWords = RegExp(r'\b(i|im|me|my|mine|myself|mera|meri|mere|mujhe|main)\b');

  bool _mentionsSelf(String n) => _selfWords.hasMatch(n.replaceAll(_tellMe, ' '));

  List<String> _starters() => _userProfile != null
      ? const ['What are my strengths?', 'Which careers suit me?', 'How do I handle stress?', 'How can I grow?']
      : const ['What is DISC?', 'Show all 16 combinations', 'What is D/I?', 'Which type is most patient?'];

  List<String> _followUps() =>
      _lastProfile != null ? _suggestionsFor(_lastProfile!, _lastIntent ?? '') : _starters();

  List<String> _suggestionsFor(String code, String asked) {
    final s = _profiles[code]?.slash ?? code;
    final pool = <List<String>>[
      ['strengths', 'Strengths of $s'],
      ['weaknesses', 'Weaknesses of $s'],
      ['career', 'Best careers for $s'],
      ['stress', 'How does $s handle stress?'],
      ['motivators', 'What motivates $s?'],
      ['mentor', 'How to guide a $s?'],
      ['student', '$s as a student'],
      ['relationships', '$s in relationships'],
      ['growth', 'Growth exercise for $s'],
    ].where((e) => e[0] != asked).toList();
    final start = (code + asked).codeUnits.fold<int>(0, (a, b) => a + b) % pool.length;
    return List.generate(3, (k) => pool[(start + k * 2) % pool.length][1]);
  }

  List<String> _styleSuggestions(String c) => profileLabels
      .where((l) => l.length == 2 && l[0] == c)
      .take(3)
      .map((l) => 'What is ${_profiles[l]?.slash ?? l}?')
      .toList();

  static const Set<String> _generalAnswers = {'list_profiles', 'what_is_disc', 'list_intelligences'};
  static const Map<String, String> _topicNames = {
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
  static const String _help = 'You can ask me things like:\n• What is D/I?\n'
      '• What are my strengths? (after telling me "I am S/C")\n• Best careers for Influential–Steady\n'
      '• How does C/D handle stress?\n• How should a parent guide an I/I child?\n'
      '• Which type is most patient?\n• Tell me about Compliant people';
}
