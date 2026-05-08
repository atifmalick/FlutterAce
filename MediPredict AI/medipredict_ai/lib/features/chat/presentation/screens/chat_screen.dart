import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/constants/app_constants.dart';
import '../providers/chat_provider.dart';
import '../widgets/chat_bubble.dart';
import '../widgets/risk_score_indicator.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});
  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();

  void _send() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(text);
    _controller.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 200), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chatState = ref.watch(chatProvider);

    ref.listen<ChatState>(chatProvider, (prev, next) {
      if ((prev?.messages.length ?? 0) != next.messages.length) {
        _scrollToBottom();
      }
    });

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(children: [
        // Header
        Container(
          padding: EdgeInsets.only(
            top: MediaQuery.of(context).padding.top + 16,
            left: AppConstants.paddingLarge, right: AppConstants.paddingLarge, bottom: 16,
          ),
          decoration: const BoxDecoration(
            gradient: AppColors.darkGradient,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(28), bottomRight: Radius.circular(28),
            ),
          ),
          child: Row(children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('AI Symptom Triage', style: AppTextStyles.heading3.copyWith(color: Colors.white)),
              Text('Describe your symptoms', style: AppTextStyles.caption.copyWith(color: Colors.white60)),
            ])),
            IconButton(
              onPressed: () => ref.read(chatProvider.notifier).clearChat(),
              icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
            ),
          ]),
        ),
        // Messages
        Expanded(
          child: ListView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            itemCount: chatState.messages.length + (chatState.isAnalyzing ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == chatState.messages.length && chatState.isAnalyzing) {
                return _buildTypingIndicator();
              }
              final msg = chatState.messages[index];
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ChatBubble(message: msg),
                  if (msg.triageResult != null)
                    RiskScoreIndicator(result: msg.triageResult!),
                ],
              );
            },
          ),
        ),
        // Suggestion chips
        if (chatState.messages.length <= 2)
          _buildSuggestions(),
        // Input
        _buildInputBar(),
      ]),
    );
  }

  Widget _buildTypingIndicator() {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(right: 60, bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          color: AppColors.cardBackground,
          borderRadius: BorderRadius.circular(16),
          boxShadow: AppColors.cardShadow,
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          _dot(0), const SizedBox(width: 4), _dot(200), const SizedBox(width: 4), _dot(400),
          const SizedBox(width: 8),
          Text('Analyzing...', style: AppTextStyles.bodySmall),
        ]),
      ),
    );
  }

  Widget _dot(int delayMs) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.3, end: 1.0),
      duration: const Duration(milliseconds: 600),
      builder: (_, val, child) => Opacity(opacity: val, child: child),
      child: Container(
        width: 8, height: 8,
        decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildSuggestions() {
    final suggestions = [
      'I have a headache and fever',
      'Feeling dizzy and nauseous',
      'Persistent cough for 3 days',
      'Chest pain when breathing',
    ];
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => GestureDetector(
          onTap: () {
            _controller.text = suggestions[i];
            _send();
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondary,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            ),
            child: Text(suggestions[i], style: AppTextStyles.chip),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(16, 8, 16, MediaQuery.of(context).padding.bottom + 90),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 10, offset: const Offset(0, -4))],
      ),
      child: Row(children: [
        Expanded(
          child: TextField(
            controller: _controller,
            textInputAction: TextInputAction.send,
            onSubmitted: (_) => _send(),
            decoration: InputDecoration(
              hintText: 'Describe your symptoms...',
              filled: true,
              fillColor: AppColors.surfaceVariant,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
            ),
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: _send,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(gradient: AppColors.primaryGradient, shape: BoxShape.circle),
            child: const Icon(Icons.send_rounded, color: Colors.white, size: 20),
          ),
        ),
      ]),
    );
  }
}
