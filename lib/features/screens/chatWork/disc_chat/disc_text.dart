/// Text normalization and light stemming ported from the Android DISC engine.
class DiscText {
  static String normalize(String value) => value.toLowerCase()
      .replaceAll('&', ' and ').replaceAll('’', "'")
      .replaceAll(RegExp("'s "), ' ').replaceAll("'", '')
      .replaceAll(RegExp(r'[^a-z0-9%]+'), ' ').trim();
  static List<String> tokens(String value) => normalize(value).isEmpty
      ? [] : normalize(value).split(RegExp(r'\s+'));
  static String stem(String word) {
    if (word.length > 5 && word.endsWith('ies')) return '${word.substring(0, word.length - 3)}y';
    for (final suffix in ['ing','ness','ment','ally','ity','ive','ed','ly','es','s']) {
      if (word.endsWith(suffix) && word.length - suffix.length >= 4) {
        return word.substring(0, word.length - suffix.length);
      }
    }
    return word;
  }
  static const stopwords = <String>{'a','an','the','is','are','am','was','were','be','been','of','to','in','on','for','and','or','with','what','which','who','whom','how','why','when','where','do','does','did','can','could','should','would','will','shall','may','might','me','my','mine','i','you','your','we','our','they','them','their','he','she','his','her','it','its','this','that','these','those','tell','about','please','pls','plz','give','show','explain','describe','know','want','need','type','types','profile','profiles','person','people','personality','style','combination','disc','some','any','all','more','most','best','good','get','like','as','at','by','from','so','if','than','then','there','here','also','just','very','much','many','kya','hai','hain','ka','ki','ke','ko','mujhe','mera','meri','mere','batao','bataiye','aur','kaise','kaun','someone','somebody','us','im','has','have','having','got','gets','make','makes','one','ones','kind','sort','really','usually','generally','typically','not','no','yes','into','out','up','down','over','under','per','each','every','other','own','same','such','only','both','either','neither','being','become','becomes','thing','things','something','anything','everything','way','ways','let','lets','say','says','okay','ok','now','today','s','t','d','c','wants','wanted'};
  static List<String> terms(String value) => tokens(value).where((e) => e.length > 1 && !stopwords.contains(e)).map(stem).toList();
}
