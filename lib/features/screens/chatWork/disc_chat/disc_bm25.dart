import 'dart:math' as math;
import 'disc_text.dart';

class DiscChunk {
  final String profileCode, topic, text;
  const DiscChunk(this.profileCode, this.topic, this.text);
}
class DiscSearchHit {
  final DiscChunk chunk;
  final double score;
  final int matchedTerms;
  const DiscSearchHit(this.chunk, this.score, this.matchedTerms);
}
/// Okapi BM25 (k1=1.2, b=0.75), matching the original Android algorithm.
class DiscBm25 {
  final List<DiscChunk> chunks;
  final double k1, b;
  late final List<Map<String,int>> _counts;
  late final List<int> _lengths;
  late final double _average;
  final Map<String,int> _df = {};
  DiscBm25(this.chunks, {this.k1=1.2, this.b=0.75}) {
    _counts = [];
    _lengths = [];
    for (final chunk in chunks) {
      final count = <String,int>{};
      for (final term in DiscText.terms(chunk.text)) { count[term] = (count[term] ?? 0) + 1; }
      _counts.add(count);
      _lengths.add(count.values.fold<int>(0, (a,v) => a + v));
      for (final key in count.keys) { _df[key] = (_df[key] ?? 0) + 1; }
    }
    _average = _lengths.isEmpty ? 1 : _lengths.reduce((a,b)=>a+b)/_lengths.length;
  }
  double idf(String term) => math.log(1 + (chunks.length - (_df[term] ?? 0) + 0.5) / ((_df[term] ?? 0) + 0.5));
  List<DiscSearchHit> search(List<String> query, {String? profileCode, int limit=5}) {
    final expanded = <String>{};
    for (final token in query) {
      for (final term in [token,...?synonyms[token]]) {
        final stem = DiscText.stem(term.toLowerCase());
        if (stem.length > 1 && !DiscText.stopwords.contains(stem)) expanded.add(stem);
      }
    }
    final matches = <DiscSearchHit>[];
    for (var i=0; i<chunks.length; i++) {
      if (profileCode != null && chunks[i].profileCode != profileCode) continue;
      var score=0.0, matched=0;
      for (final term in expanded) {
        final f = _counts[i][term];
        if (f == null) continue;
        matched++;
        score += idf(term) * (f*(k1+1)) / (f+k1*(1-b+b*_lengths[i]/_average));
      }
      if (score>0) matches.add(DiscSearchHit(chunks[i],score,matched));
    }
    matches.sort((a,b)=>b.score.compareTo(a.score));
    return matches.take(limit).toList();
  }
  static const synonyms = <String,List<String>>{
    'teamwork':['team','group','collaborative'], 'team':['group','collaborative'],
    'sales':['sales','business','customer','deal'], 'selling':['sales','customer'],
    'business':['enterprise','venture','business'], 'teacher':['teaching','training','pedagogical'],
    'teaching':['training','pedagogical'], 'doctor':['medical','clinical'],
    'medicine':['medical','clinical'], 'it':['systems','technical'],
    'software':['systems','technical','engineer'], 'computer':['systems','technical','database'],
    'engineering':['engineer','technical','systems'], 'data':['data','analytical','metrics'],
    'hr':['hr','employee'], 'marketing':['marketing','brand','promotion'],
    'lazy':['passive','slow'], 'angry':['blunt','critical','confrontation'],
    'criticism':['criticism','critique','critical'], 'change':['change','shifts','pivots'],
    'deadline':['deadline','deadlines','timelines'], 'deadlines':['deadline','timelines'],
    'speaker':['speaker','presentation','public'], 'public':['public','presentation','visibility'],
    'entrepreneur':['entrepreneur','venture','business'], 'startup':['venture','entrepreneur'],
    'accountant':['auditor','accounts','financial'], 'lawyer':['regulatory','compliance'],
    'law':['regulatory','compliance'], 'research':['research','researcher','scientist'],
    'army':['crisis','command'], 'police':['enforcement','command'],
  };
}
