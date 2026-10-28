/*
                              // in dispose()

import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'DiscChatCore.dart';

class DiscPrediction {
  const DiscPrediction(this.profile, this.profileIndex, this.profileConfidence,
      this.intent, this.intentIndex, this.intentConfidence);
  final String profile;
  final int profileIndex;
  final double profileConfidence;
  final String intent;
  final int intentIndex;
  final double intentConfidence;
}

// ---------------------------------------------------------------------------
// Model wrapper: loads the .tflite + JSON data and answers questions
// ---------------------------------------------------------------------------

class DiscChatModel {
  DiscChatModel._(this._interpreter, this._tokenizer, this._brain,
      this._profileOut, this._intentOut);

  static const modelAsset = 'assets/disc_model.tflite';
  static const dataAsset = 'assets/disc_model_data.json';

  final Interpreter _interpreter;
  final DiscTokenizer _tokenizer;
  final DiscChatBrain _brain;
  final int _profileOut;
  final int _intentOut;

  /// Create once (e.g. in initState or a provider).
  static Future<DiscChatModel> load() async {
    final interpreter = await Interpreter.fromAsset(modelAsset);

    final json =
    jsonDecode(await rootBundle.loadString(dataAsset)) as Map<String, dynamic>;
    final vocab = (json['vocab'] as List).cast<String>();
    final profileLabels = (json['profile_labels'] as List).cast<String>();
    final intentLabels = (json['intent_labels'] as List).cast<String>();
    final answers = (json['answers'] as Map<String, dynamic>)
        .map((k, v) => MapEntry(k, v as String));
    final profiles = (json['profiles'] as List)
        .map((p) => DiscProfileInfo(p['code'] as String, p['slash'] as String,
        p['label'] as String, p['archetype'] as String))
        .toList();

    final tokenizer = DiscTokenizer(vocab, json['max_len'] as int);
    final brain = DiscChatBrain(profileLabels, intentLabels, answers, profiles);

    // The two outputs can come in either order; identify them by size.
    final size0 = interpreter.getOutputTensors()[0].shape.last;
    final profileOut = size0 == profileLabels.length ? 0 : 1;
    return DiscChatModel._(
        interpreter, tokenizer, brain, profileOut, 1 - profileOut);
  }

  /// The user's own DISC result ("DI", "D/I"), or null to clear.
  void setUserProfile(String? code) => _brain.setUserProfile(code);

  String? get userProfile => _brain.userProfile;

  DiscReply welcome() => _brain.welcome();

  void resetConversation() => _brain.reset();

  /// Answers one message (~1 ms).
  DiscReply ask(String message) {
    final none = _brain.profileLabels.indexOf('NONE');
    if (message.trim().isEmpty) {
      return _brain.reply('help', none, _brain.intentLabels.indexOf('help'), 1);
    }
    final ids = _tokenizer.encode(message);
    // Not a single known word (gibberish / another language) -> off-topic
    if (ids.every((i) => i <= 1)) {
      return _brain.reply(
          message, none, _brain.intentLabels.indexOf('out_of_scope'), 1);
    }
    final p = _run(ids);
    return _brain.reply(
        message, p.profileIndex, p.intentIndex, p.intentConfidence);
  }

  /// Raw model output, if you want to build your own replies.
  DiscPrediction predict(String message) => _run(_tokenizer.encode(message));

  DiscPrediction _run(List<int> ids) {
    final profileProbs = [List<double>.filled(_brain.profileLabels.length, 0)];
    final intentProbs = [List<double>.filled(_brain.intentLabels.length, 0)];
    _interpreter.runForMultipleInputs([
      [ids]
    ], {
      _profileOut: profileProbs,
      _intentOut: intentProbs,
    });
    final pp = profileProbs[0];
    final ip = intentProbs[0];
    var pi = 0, ii = 0;
    for (var i = 1; i < pp.length; i++) {
      if (pp[i] > pp[pi]) pi = i;
    }
    for (var i = 1; i < ip.length; i++) {
      if (ip[i] > ip[ii]) ii = i;
    }
    return DiscPrediction(_brain.profileLabels[pi], pi, pp[pi],
        _brain.intentLabels[ii], ii, ip[ii]);
  }

  void close() => _interpreter.close();
}*/
