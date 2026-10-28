import 'dart:convert';
import 'package:flutter/services.dart';
import 'disc_bm25.dart';
import 'disc_knowledge_base.dart';
import 'disc_text.dart';

enum BotReplyKind { answer, clarify, smallTalk, outOfScope }

class BotReply {
  final String text;
  final List<String> suggestions;
  final String? profileCode;
  final BotReplyKind kind;
  const BotReply(this.text, {this.suggestions = const [], this.profileCode, this.kind = BotReplyKind.answer});
}

/// Offline, asset-backed DISC chatbot for embedding in an existing Flutter app.
/// No server, model download, native Android SDK or permissions required.
class DiscChatbot {
  final Map<String, dynamic> _root;
  late final List<Map<String, dynamic>> profiles;
  late final List<Map<String, dynamic>> quadrants;
  late final DiscBm25 _index;
  String? userProfileCode;
  String? _lastCode;
  String? _lastTopic;

  DiscChatbot._(this._root) {
    profiles = _maps(_root['profiles']);
    quadrants = _maps(_root['quadrants']);
    _index = DiscBm25(DiscKnowledgeBase(_root).chunks());
  }

  static Future<DiscChatbot> fromAssets({String path = 'assets/disc/disc_knowledge.json'}) async {
    final source = await rootBundle.loadString(path);
    return DiscChatbot.fromJson(source);
  }


  factory DiscChatbot.fromJson(String json) => DiscChatbot._(Map<String, dynamic>.from(jsonDecode(json) as Map));

  static List<Map<String, dynamic>> _maps(dynamic v) =>
      v is List ? v.whereType<Map>().map((x) => Map<String, dynamic>.from(x)).toList() : [];
  static Map<String, dynamic> _map(dynamic v) => v is Map ? Map<String, dynamic>.from(v) : {};
  static String _str(dynamic v) => v?.toString() ?? '';
  static List<String> _strings(dynamic v) => v is List ? v.map(_str).where((e) => e.isNotEmpty).toList() : [];
  String _code(Map<String, dynamic> p) => _str(p['code']).toUpperCase();
  Map<String, dynamic>? profile(String code) {
    for (final p in profiles) { if (_code(p) == code.toUpperCase()) return p; }
    return null;
  }

  static const _styles = {'dominant':'D','dominance':'D','driver':'D','influential':'I','influence':'I',
    'steady':'S','steadiness':'S','stable':'S','compliant':'C','compliance':'C','conscientious':'C'};
  String? resolveCode(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final normalized = input.toLowerCase().replaceAll(RegExp(r'[^a-z]'), ' ');
    final words = normalized.split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    final compact = input.toUpperCase().replaceAll(RegExp(r'[^DISC]'), '');
    if (compact.length == 2 && profile(compact) != null) return compact;
    final chars = words.map((w) => _styles[w]).whereType<String>().toList();
    if (chars.length >= 2 && profile('${chars[0]}${chars[1]}') != null) return '${chars[0]}${chars[1]}';
    for (final p in profiles) {
      final aliases = _strings(p['aliases']);
      if (aliases.any((a) => a.toLowerCase() == input.trim().toLowerCase())) return _code(p);
    }
    return null;
  }

  void setUserProfile(String? code) => userProfileCode = resolveCode(code);
  void setUserProfileFromStyles(String primary, String secondary) => setUserProfile('$primary $secondary');
  void resetConversation() { _lastCode = null; _lastTopic = null; }
  String _slash(String code) => code.length == 2 ? '${code[0]}/${code[1]}' : code;
  String _name(Map<String, dynamic> p) => '${_str(p['label'])} · ${_str(p['archetype'])}';
  bool _hindi(String q) => RegExp(r'[\u0900-\u097F]').hasMatch(q) ||
      RegExp(r'\b(kya|kaise|kaun|batao|bataiye|mera|meri|mere|mujhe|hai|hain|hoon|naukri|padhai|kamzori|taakat|rishte|kaam)\b', caseSensitive: false).hasMatch(q);
  String _heading(String english, String hindi, bool hi) => hi ? '$hindi / $english' : english;
  List<String> _suggestions(String? code, {bool hi = false}) => code == null
      ? ['Show all 16 combinations', 'What is D/I?', 'Compare D/I and S/C']
      : ['Strengths of ${_slash(code)}', 'Career of ${_slash(code)}', 'Weaknesses of ${_slash(code)}', '8 intelligences of ${_slash(code)}'];

  BotReply welcome({bool hindi = false}) {
    final p = userProfileCode == null ? null : profile(userProfileCode!);
    final info = p == null ? '' : ' Your combination is ${_name(p)}.';
    final msg = 'Hi! I\'m your DISC personality assistant.$info\nAsk about any of the 16 DISC combinations, strengths, weaknesses, career, studies, relationships, SWOT and intelligences.';
    return BotReply(hindi ? 'नमस्ते! मैं आपका DISC पर्सनालिटी असिस्टेंट हूँ।\n$msg' : msg,
      suggestions: _suggestions(userProfileCode, hi: hindi), profileCode: userProfileCode, kind: BotReplyKind.smallTalk);
  }

  static const Map<String, List<String>> _terms = {
    'strengths': ['strength','strengths','strong','taakat','khubi','khubiyan','ताकत','खूबी'],
    'weaknesses': ['weak','weakness','weaknesses','kamzori','कमजोरी','कमज़ोरी'],
    'opportunities': ['opportunity','opportunities','potential','scope','अवसर'],
    'threats': ['threat','threats','risk','risks','khatra','खतरा'],
    'swot': ['swot'],
    'meters': ['meter','meters','score','scores','percentage','intensity','decisiveness','patience','listening','autonomy','pace'],
    'placement': ['placement','quadrant placement','blend','ratio','60%','40%'],
    'student': ['student','study','studies','school','college','padhai','पढ़ाई','छात्र'],
    'group_projects': ['group project','group work','team project','assignment'],
    'academic_pressure': ['exam','exams','academic pressure','marks','test'],
    'learning_environment': ['learning','learn','teaching','study environment'],
    'communication': ['communication','communicate','speaking','बातचीत'],
    'professional': ['professional','work','workplace','office','job','kaam','काम'],
    'leadership': ['leadership','leader','manager','management','boss'],
    'stress_response': ['stress','stressed','tension','pressure','तनाव'],
    'career': ['career','careers','role','roles','profession','naukri','नौकरी','job options'],
    'personal': ['personal','personal life','family','घर','जीवन'],
    'household': ['household','home','घर'],
    'relationships': ['relationship','relationships','rishte','रिश्ते','friends','friendship'],
    'conflict': ['conflict','fight','argument','disagreement','झगड़ा'],
    'mentor': ['mentor','mentoring','guideline','coaching'],
    'growth': ['growth','improve','improvement','exercise','develop','सुधार'],
    'motivators': ['motivation','motivate','motivators','fuel','fuels','प्रेरणा'],
    'drains': ['drain','drains','demotivate','energy'],
    'intelligences': ['intelligence','intelligences','8 intelligences','eight intelligences','बुद्धिमत्ता'],
    'overview': ['overview','personality','describe','tell me about','meaning','about','traits','स्वभाव','व्यक्तित्व'],
  };

  List<String> _topics(String question) {
    final lower = question.toLowerCase();
    final found = <String>[];
    for (final e in _terms.entries) {
      if (e.value.any((term) => RegExp(r'[\u0900-\u097F]').hasMatch(term)
        ? lower.contains(term) : RegExp('(^|[^a-z])${RegExp.escape(term)}([^a-z]|\$)').hasMatch(lower))) found.add(e.key);
    }
    const nested = {'group_projects':'student','academic_pressure':'student','learning_environment':'student',
      'communication':'student','leadership':'professional','stress_response':'professional','career':'professional',
      'household':'personal','relationships':'personal','conflict':'personal',
      'strengths':'swot','weaknesses':'swot','opportunities':'swot','threats':'swot','growth':'mentor'};
    for (final entry in nested.entries) { if (found.contains(entry.key)) found.remove(entry.value); }
    if (found.length > 1) found.remove('overview');
    return found;
  }

  List<String> _mentionedProfiles(String message) {
    final found = <String>[];
    final explicit = RegExp(r'(?<![A-Za-z])([DISC])\s*[/\-]\s*([DISC])(?![A-Za-z])', caseSensitive: false);
    for (final m in explicit.allMatches(message)) {
      final c = '${m.group(1)}${m.group(2)}'.toUpperCase();
      if (profile(c) != null && !found.contains(c)) found.add(c);
    }
    final compact = RegExp(r'(?<![A-Za-z])([DISC]{2})(?![A-Za-z])', caseSensitive: false);
    for (final m in compact.allMatches(message)) {
      final c = m.group(1)!.toUpperCase();
      if (profile(c) != null && !found.contains(c)) found.add(c);
    }
    final lower = message.toLowerCase();
    for (final p in profiles) {
      final c = _code(p);
      if (found.contains(c)) continue;
      if (_strings(p['aliases']).any((a) => a.length >= 4 && lower.contains(a.toLowerCase()))) found.add(c);
    }
    final styleWords = RegExp(r'\b(dominant|influential|steady|compliant|dominance|influence|steadiness|compliance)\b', caseSensitive: false)
      .allMatches(message).map((m) => _styles[m.group(0)!.toLowerCase()]).whereType<String>().toList();
    if (found.isEmpty && styleWords.length >= 2) {
      final c = '${styleWords[0]}${styleWords[1]}';
      if (profile(c) != null) found.add(c);
    }
    return found;
  }

  BotReply ask(String message) {
    final q = message.trim(); final hi = _hindi(q);
    if (q.isEmpty) return help(hindi: hi);
    final lower = q.toLowerCase();
    if (RegExp(r'^(reset|start over|restart|clear chat|नया शुरू)').hasMatch(lower)) {
      resetConversation();
      return BotReply(hi ? 'ठीक है, फिर से शुरू करते हैं। / Okay, starting fresh.' : 'Okay, starting fresh.',
        kind: BotReplyKind.smallTalk, suggestions: _suggestions(userProfileCode));
    }
    if (RegExp(r'^(hi|hello|hey|namaste|नमस्ते)[!. ]*$').hasMatch(lower)) return welcome(hindi: hi);
    if (RegExp(r'^(thanks|thank you|shukriya|धन्यवाद)[!. ]*$').hasMatch(lower)) {
      return BotReply(hi ? 'आपका स्वागत है! / You’re welcome!' : 'You’re welcome! Anything else about your DISC profile?',
        suggestions: _suggestions(userProfileCode), kind: BotReplyKind.smallTalk);
    }
    if (RegExp(r'^(bye|goodbye|अलविदा)[!. ]*$').hasMatch(lower)) {
      return const BotReply('Goodbye! Come back anytime to explore your DISC profile.', kind: BotReplyKind.smallTalk);
    }
    if (RegExp(r'\b(who are you|your name|तुम कौन)\b').hasMatch(lower)) return welcome(hindi: hi);
    if (RegExp(r'(what is disc|disc kya|disc क्या|explain disc)').hasMatch(lower)) {
      return BotReply('DISC is a behavioural framework describing four main styles: Dominance (D), Influence (I), Steadiness (S) and Compliance (C). Their primary/secondary combinations give 16 DISC profiles.', suggestions: _suggestions(null));
    }
    if (RegExp(r'(all 16|list (all )?profiles|show (all )?profiles|all combinations|16 combinations)').hasMatch(lower)) {
      return BotReply(profiles.map((p) => '${_slash(_code(p))}: ${_name(p)}').join('\n'), suggestions: _suggestions(null));
    }
    final declared = RegExp(r'\b(i am|i\x27m|my type is|my profile is|i have|mera type|meri profile)\b', caseSensitive: false).hasMatch(q);
    final mentioned = _mentionedProfiles(q);
    if (declared && mentioned.isNotEmpty) userProfileCode = mentioned.first;
    var targets = mentioned;
    final isSelf = RegExp(r'\b(my|mine|me|myself|mera|meri|mere|mujhe|main|मैं|मेरा|मेरी)\b', caseSensitive: false).hasMatch(q);
    final previous = RegExp(r'\b(it|its|them|their|that|those|uske|unka|उसके|उनका)\b', caseSensitive: false).hasMatch(q);
    final topics = _topics(q);
    if (targets.isEmpty && isSelf && userProfileCode != null) targets = [userProfileCode!];
    if (targets.isEmpty && (previous || topics.isNotEmpty) && _lastCode != null) targets = [_lastCode!];
    if (targets.isEmpty && topics.isNotEmpty && userProfileCode != null) targets = [userProfileCode!];
    if (targets.isEmpty) {
      if (isSelf && userProfileCode == null) return const BotReply(
        'Tell me your DISC combination first, for example "I am D/I" or "My type is S/C".',
        suggestions: ['I am D/I', 'I am S/C', 'Show all 16 combinations'], kind: BotReplyKind.clarify);
      if (topics.isEmpty) {
        final matches = _index.search(DiscText.terms(q), limit: 10);
        if (matches.isNotEmpty && matches.first.score >= 3.0) {
          final top = matches.first;
          final p = profile(top.chunk.profileCode);
          if (p != null) {
            _lastCode = top.chunk.profileCode; _lastTopic = top.chunk.topic;
            return BotReply(_compose(p, top.chunk.topic, hi), profileCode: top.chunk.profileCode, suggestions: _suggestions(top.chunk.profileCode));
          }
        }
      }
      if (topics.isNotEmpty) return BotReply('Which DISC combination should I answer for? For example D/I, S/C or C/S.',
        suggestions: ['${topics.first} of D/I', '${topics.first} of S/C', '${topics.first} of I/S'], kind: BotReplyKind.clarify);
      return help(hindi: hi);
    }
    var pickedTopics = topics;
    if (pickedTopics.isEmpty && previous && _lastTopic != null) pickedTopics = [_lastTopic!];
    if (pickedTopics.isEmpty) {
      final ranked = _index.search(DiscText.terms(q), profileCode: targets.first, limit: 1);
      if (ranked.isNotEmpty && ranked.first.score >= 1.6) {
        pickedTopics = [ranked.first.chunk.topic];
      } else {
        pickedTopics = ['overview'];
      }
    }
    if (targets.length >= 2) {
      final chunks = <String>[];
      for (final code in targets.take(4)) {
        final p = profile(code); if (p == null) continue;
        chunks.add('${_slash(code)} — ${_name(p)}\n${pickedTopics.map((t) => _compose(p, t, hi)).join('\n')}');
      }
      _lastCode = targets.first; _lastTopic = pickedTopics.first;
      return BotReply(chunks.join('\n\n'), profileCode: targets.first, suggestions: _suggestions(targets.first));
    }
    final p = profile(targets.first);
    if (p == null) return help(hindi: hi);
    _lastCode = targets.first; _lastTopic = pickedTopics.first;
    final body = pickedTopics.take(3).map((t) => _compose(p, t, hi)).where((e) => e.isNotEmpty).join('\n\n');
    return BotReply(body, profileCode: targets.first, suggestions: _suggestions(targets.first, hi: hi));
  }

  BotReply help({bool hindi = false}) => BotReply(
    hindi ? 'आप DISC के 16 प्रोफाइल, ताकत, कमजोरी, करियर, पढ़ाई और रिश्तों के बारे में पूछ सकते हैं।\nYou can ask about DISC profiles, strengths, careers, studies and relationships.'
    : 'I can help with the 16 DISC combinations: strengths, weaknesses, careers, study style, stress, relationships, motivation, SWOT and 8 intelligences.',
    kind: BotReplyKind.smallTalk, suggestions: _suggestions(userProfileCode, hi: hindi));

  String _compose(Map<String, dynamic> p, String topic, bool hi) {
    final code = _code(p);
    final title = '${_slash(code)} — ${_name(p)}';
    final swot = _map(p['swot']); final mentor = _map(p['mentor']);
    final professional = _map(p['professional']); final student = _map(p['student']);
    final personal = _map(p['personal']); final driver = _map(p['drivers']);
    final report = _map(p['report']); final placement = _map(p['placement']);
    String section(String name, String content) => '$title\n${_heading(name, _hiTitles[name] ?? name, hi)}\n$content';
    switch (topic) {
      case 'strengths': case 'weaknesses': case 'opportunities': case 'threats':
        return section(topic.toUpperCase(), _str(swot[topic]));
      case 'swot':
        return section('SWOT', ['strengths','weaknesses','opportunities','threats'].map((k) => '${k.toUpperCase()}: ${_str(swot[k])}').join('\n\n'));
      case 'meters':
        return section('Behavioural meters', _maps(p['meters']).map((m) => '${m['name']}: ${m['value']}% (${m['level']})').join('\n'));
      case 'placement':
        return section('Placement', 'Primary: ${_str(_map(placement['primary'])['text'])}\nSecondary: ${_str(_map(placement['secondary'])['text'])}');
      case 'student':
        return section('Student life', student.entries.map((e) => '${_pretty(e.key)}: ${e.value}').join('\n\n'));
      case 'group_projects': case 'academic_pressure': case 'learning_environment':
        return section(_pretty(topic), _str(student[topic]));
      case 'communication':
        return section('Communication', _str(student['communication']));
      case 'professional':
        return section('Professional life', professional.entries.map((e) => '${_pretty(e.key)}: ${e.value is List ? _strings(e.value).join(', ') : e.value}').join('\n\n'));
      case 'leadership': case 'stress_response':
        return section(_pretty(topic), _str(professional[topic]));
      case 'career':
        final roles = _strings(professional['ideal_roles']);
        return section('Career', 'Suitable roles: ${roles.join(', ')}\n${_strings(_map(report['work_direction'])['intro']).join(' ')}');
      case 'personal':
        return section('Personal life', personal.entries.map((e) => '${_pretty(e.key)}: ${e.value}').join('\n\n'));
      case 'household': case 'relationships': case 'conflict':
        return section(_pretty(topic), _str(personal[topic]));
      case 'mentor':
        return section('Mentor', 'Guideline: ${_str(mentor['guideline'])}\nCommunication key: ${_str(mentor['communication_key'])}');
      case 'growth':
        final growth = _map(mentor['growth_exercise']);
        return section('Growth exercise', '${_str(growth['name'])}: ${_str(growth['text'])}');
      case 'motivators': return section('Motivators', _str(driver['fuels']));
      case 'drains': return section('Drains', _str(driver['drains']));
      case 'intelligences':
        return section('8 intelligences', _maps(report['intelligences']).map((i) =>
          '${_str(i['name'])} (${_str(i['level'])}) — ${_str(i['area'])}\n${_strings(i['items']).join('; ')}').join('\n\n'));
      default:
        final summary = _map(p['summary']);
        return section('Overview', '${_str(summary['short_name'])}\n${_str(summary['student'])}\n${_str(summary['professional'])}\n${_str(summary['personal'])}\nMotivators: ${_str(driver['fuels'])}');
    }
  }
  static String _pretty(String k) => k.replaceAll('_', ' ').split(' ').map((w) => w.isEmpty ? w : '${w[0].toUpperCase()}${w.substring(1)}').join(' ');
  static const _hiTitles = {'Career':'करियर','Student life':'विद्यार्थी जीवन','Strengths':'ताकत',
    'Personal life':'निजी जीवन','Professional life':'कामकाजी जीवन','Growth exercise':'विकास अभ्यास',
    'Communication':'संवाद','Motivators':'प्रेरणा','Drains':'ऊर्जा की कमी','Overview':'परिचय',
    '8 intelligences':'8 बुद्धिमत्ता','Behavioural meters':'व्यवहार स्कोर','Placement':'प्रोफाइल स्थिति'};
}
