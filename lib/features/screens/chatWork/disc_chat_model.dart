import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

import 'disc_chat_brain.dart';
import 'disc_tokenizer.dart';

export 'disc_chat_brain.dart' show DiscReply;

/// DISC chatbot powered by the trained TFLite model.
///
/// ```dart
/// final bot = await DiscChatModel.load();
/// bot.setUserProfile('DI');                 // optional: the user's DISC test result
/// final reply = bot.ask('What are my strengths?');
/// print(reply.text);
/// bot.close();
/// ```
class DiscChatModel {
  DiscChatModel._(this._interpreter, this._tokenizer, this._brain, this._profileOut, this._intentOut);

  static const String modelAsset = 'assets/chatmodels/disc_model.tflite';
  static const String dataAsset = 'assets/chatmodels/disc_model_data.json';

  final Interpreter _interpreter;
  final DiscTokenizer _tokenizer;
  final DiscChatBrain _brain;
  final int _profileOut;
  final int _intentOut;

  /// Loads the model and its data from the app's assets (takes well under a second).
  static Future<DiscChatModel> load({String model = modelAsset, String data = dataAsset}) async {
    final interpreter = await Interpreter.fromAsset(model);
    final json = jsonDecode(await rootBundle.loadString(data)) as Map<String, dynamic>;

    final vocab = List<String>.from(json['vocab'] as List);
    final profileLabels = List<String>.from(json['profile_labels'] as List);
    final intentLabels = List<String>.from(json['intent_labels'] as List);
    final answers = Map<String, String>.from(json['answers'] as Map);
    final profiles = (json['profiles'] as List)
        .cast<Map<String, dynamic>>()
        .map((p) => DiscProfileInfo(p['code'] as String, p['slash'] as String, p['label'] as String, p['archetype'] as String))
        .toList();

    // The two outputs can come in either order; identify them by size.
    final size0 = interpreter.getOutputTensor(0).shape.last;
    final profileOut = size0 == profileLabels.length ? 0 : 1;

    return DiscChatModel._(
      interpreter,
      DiscTokenizer(vocab, json['max_len'] as int),
      DiscChatBrain(profileLabels, intentLabels, answers, profiles),
      profileOut,
      1 - profileOut,
    );
  }

  /// The user's own DISC result ("DI", "D/I"), or null to clear.
  void setUserProfile(String? code) => _brain.setUserProfile(code);

  String? get userProfile => _brain.userProfile;

  DiscReply welcome() => _brain.welcome();

  void resetConversation() => _brain.reset();

  /// Answers one message (about 1 ms).
  DiscReply ask(String message) {
    final none = _brain.profileLabels.indexOf('NONE');
    if (message.trim().isEmpty) {
      return _brain.reply('help', none, _brain.intentLabels.indexOf('help'), 1);
    }
    final ids = _tokenizer.encode(message);
    // Not a single known word (gibberish / another language) → off-topic
    if (!ids.any((id) => id > 1)) {
      return _brain.reply(message, none, _brain.intentLabels.indexOf('out_of_scope'), 1);
    }
    final p = _run(ids);
    return _brain.reply(message, p.profileIndex, p.intentIndex, p.intentConfidence);
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
    final pi = _argMax(profileProbs[0]);
    final ii = _argMax(intentProbs[0]);
    return DiscPrediction(
      _brain.profileLabels[pi], pi, profileProbs[0][pi],
      _brain.intentLabels[ii], ii, intentProbs[0][ii],
    );
  }

  static int _argMax(List<double> v) {
    var best = 0;
    for (var i = 1; i < v.length; i++) {
      if (v[i] > v[best]) best = i;
    }
    return best;
  }

  void close() => _interpreter.close();
}

class DiscPrediction {
  const DiscPrediction(this.profile, this.profileIndex, this.profileConfidence, this.intent, this.intentIndex,
      this.intentConfidence);
  final String profile;
  final int profileIndex;
  final double profileConfidence;
  final String intent;
  final int intentIndex;
  final double intentConfidence;
}
