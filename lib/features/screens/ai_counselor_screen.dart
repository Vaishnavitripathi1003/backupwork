import 'package:flutter/material.dart';
import '../../core/models/intelligence_models.dart';
import '../../core/services/daksh_chat_service.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/responsive.dart';

class AICounselorScreen extends StatefulWidget {
  final StudentProfile profile;
  final String? initialPrompt;

  const AICounselorScreen({
    super.key,
    required this.profile,
    this.initialPrompt,
  });

  @override
  State<AICounselorScreen> createState() => _AICounselorScreenState();
}

class _AICounselorScreenState extends State<AICounselorScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isLoading = false;
  int _basicQueriesLeft = 3;
  final DakshChatService _dakshService = DakshChatService();

  @override
  void initState() {
    super.initState();
    _dakshService.initialize();

    // Initial Welcome Message from screenshot
    _messages.add({
      'role': 'assistant',
      'text':
      'Hello ${widget.profile.name}! 🖐️ I am your DAKSH report assistant. Please provide your Primary and Secondary DISC styles to receive personalized report answers.\n\n💡 In Free Tier, I can answer your basic orientation questions. After basic questions, you will be invited to connect directly with our Certified Live Human Counselor for in-depth guidance. How can I assist you right now?',
      'time': '9:41 AM',
    });

    if (widget.initialPrompt != null && widget.initialPrompt!.isNotEmpty) {
      _controller.text = widget.initialPrompt!;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _sendMessage([String? overrideText]) async {
    final text = (overrideText ?? _controller.text).trim();
    if (_isLoading) return;
    if (text.isEmpty) return;

    if (_basicQueriesLeft <= 0) {
      _showUpgradeModal();
      return;
    }

    final String currentTime = TimeOfDay.now().format(context);

    setState(() {
      _messages.add({
        'role': 'user',
        'text': text,
        'time': currentTime,
      });
      _isLoading = true;
      _controller.clear();
    });

    String answer;
    try {
      answer = await _dakshService.ask(text);
    } catch (e) {
      answer = 'Unable to load the local DAKSH report: $e';
    }
    if (!mounted) return;
    setState(() {
      _messages.add({
        'role': 'assistant',
        'text': answer,
        'time': TimeOfDay.now().format(context),
      });
      // Charge only for successful report questions, not profile setup.
      if (!answer.startsWith('Please provide your DISC') &&
          !answer.startsWith('Hello! Please enter') &&
          !answer.startsWith('Unable to load')) {
        _basicQueriesLeft = (_basicQueriesLeft - 1).clamp(0, 3);
      }
      _isLoading = false;
    });
  }

  void _showUpgradeModal() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('👑', style: TextStyle(fontSize: 40)),
            const SizedBox(height: 12),
            const Text(
              'Basic AI Queries Exhausted',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Connect directly with our Certified Live Human Counselor or upgrade to Premium for unlimited AI guidance.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4F46E5),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text('Connect with Live Counselor 🧘', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isNarrow = context.isNarrowMobile;

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            // 1. Top Header Bar (Dark Indigo Gradient)
            _buildTopHeader(context, isNarrow),

            // 2. Sub-Header Banner (Free Basic AI Orientation)
            _buildSubHeaderBanner(context, isNarrow),

            // 3. Chat Messages Area
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final msg in _messages) ...[
                      _buildMessageBubble(msg),
                      const SizedBox(height: 14),
                    ],
                    if (_isLoading)
                      const Padding(
                        padding: EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            SizedBox(
                              width: 14,
                              height: 14,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Color(0xFF4F46E5),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Vayo is formulating guidance...',
                              style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // 4. Prompt Chips Row
            _buildPromptChipsRow(context),

            // 5. Message Input Bar
            _buildInputBar(context, isNarrow),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context, bool isNarrow) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isNarrow ? 12 : 16,
        vertical: 12,
      ),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF1E1B4B), // Dark Indigo 950
            Color(0xFF312E81), // Indigo 900
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ),
      ),
      child: Row(
        children: [
          // Vayo Robot Icon Box
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 26,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 3.5,
                        height: 3.5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22D3EE),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Container(
                        width: 3.5,
                        height: 3.5,
                        decoration: const BoxDecoration(
                          color: Color(0xFF22D3EE),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6366F1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'VAYO',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 7,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 10),

          // Title & Status
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Text(
                      'Vayo • Student AI',
                      style: TextStyle(
                        fontSize: context.scaleFont(15),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF06B6D4), // Cyan dot
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 1),
                Text(
                  'Active Counselor for ${widget.profile.name} (${widget.profile.role})',
                  style: TextStyle(
                    fontSize: context.scaleFont(10.5),
                    color: const Color(0xFFC7D2FE),
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 6),

          // Live Counselor Pill Button
          InkWell(
            onTap: _showUpgradeModal,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Text('🧘', style: TextStyle(fontSize: 12)),
                  SizedBox(width: 4),
                  Text(
                    'Live\nCounselor',
                    style: TextStyle(
                      fontSize: 9.5,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF22D3EE),
                      height: 1.1,
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Close Button
          InkWell(
            onTap: () => Navigator.of(context).pop(),
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: Colors.white, size: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeaderBanner(BuildContext context, bool isNarrow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFFEEF2FF),
        border: Border(bottom: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              const Icon(Icons.auto_awesome, size: 14, color: Color(0xFF6366F1)),
              const SizedBox(width: 6),
              Text(
                'Free Basic AI Orientation',
                style: TextStyle(
                  fontSize: context.scaleFont(12),
                  fontWeight: FontWeight.bold,
                  color: const Color(0xFF4338CA),
                ),
              ),
            ],
          ),

          // Basic Qs pill badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFC7D2FE)),
            ),
            child: Text.rich(
              TextSpan(
                children: [
                  const TextSpan(
                    text: 'Basic Qs: ',
                    style: TextStyle(color: Color(0xFF6366F1)),
                  ),
                  TextSpan(
                    text: '$_basicQueriesLeft/3 left',
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF312E81)),
                  ),
                ],
              ),
              style: const TextStyle(fontSize: 11),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(Map<String, String> msg) {
    final isUser = msg['role'] == 'user';
    final text = msg['text'] ?? '';
    final time = msg['time'] ?? '9:41 AM';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Container(
            constraints: BoxConstraints(maxWidth: MediaQuery.sizeOf(context).width * 0.82),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isUser ? const Color(0xFF4F46E5) : Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(20),
                topRight: const Radius.circular(20),
                bottomLeft: Radius.circular(isUser ? 20 : 4),
                bottomRight: Radius.circular(isUser ? 4 : 20),
              ),
              border: isUser ? null : Border.all(color: const Color(0xFFE2E8F0)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Text(
              text,
              style: TextStyle(
                color: isUser ? Colors.white : const Color(0xFF334155),
                fontSize: 13.5,
                height: 1.45,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Text(
              time,
              style: const TextStyle(fontSize: 10, color: Color(0xFF94A3B8)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromptChipsRow(BuildContext context) {
    final prompts = [
      {'icon': '🎯', 'label': 'Best Career'},
      {'icon': '⭐', 'label': 'My Strengths'},
      {'icon': '📈', 'label': 'How can I improve?'},
      {'icon': '📋', 'label': 'Detailed SWOT'},
    ];

    return Container(
      height: 42,
      padding: const EdgeInsets.symmetric(vertical: 4),
      color: AppTheme.background,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        itemCount: prompts.length,
        itemBuilder: (context, index) {
          final p = prompts[index];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () => _sendMessage('${p['icon']} ${p['label']}'),
              borderRadius: BorderRadius.circular(20),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFC7D2FE)),
                ),
                child: Row(
                  children: [
                    Text(p['icon']!, style: const TextStyle(fontSize: 12)),
                    const SizedBox(width: 4),
                    Text(
                      p['label']!,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF4338CA),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /*Widget _buildInputBar(BuildContext context, bool isNarrow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // TextField
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                  decoration: const InputDecoration(
                    hintText: 'Ask Vayo anything about your assessments...',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                   *//* isDense: true,*//*
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send Button
            ElevatedButton(
              onPressed: _sendMessage,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFC7D2FE),
                foregroundColor: const Color(0xFF312E81),
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Send',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF312E81),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }*/
  Widget _buildInputBar(BuildContext context, bool isNarrow) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE2E8F0))),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end, // keeps send icon at the bottom as field grows
          children: [
            // Expanding TextField
            Expanded(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _controller,
                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary),
                  keyboardType: TextInputType.multiline,
                  textInputAction: TextInputAction.newline,
                  textCapitalization: TextCapitalization.sentences,
                  minLines: 1,
                  maxLines: 5, // grows up to 5 lines, then scrolls
                  decoration: const InputDecoration(
                    hintText: 'Ask Vayo anything about your assessments...',
                    hintStyle: TextStyle(fontSize: 12, color: Color(0xFF94A3B8)),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(vertical: 10),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 8),

            // Send icon button
            Material(
              color: _isLoading ? const Color(0xFFE2E8F0) : const Color(0xFF4F46E5),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _isLoading ? null : () => _sendMessage(),
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.send_rounded, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
