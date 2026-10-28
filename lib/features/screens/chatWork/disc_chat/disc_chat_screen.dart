import 'package:flutter/material.dart';
import 'disc_chatbot.dart';

class DiscChatScreen extends StatefulWidget {
  final String? profileCode;
  const DiscChatScreen({super.key, this.profileCode});

  @override
  State<DiscChatScreen> createState() => _DiscChatScreenState();
}

class _DiscChatScreenState extends State<DiscChatScreen> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scroll = ScrollController();
  final List<_ChatItem> _messages = [];
  DiscChatbot? _bot;
  BotReply? _lastReply;
  String? _error;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final bot = await DiscChatbot.fromAssets();
      bot.setUserProfile(widget.profileCode);
      final welcome = bot.welcome();
      if (!mounted) return;
      setState(() {
        _bot = bot;
        _lastReply = welcome;
        _messages.add(_ChatItem(welcome.text, false));
      });
    } catch (e) {
      if (mounted) setState(() => _error = 'Unable to load DISC knowledge: $e');
    }
  }

  void _send([String? text]) {
    final value = (text ?? _controller.text).trim();
    if (value.isEmpty || _bot == null || _busy) return;
    _controller.clear();
    setState(() {
      _busy = true;
      _messages.add(_ChatItem(value, true));
    });
    try {
      final reply = _bot!.ask(value);
      setState(() {
        _messages.add(_ChatItem(reply.text, false));
        _lastReply = reply;
      });
    } catch (e) {
      setState(() => _messages.add(_ChatItem('Could not process the message: $e', false)));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) _scroll.animateTo(_scroll.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
    });
  }

  @override
  void dispose() {
    _controller.dispose(); _scroll.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('DISC Personality Assistant'), actions: [
        IconButton(tooltip: 'Reset conversation', icon: const Icon(Icons.refresh),
          onPressed: _bot == null ? null : () {
            _bot!.resetConversation();
            final msg = _bot!.welcome();
            setState(() { _messages..clear()..add(_ChatItem(msg.text, false)); _lastReply = msg; });
          }),
      ]),
      body: SafeArea(child: Column(children: [
        if (_bot == null && _error == null) const LinearProgressIndicator(),
        if (_error != null) Padding(padding: const EdgeInsets.all(16), child: Text(_error!, style: TextStyle(color: scheme.error))),
        Expanded(child: ListView.builder(
          controller: _scroll,
          padding: const EdgeInsets.all(14),
          itemCount: _messages.length,
          itemBuilder: (context, i) {
            final msg = _messages[i];
            return Align(alignment: msg.fromUser ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .85),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 14),
                decoration: BoxDecoration(
                  color: msg.fromUser ? scheme.primaryContainer : scheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(16)),
                child: SelectableText(msg.text),
              ),
            );
          },
        )),
        if (_lastReply != null && _lastReply!.suggestions.isNotEmpty)
          SizedBox(height: 46, child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            children: _lastReply!.suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(right: 6),
              child: ActionChip(label: Text(s), onPressed: () => _send(s)),
            )).toList(),
          )),
        Padding(padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          child: Row(children: [
            Expanded(child: TextField(controller: _controller,
              enabled: _bot != null && !_busy,
              textInputAction: TextInputAction.send,
              onSubmitted: _send,
              minLines: 1, maxLines: 4,
              decoration: const InputDecoration(hintText: 'Ask about your DISC personality...', border: OutlineInputBorder()))),
            const SizedBox(width: 8),
            IconButton.filled(onPressed: _bot == null || _busy ? null : () => _send(), icon: const Icon(Icons.send)),
          ]),
        ),
      ])),
    );
  }
}

class _ChatItem {
  final String text;
  final bool fromUser;
  const _ChatItem(this.text, this.fromUser);
}
