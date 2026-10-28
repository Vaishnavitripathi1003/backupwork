/*
import 'package:flutter/material.dart';
import 'DiscChatCore.dart';
import 'DiscChatModel.dart';

class DiscChatPage extends StatefulWidget {
  const DiscChatPage({super.key, this.userProfile});
  final String? userProfile; // e.g. "DI" from your DISC test, or null

  @override
  State<DiscChatPage> createState() => _DiscChatPageState();
}

class _DiscChatPageState extends State<DiscChatPage> {
  DiscChatModel? _bot;
  final _controller = TextEditingController();
  final List<({bool me, String text})> _messages = [];
  List<String> _suggestions = [];

  @override
  void initState() {
    super.initState();
    DiscChatModel.load().then((bot) {
      bot.setUserProfile(widget.userProfile);
      final hello = bot.welcome();
      setState(() {
        _bot = bot;
        _messages.add((me: false, text: hello.text));
        _suggestions = hello.suggestions;
      });
    });
  }

  void _send(String text) {
    if (_bot == null || text.trim().isEmpty) return;
    final reply = _bot!.ask(text);
    setState(() {
      _messages.add((me: true, text: text));
      _messages.add((me: false, text: reply.text));
      _suggestions = reply.suggestions;
    });
    _controller.clear();
  }

  @override
  void dispose() {
    _bot?.close();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bot == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    return Scaffold(
      appBar: AppBar(title: const Text('DISC Assistant')),
      body: Column(children: [
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length,
            itemBuilder: (_, i) {
              final m = _messages[i];
              return Align(
                alignment: m.me ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  padding: const EdgeInsets.all(10),
                  constraints: const BoxConstraints(maxWidth: 320),
                  decoration: BoxDecoration(
                    color: m.me ? Colors.blue.shade100 : Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(m.text),
                ),
              );
            },
          ),
        ),
        if (_suggestions.isNotEmpty)
          SizedBox(
            height: 44,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              children: [
                for (final s in _suggestions)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ActionChip(label: Text(s), onPressed: () => _send(s)),
                  ),
              ],
            ),
          ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Row(children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  onSubmitted: _send,
                  decoration: const InputDecoration(
                      hintText: 'Ask about DISC…', border: OutlineInputBorder()),
                ),
              ),
              IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _send(_controller.text)),
            ]),
          ),
        ),
      ]),
    );
  }
}
*/
