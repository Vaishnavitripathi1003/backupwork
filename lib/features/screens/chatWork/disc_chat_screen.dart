import 'package:flutter/material.dart';
import 'disc_chat_model.dart';

class DiscChatScreen extends StatefulWidget {

  const DiscChatScreen({super.key, this.userProfile, this.title = 'DISC Assistant',this.primary,this.secondary});

  final String? userProfile;
  final String title;

  final String?  primary;

  final String?  secondary;

  @override
  State<DiscChatScreen> createState() => _DiscChatScreenState();
}

class _ChatMessage {
  const _ChatMessage(this.text, {required this.fromUser});
  final String text;
  final bool fromUser;
}

class _DiscChatScreenState extends State<DiscChatScreen> {
  final _messages = <_ChatMessage>[];
  final _input = TextEditingController();
  final _scroll = ScrollController();
  DiscChatModel? _bot;
  List<String> _suggestions = const [];
  bool _typing = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      final bot = await DiscChatModel.load();
      bot.setUserProfile(widget.userProfile);
      final hello = bot.welcome();
      if (!mounted) {
        bot.close();
        return;
      }
      setState(() {
        _bot = bot;
        _messages.add(_ChatMessage(hello.text, fromUser: false));
        _suggestions = hello.suggestions;
      });
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not load the chat model: $e');
    }
  }

  Future<void> _send(String text) async {
    final q = text.trim();
    final bot = _bot;
    if (q.isEmpty || bot == null || _typing) return;
    _input.clear();
    setState(() {
      _messages.add(_ChatMessage(q, fromUser: true));
      _suggestions = const [];
      _typing = true;
    });
    _scrollToEnd();
    final reply = bot.ask(q);
    await Future<void>.delayed(const Duration(milliseconds: 300)); // small "typing…" pause
    if (!mounted) return;
    setState(() {
      _typing = false;
      _messages.add(_ChatMessage(reply.text, fromUser: false));
      _suggestions = reply.suggestions;
    });
    _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(_scroll.position.maxScrollExtent,
            duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      }
    });
  }

  @override
  void dispose() {
    _bot?.close();
    _input.dispose();
    _scroll.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: _error != null
                  ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)))
                  : _bot == null
                      ? const Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          controller: _scroll,
                          padding: const EdgeInsets.all(12),
                          itemCount: _messages.length + (_typing ? 1 : 0),
                          itemBuilder: (context, i) {
                            final m = i < _messages.length ? _messages[i] : const _ChatMessage('typing…', fromUser: false);
                            return _Bubble(message: m, scheme: scheme);
                          },
                        ),
            ),
            if (_suggestions.isNotEmpty)
              SizedBox(
                height: 48,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  itemCount: _suggestions.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemBuilder: (_, i) => ActionChip(
                    label: Text(_suggestions[i]),
                    onPressed: () => _send(_suggestions[i]),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _input,
                      minLines: 1,
                      maxLines: 4,
                      textInputAction: TextInputAction.send,
                      onSubmitted: _send,
                      decoration: const InputDecoration(
                        hintText: 'Ask about your DISC profile…',
                        border: OutlineInputBorder(),
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    icon: const Icon(Icons.send),
                    onPressed: _bot == null ? null : () => _send(_input.text),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  const _Bubble({required this.message, required this.scheme});
  final _ChatMessage message;
  final ColorScheme scheme;

  @override
  Widget build(BuildContext context) {
    final user = message.fromUser;
    return Align(
      alignment: user ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.82),
        decoration: BoxDecoration(
          color: user ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(user ? 16 : 4),
            bottomRight: Radius.circular(user ? 4 : 16),
          ),
        ),
        child: SelectableText(message.text),
      ),
    );
  }
}
