import 'disc_chatbot.dart';
/// Loading facade equivalent to Android's DiscChatbotLoader.
class DiscChatbotLoader {
  static Future<DiscChatbot> fromAssets({String path='assets/disc/disc_knowledge.json'}) =>
      DiscChatbot.fromAssets(path: path);
}
