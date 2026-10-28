/// Dart mirrors of the Kotlin models. Field names match the JSON produced by
/// `ScanResultStore.kt`.

enum ScanMode {
  group('group', 'Full Hand / 4-Fingers'),
  individual('individual', 'Single Fingertip');

  const ScanMode(this.channelValue, this.title);

  /// Value sent over the MethodChannel (read by `ScanActivity.parseMode`).
  final String channelValue;
  final String title;
}

class ScanStepInfo {
  const ScanStepInfo({
    required this.name,
    required this.handSide,
    required this.fingerName,
    required this.title,
    required this.description,
    required this.fingerCount,
  });

  /// Kotlin enum name, e.g. `RIGHT_THUMB_IND`. Use it to (re)scan one finger.
  final String name;
  final String handSide; // RIGHT | LEFT
  final String fingerName;
  final String title;
  final String description;
  final int fingerCount;

  factory ScanStepInfo.fromMap(Map<dynamic, dynamic> m) => ScanStepInfo(
        name: m['name'] as String,
        handSide: m['handSide'] as String,
        fingerName: m['fingerName'] as String,
        title: m['title'] as String,
        description: m['description'] as String,
        fingerCount: (m['fingerCount'] as num).toInt(),
      );
}

class PatternScore {
  const PatternScore(this.label, this.score);
  final String label;
  final double score; // 0..100

  factory PatternScore.fromJson(Map<String, dynamic> j) =>
      PatternScore(j['label'] as String, (j['score'] as num).toDouble());
}

class ScanResult {
  const ScanResult({
    required this.step,
    required this.handSide,
    required this.fingerName,
    required this.fingerCount,
    required this.pattern,
    required this.description,
    required this.confidence,
    required this.topPredictions,
    required this.clarity,
    required this.contrastBoost,
    required this.resolution,
    required this.originalPath,
    required this.enhancedPath,
  });

  final String step;
  final String handSide;
  final String fingerName;
  final int fingerCount;
  final String pattern;
  final String description;
  final double confidence; // percent
  final List<PatternScore> topPredictions;
  final int clarity; // percent
  final int contrastBoost;
  final String resolution;
  final String originalPath;
  final String enhancedPath;

  factory ScanResult.fromJson(Map<String, dynamic> j) => ScanResult(
        step: j['step'] as String,
        handSide: j['handSide'] as String,
        fingerName: j['fingerName'] as String,
        fingerCount: (j['fingerCount'] as num).toInt(),
        pattern: j['pattern'] as String,
        description: j['description'] as String,
        confidence: (j['confidence'] as num).toDouble(),
        topPredictions: (j['topPredictions'] as List)
            .map((e) => PatternScore.fromJson(Map<String, dynamic>.from(e as Map)))
            .toList(),
        clarity: (j['clarity'] as num).toInt(),
        contrastBoost: (j['contrastBoost'] as num).toInt(),
        resolution: j['resolution'] as String,
        originalPath: j['originalPath'] as String,
        enhancedPath: j['enhancedPath'] as String,
      );
}
