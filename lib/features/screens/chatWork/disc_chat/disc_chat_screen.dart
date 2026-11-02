import 'package:flutter/material.dart';

import 'disc_chatbot_flutter.dart';

class DiscChatScreen extends StatefulWidget {
  final String? profileCode;
  final bool hindiWelcome;
  const DiscChatScreen({super.key, this.profileCode, this.hindiWelcome = false});

  @override
  State<DiscChatScreen> createState() => _DiscChatScreenState();
}

class _ChatMessage {
  final bool isUser;
  final String text;
  const _ChatMessage(this.isUser, this.text);
}

class _DiscChatScreenState extends State<DiscChatScreen> {
  final _bot = DiscChatbot();
  final _input = TextEditingController();
  final _scroll = ScrollController();
  final _messages = <_ChatMessage>[];
  List<String> _suggestions = [];
  bool _loading = true;
  bool _typing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      final hello = await _bot.initialize(
        profileCode: widget.profileCode, hindi: widget.hindiWelcome);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(false, hello.text));
        _suggestions = hello.suggestions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  void didUpdateWidget(covariant DiscChatScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.profileCode != widget.profileCode) {
      _bot.setUserProfile(widget.profileCode);
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 220), curve: Curves.easeOut);
      }
    });
  }

  Future<void> _send([String? suggested]) async {
    if (_typing || _loading) return;
    final text = (suggested ?? _input.text).trim();
    if (text.isEmpty) return;
    _input.clear();
    setState(() {
      _messages.add(_ChatMessage(true, text));
      _suggestions = [];
      _typing = true;
    });
    _scrollToBottom();
    try {
      final reply = await _bot.ask(text);
      if (!mounted) return;
      setState(() {
        _messages.add(_ChatMessage(false, reply.text));
        _suggestions = reply.suggestions;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _messages.add(_ChatMessage(false, 'Chat error: $e')); });
    } finally {
      if (mounted) setState(() => _typing = false);
      _scrollToBottom();
    }
  }

  @override
  void dispose() {
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('DISC Assistant')),
      body: SafeArea(
        child: Column(children: [
          if (_loading) const LinearProgressIndicator(),
          if (_error != null) Padding(padding: const EdgeInsets.all(16),
            child: Text(_error!, style: TextStyle(color: theme.colorScheme.error))),
          Expanded(child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(12),
            itemCount: _messages.length + (_typing ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _messages.length) {
                return const Align(alignment: Alignment.centerLeft,
                  child: Padding(padding: EdgeInsets.all(12), child: Text('typing…')));
              }
              final item = _messages[index];
              return Align(
                alignment: item.isUser ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * .84),
                  margin: const EdgeInsets.symmetric(vertical: 5),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: item.isUser ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: SelectableText(item.text),
                ),
              );
            },
          )),
          if (_suggestions.isNotEmpty)
            SizedBox(height: 46, child: ListView.separated(
              scrollDirection: Axis.horizontal, padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: _suggestions.length, separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ActionChip(
                label: Text(_suggestions[index]),
                onPressed: _typing ? null : () => _send(_suggestions[index]),
              ),
            )),
          Padding(padding: const EdgeInsets.all(12), child: Row(children: [
            Expanded(child: TextField(
              controller: _input, enabled: !_loading && _error == null,
              minLines: 1, maxLines: 4,
              decoration: const InputDecoration(hintText: 'Ask about your DISC profile…',
                border: OutlineInputBorder()),
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
            )),
            IconButton(onPressed: _typing || _loading || _error != null ? null : () => _send(),
              icon: const Icon(Icons.send)),
          ])),
        ]),
      ),
    );
  }
}
