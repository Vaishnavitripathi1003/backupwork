import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'bm25.dart';
import 'original_phrases.dart';


/// Dart-only reply compatible with the earlier Flutter UI.
class DiscReply {
  final String text;
  final List<String> suggestions;
  final String? profileCode;
  final String kind;

  const DiscReply({required this.text, this.suggestions = const [],
    this.profileCode, this.kind = 'ANSWER'});

  factory DiscReply.fromMap(Map<dynamic, dynamic> map) => DiscReply(
    text: '${map['text'] ?? ''}',
    suggestions: (map['suggestions'] as List? ?? []).map((e) => '$e').toList(),
    profileCode: map['profileCode']?.toString(), kind: '${map['kind'] ?? 'ANSWER'}');
}

/// Entirely Dart; no Android, JNI, MethodChannel, Firebase or internet.
/// The included JSON is the original Android knowledge data.
class DiscChatbot {
  Map<String, dynamic>? _knowledge;
  final Map<String, Map<String, dynamic>> _profiles = {};
  String? _userProfile;
  String? _lastProfile;
  String? _lastTopic;
  bool _hindi = false;
  DiscBm25? _index;
  final Map<String,String> _lastTopicsByProfile = {};

  String? get userProfileCode => _userProfile;

  Future<DiscReply> initialize({String? profileCode, bool hindi = false}) async {
    _knowledge ??= jsonDecode(await rootBundle.loadString(
      'assets/disc/disc_knowledge.json')) as Map<String, dynamic>;
    _profiles.clear();
    for (final raw in (_knowledge!['profiles'] as List)) {
      final p = Map<String, dynamic>.from(raw as Map);
      _profiles['${p['code']}'] = p;
    }
    _index = DiscBm25(_buildChunks());
    _hindi = hindi;
    setUserProfile(profileCode);
    resetConversation();
    return welcome(hindi: hindi);
  }

  Future<String?> setUserProfile(String? code) async {
    _userProfile = _resolveCode(code ?? '');
    return _userProfile;
  }

  Future<String?> getUserProfile() async => _userProfile;

  Future<void> resetConversation() async {
    _lastProfile = null;
    _lastTopic = null;
    _lastTopicsByProfile.clear();
  }

  Future<DiscReply> welcome({bool hindi = false}) async {
    _ensureLoaded();
    final p = _userProfile == null ? null : _profiles[_userProfile];
    final label = p == null ? '' : ' Your combination is ${p['label']} — ${p['archetype']}.';
    return DiscReply(
      text: hindi
        ? 'नमस्ते! मैं आपका DISC पर्सनालिटी असिस्टेंट हूँ।$label\nआप मुझसे ताकत, करियर, पढ़ाई, रिश्तों, तनाव और DISC प्रोफाइल के बारे में पूछ सकते हैं।\n\nHi! I am your DISC personality assistant.$label'
        : 'Hi! I\'m your DISC personality assistant.$label\nAsk about strengths, weaknesses, careers, studies, relationships, motivation and all 16 DISC profiles.',
      suggestions: _suggestions(_userProfile), profileCode: _userProfile,
      kind: 'SMALL_TALK');
  }

  Future<DiscReply> ask(String message) async {
    _ensureLoaded();
    final raw = message.trim();
    final q = raw.toLowerCase();
    final hi = _hindi || RegExp(r'[\u0900-\u097f]').hasMatch(raw);
    if (q.isEmpty) return _help(hi);
    if (_match(q, ['reset', 'start over', 'clear chat', 'restart'])) {
      await resetConversation();
      return DiscReply(text: hi ? 'ठीक है, फिर से शुरू करते हैं।' : 'Okay, starting fresh. What would you like to know?', suggestions: _suggestions(_userProfile), kind: 'SMALL_TALK');
    }
    if (_match(q, ['show all 16', 'all profiles', 'list profiles', 'all combinations', '16 combinations'])) {
      return DiscReply(text: _profiles.values.map((p) => '${p['code']} — ${p['label']} · ${p['archetype']}').join('\n'), suggestions: ['What is D/I?', 'Compare S/C and I/D']);
    }
    if (_match(q, ['what is disc', 'explain disc', 'disc meaning'])) {
      return DiscReply(text: 'DISC describes four behavioral styles: D (Dominance), I (Influence), S (Steadiness), and C (Compliance). These combine into 16 primary/secondary profiles.', suggestions: ['Show all 16 combinations', 'What is D/I?']);
    }
    if (_match(q, ['hello', 'hi', 'hey', 'namaste', 'नमस्ते']) && q.split(RegExp(r'\s+')).length <= 3) return welcome(hindi: hi);
    if (_match(q, ['thank you', 'thanks', 'shukriya', 'धन्यवाद'])) return DiscReply(text: hi ? 'आपका स्वागत है! और क्या जानना चाहेंगे?' : 'You\'re welcome! Anything else about your DISC profile?', suggestions: _suggestions(_userProfile), kind: 'SMALL_TALK');
    if (_match(q, ['bye', 'goodbye', 'alvida', 'अलविदा'])) return const DiscReply(text: 'Goodbye! Come back anytime to explore your DISC profile.', kind: 'SMALL_TALK');

    final found = _findProfiles(raw);
    final declaresSelf = _match(q, ['i am ', 'i\'m ', 'my type', 'my profile', 'my disc', 'mera profile', 'मेरी प्रोफाइल']);
    if (declaresSelf && found.isNotEmpty) _userProfile = found.first;
    final refersSelf = _match(q, ['my ', 'mine', 'for me', 'i ', 'mera', 'meri', 'mujhe', 'मेरे', 'मेरा', 'मेरी', 'मुझे']);
    final topics = _originalTopics(raw);
    if (found.isEmpty && topics.isNotEmpty && RegExp(r'\b(which|who|highest|lowest|most|least|top)\b').hasMatch(q)) {
      final ranking = _ranking(topics.first, ascending: RegExp(r'\b(least|lowest|minimum)\b').hasMatch(q));
      if (ranking != null) return DiscReply(text: ranking, suggestions: const ['Compare D/I and S/C', 'Show all 16 combinations']);
    }
    if (found.length > 1) {
      final topic = topics.isEmpty ? 'overview' : topics.first;
      _lastProfile = found.first;
      _lastTopic = topic;
      _lastTopicsByProfile[found.first] = topic;
      return DiscReply(text: found.map((c) => _answer(_profiles[c]!, topic, false)).join('\n\n──────────\n\n'), suggestions: _suggestions(found.first));
    }
    var code = found.isNotEmpty ? found.first :
      (refersSelf ? _userProfile : (_lastProfile ?? _userProfile));
    if (code == null && topics.isEmpty && !_match(q, ['which','who','what type'])) {
      final matches = _index?.search(DiscText.terms(raw), limit: 3) ?? [];
      final useful = DiscText.terms(raw).length;
      if (matches.isNotEmpty && matches.first.score >= 3 &&
          matches.first.matchedTerms * 2 >= useful) {
        code = matches.first.chunk.profileCode;
        topics.add(matches.first.chunk.topic);
      }
    }
    if (code == null) {
      if (topics.isEmpty) return _help(hi);
      return DiscReply(text: hi ? 'कृपया DISC प्रोफाइल बताएं, जैसे D/I या S/C।' : 'Which DISC combination should I answer for? For example, D/I or S/C.', suggestions: ['I am D/I', 'I am S/C', 'Show all 16 combinations'], kind: 'CLARIFY');
    }
    if (topics.isEmpty && found.isEmpty && !refersSelf && !declaresSelf &&
        !RegExp(r'\b(what about|how about|and|also|same for|for|now)\b').hasMatch(q)) {
      final matches = _index?.search(DiscText.terms(raw), profileCode: code, limit: 1) ?? [];
      if (matches.isEmpty || matches.first.score < 1.6) return _outOfScope(hi);
    }
    final p = _profiles[code];
    if (p == null) return _help(hi);
    final topic = topics.isNotEmpty ? topics.first : (found.isEmpty && q.split(' ').length <= 4 ? (_lastTopic ?? 'overview') : 'overview');
    _lastProfile = code;
    _lastTopic = topic;
    _lastTopicsByProfile[code] = topic;
    return DiscReply(text: _answer(p, topic, refersSelf || declaresSelf), profileCode: code, suggestions: _suggestions(code));
  }

  void _ensureLoaded() {
    if (_knowledge == null) throw StateError('Call initialize() before ask().');
  }

  bool _match(String text, List<String> terms) => terms.any((t) => text.contains(t));

  String? _resolveCode(String input) {
    final s = input.toUpperCase().trim();
    final direct = RegExp(r'\b([DISC])\s*[/\- ]?\s*([DISC])\b').firstMatch(s);
    if (direct != null) return '${direct.group(1)}${direct.group(2)}';
    const styleMap = {'DOMINANT':'D', 'DOMINANCE':'D', 'INFLUENTIAL':'I', 'INFLUENCE':'I', 'STEADY':'S', 'STEADINESS':'S', 'COMPLIANT':'C', 'COMPLIANCE':'C'};
    final words = RegExp(r'[A-Z]+').allMatches(s).map((m) => m.group(0)!).toList();
    final codes = words.map((w) => styleMap[w]).whereType<String>().toList();
    return codes.length >= 2 ? '${codes[0]}${codes[1]}' : null;
  }

  List<String> _findProfiles(String raw) {
    final found = <String>[];
    final s = raw.toUpperCase();
    final pattern = RegExp(r'(?<![A-Z])([DISC])\s*[/\-]\s*([DISC])(?![A-Z])|(?<![A-Z])([DISC]{2})(?![A-Z])');
    for (final m in pattern.allMatches(s)) {
      final c = m.group(3) ?? '${m.group(1)}${m.group(2)}';
      if (_profiles.containsKey(c) && !found.contains(c)) found.add(c);
    }
    for (final p in _profiles.values) {
      final label = '${p['label']}'.toLowerCase().split(' (').first;
      if (raw.toLowerCase().contains(label) && !found.contains(p['code'])) found.add('${p['code']}');
    }
    if (found.isEmpty) {
      final c = _resolveCode(raw);
      if (c != null && _profiles.containsKey(c)) found.add(c);
    }
    return found;
  }


  /// Phrases are extracted directly from Kotlin QueryParser.kt, including
  /// its topic names and parameter labels. Longer phrases take priority.
  List<String> _originalTopics(String input) {
    final normalized = DiscText.normalize(input);
    final words = DiscText.tokens(normalized);
    final used = List<bool>.filled(words.length, false);
    final ordered = [...originalPhrases]..sort((a,b)=>
        DiscText.tokens(b[0]).length.compareTo(DiscText.tokens(a[0]).length));
    final found=<String>[];
    for(final entry in ordered) {
      final phrase=DiscText.tokens(DiscText.normalize(entry[0]));
      if(phrase.isEmpty || phrase.length>words.length)continue;
      for(var i=0;i<=words.length-phrase.length;i++) {
        var match=true;
        for(var j=0;j<phrase.length;j++) {
          if(used[i+j]||words[i+j]!=phrase[j]){match=false;break;}
        }
        if(match) {
          for(var j=0;j<phrase.length;j++)used[i+j]=true;
          final topic=_topicKey(entry[1]);
          if(!found.contains(topic))found.add(topic);
          break;
        }
      }
    }
    if(found.contains('career'))found.remove('work');
    if(found.contains('intelligence_one'))found.remove('intelligences');
    if(found.contains('communication_key'))found.remove('communication');
    if(found.contains('swot')&&found.length>1)found.remove('swot');
    if(found.contains('academic_pressure'))found.remove('stress');
    return found;
  }
  String _topicKey(String t)=>const {
    'workplace':'work','student':'student', 'personal':'personal',
    'communication_style':'communication', 'comm_key':'communication_key',
  }[t]??t;

  List<DiscChunk> _buildChunks() {
    final chunks=<DiscChunk>[];
    for(final p in _profiles.values) {
      final code='${p['code']}';
      Map<String,dynamic> map(dynamic v)=>v is Map?Map<String,dynamic>.from(v):{};
      final swot=map(p['swot']),student=map(p['student']);
      final professional=map(p['professional']),personal=map(p['personal']);
      final mentor=map(p['mentor']),drivers=map(p['drivers']),placement=map(p['placement']);
      final report=map(p['report']);
      void add(String topic,dynamic v,[String? param]) {
        final text=v==null?'':v is List?v.join(', '):'$v';
        if(text.trim().isNotEmpty)chunks.add(DiscChunk(code,topic,text,param));
      }
      for(final t in ['strengths','weaknesses','opportunities','threats'])add(t,swot[t]);
      add('group_projects',student['group_projects']);
      add('academic_pressure',student['academic_pressure']);
      add('communication',student['communication']);
      add('learning',student['learning_environment']);
      add('work',professional['workplace_execution']);
      add('leadership',professional['leadership']);
      add('stress',professional['stress_response']);
      add('career',[...(professional['ideal_roles'] as List? ?? []),...(map(report['work_direction'])['suitable_for'] as List? ?? [])]);
      add('household',personal['household']);add('relationships',personal['relationships']);
      add('conflict',personal['conflict']);add('mentor',mentor['guideline']);
      add('communication_key',mentor['communication_key']);
      final exercise=map(mentor['growth_exercise']);
      add('growth','${exercise['name']??''} ${exercise['text']??''}');
      add('motivators',drivers['fuels']);add('drains',drivers['drains']);
      add('placement','${map(placement['primary'])['text']} ${map(placement['secondary'])['text']}');
      for(final it in (report['intelligences'] as List? ?? [])){
        final i=map(it);
        add('intelligence_one','${i['name']} ${i['area']} ${(i['items'] as List? ?? []).join(' ')}','${i['key']}');
      }
    }
    return chunks;
  }

  String? _ranking(String topic,{bool ascending=false}) {
    final meterNames=<String,String>{
      'decisiveness':'Decisiveness & Drive','autonomy':'Task Autonomy',
      'pace':'Pace & Execution Urgency','risk':'Calculated Risk Appetite',
      'patience':'Consistency & Patience','listening':'Collaborative Listening'};
    if(['strengths','weaknesses','opportunities','threats'].contains(topic)) {
      final rows=_profiles.values.map((p){final sw=Map<String,dynamic>.from(p['swot']);
        final pct=Map<String,dynamic>.from(sw['pct']);return (p:p,value:(pct[topic] as num).toInt(),detail:'${sw[topic]}');}).toList();
      rows.sort((a,b)=>ascending?a.value.compareTo(b.value):b.value.compareTo(a.value));
      final top=rows.where((r)=>r.value==rows.first.value);
      return '${ascending?'Lowest':'Highest'} share of $topic (${rows.first.value}%):\n'
          '${top.map((r)=>'• ${r.p['code']} · ${r.p['archetype']} — ${r.detail}').join('\n')}';
    }
    if(topic=='meters'||topic=='meter_one') {
      // Meter ranking requires a named metric; otherwise leave the question for clarification.
      return null;
    }
    return null;
  }

  DiscReply _outOfScope(bool hindi)=>DiscReply(
    text:hindi?'मैं केवल DISC पर्सनालिटी के सवालों में मदद कर सकता हूँ — 16 कॉम्बिनेशन, ताकत, कमजोरियाँ, करियर, तनाव और रिश्ते।\n\nI can only help with DISC personality questions.':
      'I can only help with DISC personality questions — the 16 combinations, their strengths, weaknesses, careers, study style, stress, relationships, motivators, growth exercises and 8 intelligences.',
    suggestions:_suggestions(_userProfile),kind:'OUT_OF_SCOPE');

  List<String> _topics(String q) {
    const triggers = <String, List<String>>{
      'swot': ['swot'],
      'strengths': ['strength', 'strong', 'good at', 'advantage', 'taakat', 'khubi', 'ताकत'],
      'weaknesses': ['weakness', 'weak point', 'weak ', 'kamzori', 'कमजोर'],
      'opportunities': ['opportunit', 'scope', 'अवसर'],
      'threats': ['threat', 'risk', 'khatra', 'खतरा'],
      'career': ['career', 'jobs', 'job ', 'role', 'profession', 'करियर', 'naukri'],
      'leadership': ['leader', 'leadership', 'नेतृत्व'],
      'stress': ['stress', 'pressure', 'तनाव'],
      'work': ['work', 'office', 'workplace', 'काम'],
      'learning': ['learning', 'study', 'studies', 'padhai', 'पढ़ाई'],
      'group_projects': ['group project', 'team project'],
      'academic_pressure': ['academic pressure', 'exam'],
      'relationships': ['relationship', 'partner', 'रिश्त'],
      'conflict': ['conflict', 'argument', 'झगड़'],
      'household': ['home life', 'household', 'family', 'परिवार'],
      'mentor': ['mentor', 'parent', 'guideline', 'मार्गदर्शन'],
      'communication': ['communication', 'communicate', 'बातचीत'],
      'growth': ['growth', 'improve', 'exercise', 'विकास'],
      'motivators': ['motivat', 'fuel', 'inspire', 'प्रेरणा'],
      'drains': ['drain', 'energy', 'exhaust', 'थका'],
      'intelligences': ['intelligence', 'intelligences', 'बुद्धिमत्ता'],
      'meters': ['meter', 'score', 'percentage', 'decisive', 'autonomy', 'patience', 'listening'],
      'placement': ['placement', 'primary', 'secondary', '60%', '40%', 'blend'],
    };
    final found = <String>[];
    for (final entry in triggers.entries) {
      if (_match(q, entry.value)) found.add(entry.key);
    }
    return found;
  }

  String _answer(Map<String, dynamic> p, String topic, bool self) {
    Map<String, dynamic> map(dynamic x) => x is Map ? Map<String, dynamic>.from(x) : {};
    String value(dynamic x) => x is List ? x.map((e) => '• $e').join('\n') : '$x';
    final student = map(p['student']); final professional = map(p['professional']);
    final personal = map(p['personal']); final mentor = map(p['mentor']);
    final drivers = map(p['drivers']); final swot = map(p['swot']);
    final report = map(p['report']); final placement = map(p['placement']);
    final primary = map(placement['primary']); final secondary = map(placement['secondary']);
    final pct = map(swot['pct']);
    final heading = '${p['label']} · ${p['archetype']}';
    String lines(String label, dynamic data) => '$heading\n\n$label\n${value(data)}';
    switch (topic) {
      case 'strengths': case 'weaknesses': case 'opportunities': case 'threats':
        return lines('${topic[0].toUpperCase()}${topic.substring(1)} (${pct[topic] ?? '-'}%)', swot[topic]);
      case 'swot':
        return '$heading\n\nSWOT analysis\n${['strengths','weaknesses','opportunities','threats'].map((t) => '${t.toUpperCase()} (${pct[t] ?? '-'}%): ${swot[t]}').join('\n\n')}';
      case 'career': return lines('Suitable careers / करियर', professional['ideal_roles']);
      case 'leadership': return lines('Leadership', professional['leadership']);
      case 'stress': return lines('Stress response', professional['stress_response']);
      case 'work': return lines('Workplace / कार्यस्थल', professional['workplace_execution']);
      case 'group_projects': return lines('Group projects', student['group_projects']);
      case 'academic_pressure': return lines('Academic pressure', student['academic_pressure']);
      case 'learning': return lines('Learning environment / पढ़ाई', student['learning_environment']);
      case 'relationships': return lines('Relationships / रिश्ते', personal['relationships']);
      case 'conflict': return lines('Conflict resolution', personal['conflict']);
      case 'household': return lines('Home and family', personal['household']);
      case 'mentor': return lines('Mentoring guidance', '${mentor['guideline']}\n${mentor['communication_key']}');
      case 'communication': return lines('Communication', '${student['communication']}\n${mentor['communication_key']}');
      case 'growth': final ex = map(mentor['growth_exercise']); return lines('Growth exercise', '${ex['name']}: ${ex['text']}');
      case 'motivators': return lines('Motivation / प्रेरणा', drivers['fuels']);
      case 'drains': return lines('Energy drains', drivers['drains']);
      case 'intelligences':
        final items = (report['intelligences'] as List? ?? []);
        return lines('Multiple intelligences', items.map((x) { final i = map(x); return '${i['name']} (${i['level']}): ${i['area']}'; }).join('\n'));
      case 'meters':
        return lines('Behavioral intensity meters', (p['meters'] as List).map((x) { final m=map(x); return '${m['name']}: ${m['value']}% (${m['level']})'; }).join('\n'));
      case 'placement': return lines('Primary / Secondary (60/40)', '${primary['text']}\n${secondary['text']}');
      default:
        final summary = map(p['summary']);
        return '${self ? 'You are / आप हैं ' : ''}$heading\n\nPrimary (60%): ${primary['text']}\nSecondary (40%): ${secondary['text']}\n\nIn short / संक्षेप में:\n• As a student: ${summary['student']}\n• At work: ${summary['professional']}\n• In personal life: ${summary['personal']}\n• Strengths: ${swot['strengths']}\n• Energised by: ${drivers['fuels']}';
    }
  }

  List<String> _suggestions(String? code) => code == null
    ? ['I am D/I', 'Show all 16 combinations', 'What is DISC?']
    : ['What are my strengths?', 'My weaknesses', 'Career for $code', 'How do I handle stress?'];

  DiscReply _help(bool hi) => DiscReply(
    text: hi ? 'मैं DISC पर्सनालिटी के बारे में बताता हूँ। कृपया अपना प्रोफाइल जैसे D/I बताएं, या ताकत, करियर, रिश्तों के बारे में पूछें।' : 'I can explain 16 DISC profiles and their strengths, weaknesses, careers, study styles, relationships, motivation, SWOT and intelligences. Tell me your combination, e.g. "I am D/I".',
    suggestions: _suggestions(_userProfile), kind: 'SMALL_TALK');
}
