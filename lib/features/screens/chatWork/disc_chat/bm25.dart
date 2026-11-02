import 'dart:math' as math;

class DiscChunk {
  final String profileCode;
  final String topic;
  final String? parameter;
  final String text;
  const DiscChunk(this.profileCode, this.topic, this.text, [this.parameter]);
}
class DiscHit {
  final DiscChunk chunk;
  final double score;
  final int matchedTerms;
  const DiscHit(this.chunk, this.score, this.matchedTerms);
}

class DiscText {
  static String normalize(String input) => input.toLowerCase()
      .replaceAll('&', ' and ').replaceAll('’', "'")
      .replaceAll(RegExp("'s "), ' ').replaceAll("'", '')
      .replaceAll(RegExp(r'[^a-z0-9%]+'), ' ').trim();
  static List<String> tokens(String text) => text.trim().isEmpty ? [] : text.trim().split(RegExp(r'\s+'));
  static String stem(String word) {
    if (word.length > 5 && word.endsWith('ies')) return '${word.substring(0,word.length-3)}y';
    for (final suffix in ['ing','ness','ment','ally','ity','ive','ed','ly','es','s']) {
      if (word.endsWith(suffix) && word.length-suffix.length>=4) return word.substring(0,word.length-suffix.length);
    }
    return word;
  }
  static const stopwords = <String>{
    'a','an','the','is','are','am','was','were','be','been','of','to','in','on','for','and','or','with',
    'what','which','who','whom','how','why','when','where','do','does','did','can','could','should',
    'would','will','shall','may','might','me','my','mine','i','you','your','we','our','they','them',
    'their','he','she','his','her','it','its','this','that','these','those','tell','about','please',
    'pls','plz','give','show','explain','describe','know','want','need','type','types','profile',
    'profiles','person','people','personality','style','combination','disc','some','any','all','more',
    'most','best','good','get','like','as','at','by','from','so','if','than','then','there','here',
    'also','just','very','much','many','kya','hai','hain','ka','ki','ke','ko','mujhe','mera',
    'meri','mere','batao','bataiye','aur','kaise','kaun','someone','somebody','us','im','has',
    'have','having','got','gets','make','makes','one','ones','kind','sort','really','usually',
    'generally','typically','not','no','yes','into','out','up','down','over','under','per','each',
    'every','other','own','same','such','only','both','either','neither','being','become','becomes',
    'thing','things','something','anything','everything','way','ways','let','lets','say','says',
    'okay','ok','now','today','s','t','d','c','wants','wanted'
  };
  static List<String> terms(String text) => tokens(normalize(text))
      .where((t)=>t.length>1 && !stopwords.contains(t)).map(stem).toList();
  static int levenshtein(String a,String b,int max) {
    if ((a.length-b.length).abs()>max) return max+1;
    var previous=List<int>.generate(b.length+1,(i)=>i);
    var current=List<int>.filled(b.length+1,0);
    for(var i=1;i<=a.length;i++) {
      current[0]=i;var rowMin=i;
      for(var j=1;j<=b.length;j++) {
        final cost=a[i-1]==b[j-1]?0:1;
        current[j]=math.min(math.min(previous[j]+1,current[j-1]+1),previous[j-1]+cost);
        if(i>1&&j>1&&a[i-1]==b[j-2]&&a[i-2]==b[j-1]) current[j]=math.min(current[j],previous[j-1]);
        rowMin=math.min(rowMin,current[j]);
      }
      if(rowMin>max) return max+1;
      final temp=previous;previous=current;current=temp;
    }
    return previous[b.length];
  }
}

class DiscBm25 {
  final List<DiscChunk> chunks;
  final double k1,b;
  final List<Map<String,int>> _freq=[];
  final List<int> _length=[];
  final Map<String,int> _df={};
  late final double _average;
  DiscBm25(this.chunks,{this.k1=1.2,this.b=0.75}) {
    for(final c in chunks) {
      final tf=<String,int>{};
      for(final term in DiscText.terms(c.text)) tf[term]=(tf[term]??0)+1;
      _freq.add(tf);_length.add(tf.values.fold<int>(0,(a,v)=>a+v));
      for(final term in tf.keys) _df[term]=(_df[term]??0)+1;
    }
    _average=_length.isEmpty?1:_length.reduce((a,b)=>a+b)/_length.length;
  }
  double idf(String t) {final n=_df[t]??0;return math.log(1+(chunks.length-n+0.5)/(n+0.5));}
  List<DiscHit> search(List<String> query,{String? profileCode,int limit=5}) {
    final terms=query.expand((t)=>[t,...(synonyms[t]??<String>[])]).map(DiscText.stem)
        .where((t)=>t.length>1&&!DiscText.stopwords.contains(t)).toSet();
    final out=<DiscHit>[];
    for(var i=0;i<chunks.length;i++) {
      if(profileCode!=null&&chunks[i].profileCode!=profileCode)continue;
      double score=0;var matches=0;
      for(final t in terms){final f=_freq[i][t];if(f==null)continue;matches++;
        score+=idf(t)*(f*(k1+1))/(f+k1*(1-b+b*_length[i]/_average));}
      if(score>0)out.add(DiscHit(chunks[i],score,matches));
    }
    out.sort((a,b)=>b.score.compareTo(a.score));
    return out.take(limit).toList();
  }
  static const synonyms=<String,List<String>>{
    'teamwork':['team','group','collaborative'],'team':['group','collaborative'],
    'sales':['sales','business','customer','deal'],'selling':['sales','customer'],
    'business':['enterprise','venture','business'],'teacher':['teaching','training','pedagogical'],
    'teaching':['training','pedagogical'],'doctor':['medical','clinical'],
    'medicine':['medical','clinical'],'it':['systems','technical'],
    'software':['systems','technical','engineer'],'computer':['systems','technical','database'],
    'engineering':['engineer','technical','systems'],'data':['data','analytical','metrics'],
    'hr':['hr','employee'],'marketing':['marketing','brand','promotion'],
    'lazy':['passive','slow'],'angry':['blunt','critical','confrontation'],
    'criticism':['criticism','critique','critical'],'change':['change','shifts','pivots'],
    'deadline':['deadline','deadlines','timelines'],'deadlines':['deadline','timelines'],
    'speaker':['speaker','presentation','public'],'public':['public','presentation','visibility'],
    'entrepreneur':['entrepreneur','venture','business'],'startup':['venture','entrepreneur'],
    'accountant':['auditor','accounts','financial'],'lawyer':['regulatory','compliance'],
    'law':['regulatory','compliance'],'research':['research','researcher','scientist'],
    'army':['crisis','command'],'police':['enforcement','command']
  };
}
