import 'dart:convert';
import 'package:flutter/services.dart';
import 'disc_bm25.dart';

class DiscKnowledgeBase {
  final Map<String,dynamic> data;
  DiscKnowledgeBase(this.data);
  static Future<DiscKnowledgeBase> fromAssets({String path='assets/disc/disc_knowledge.json'}) async =>
      DiscKnowledgeBase.fromJson(await rootBundle.loadString(path));
  factory DiscKnowledgeBase.fromJson(String json) => DiscKnowledgeBase(Map<String,dynamic>.from(jsonDecode(json) as Map));
  List<Map<String,dynamic>> get profiles => (data['profiles'] as List).map((p)=>Map<String,dynamic>.from(p as Map)).toList();
  Map<String,dynamic>? profile(String code) {
    for (final p in profiles) { if ((p['code'] as String).toUpperCase() == code.toUpperCase()) return p; }
    return null;
  }
  List<DiscChunk> chunks() {
    final result = <DiscChunk>[];
    for (final p in profiles) {
      final code = p['code'] as String;
      void add(String topic,dynamic value) {
        final str = value is List ? value.join(', ') : (value?.toString() ?? '');
        if (str.trim().isNotEmpty) result.add(DiscChunk(code,topic,str));
      }
      final swot = Map<String,dynamic>.from(p['swot'] as Map);
      for (final key in ['strengths','weaknesses','opportunities','threats']) { add(key,swot[key]); }
      final student = Map<String,dynamic>.from(p['student'] as Map);
      for (final key in ['group_projects','academic_pressure','communication','learning_environment']) { add(key,student[key]); }
      final pro = Map<String,dynamic>.from(p['professional'] as Map);
      for (final key in ['workplace_execution','leadership','stress_response']) { add(key,pro[key]); }
      add('career',pro['ideal_roles']);
      final personal=Map<String,dynamic>.from(p['personal'] as Map);
      for (final key in ['household','relationships','conflict']) { add(key,personal[key]); }
      final mentor=Map<String,dynamic>.from(p['mentor'] as Map);
      add('mentor',mentor['guideline']); add('communication_key',mentor['communication_key']);
      final growth=Map<String,dynamic>.from(mentor['growth_exercise'] as Map);
      add('growth','${growth['name']} ${growth['text']}');
      final drivers=Map<String,dynamic>.from(p['drivers'] as Map);
      add('motivators',drivers['fuels']); add('drains',drivers['drains']);
      final placement=Map<String,dynamic>.from(p['placement'] as Map);
      add('placement',placement.toString());
      final report=p['report'];
      if (report is Map) {
        final intelligence=report['intelligences'];
        if (intelligence is List) for (final entry in intelligence) {
          if (entry is Map) add('intelligences','${entry['name']} ${entry['area']} ${(entry['items'] as List?)?.join(' ') ?? ''}');
        }
      }
    }
    return result;
  }
}
