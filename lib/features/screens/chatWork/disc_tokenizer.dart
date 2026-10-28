/// Turns a question into token ids for the DISC model.
/// Must match the Python training code exactly (same steps, same order).
class DiscTokenizer {
  DiscTokenizer(this.vocab, this.maxLen)
      : _index = {for (var i = 0; i < vocab.length; i++) vocab[i]: i},
        _fuzzy = vocab
            .skip(2)
            .where((w) => w.length >= 5 && !w.startsWith('code_'))
            .toList(growable: false);

  final List<String> vocab;
  final int maxLen;
  final Map<String, int> _index;
  final List<String> _fuzzy;
  final Map<String, int> _cache = {};

  static const Set<String> _notCodeAfter = {
    'student', 'students', 'engineering', 'engineer', 'branch', 'degree', 'course', 'major',
    'department', 'dept', 'graduate', 'field', 'category', 'caste', 'st', 'obc', 'batch',
    'subject', 'exam', 'paper', 'lab', 'class', 'semester', 'sem', 'year',
  };
  static final RegExp _bare = RegExp(r'(?<![A-Za-z])([DISC]{2})(?![A-Za-z])');
  static final RegExp _nextWord = RegExp(r'^\s+([A-Za-z]+)\b');
  static final RegExp _slash = RegExp(r'(?<![a-z])([disc])\s*[/\\\-–—&+|]\s*([disc])(?![a-z])');
  static final RegExp _non = RegExp(r'[^a-z0-9_%]+');

  List<String> normalize(String text) {
    // "DI", "SC" written in capitals → code tokens (but not "CS student", "SC category" …)
    var t = text.replaceAllMapped(_bare, (m) {
      final next = _nextWord.firstMatch(text.substring(m.end));
      if (next != null && _notCodeAfter.contains(next.group(1)!.toLowerCase())) {
        return m.group(0)!;
      }
      return ' code_${m.group(1)!.toLowerCase()} ';
    });
    t = t.toLowerCase().replaceAll('’', "'").replaceAll("'", '');
    t = t.replaceAllMapped(_slash, (m) => ' code_${m.group(1)}${m.group(2)} ');
    t = t.replaceAll('&', ' and ');
    t = t.replaceAll(_non, ' ').trim();
    return t.isEmpty ? <String>[] : t.split(' ');
  }

  List<int> encode(String text) {
    final out = List<int>.filled(maxLen, 0); // 0 = padding
    final toks = normalize(text);
    for (var i = 0; i < toks.length && i < maxLen; i++) {
      out[i] = _tokenId(toks[i]);
    }
    return out;
  }

  int _tokenId(String tok) {
    final known = _index[tok];
    if (known != null) return known;
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
        var v = prev[j] + 1;
        if (cur[j - 1] + 1 < v) v = cur[j - 1] + 1;
        if (prev[j - 1] + cost < v) v = prev[j - 1] + cost;
        if (i > 1 && j > 1 && a[i - 1] == b[j - 2] && a[i - 2] == b[j - 1]) {
          if (prev2[j - 2] + 1 < v) v = prev2[j - 2] + 1;
        }
        cur[j] = v;
      }
      prev2 = prev;
      prev = cur;
    }
    return prev[b.length];
  }
}
