import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/app_providers.dart';
import '../../../../data/models/app_models.dart';
import '../../../../shared/widgets/glass_card.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key});

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;
    ref.read(chatProvider.notifier).sendMessage(_messageController.text);
    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 300), () {
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
  Widget build(BuildContext context) {
    final messages = ref.watch(chatProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('DeepHeal AI', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text('Always here to listen', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.info_outline_rounded)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.all(20),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final message = messages[index];
                return _buildChatBubble(message);
              },
            ),
          ),
          _buildInputArea(),
        ],
      ),
    );
  }

  Widget _buildChatBubble(ChatMessage message) {
    final isTyping = message.id == 'typing';

    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isUser)
                const CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.primary,
                  child: Icon(Icons.auto_awesome, size: 12, color: Colors.white),
                ),
              const SizedBox(width: 8),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: message.isUser ? AppColors.primary : Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(20),
                      topRight: const Radius.circular(20),
                      bottomLeft: Radius.circular(message.isUser ? 20 : 0),
                      bottomRight: Radius.circular(message.isUser ? 0 : 20),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: isTyping 
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          _buildDot(0),
                          const SizedBox(width: 4),
                          _buildDot(1),
                          const SizedBox(width: 4),
                          _buildDot(2),
                        ],
                      )
                    : Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : AppColors.textPrimary,
                          fontSize: 15,
                          height: 1.4,
                        ),
                      ),
                ).animate().scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack),
              ),
              const SizedBox(width: 8),
              if (message.isUser)
                const CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.textDisabled,
                  child: Icon(Icons.person, size: 12, color: Colors.white),
                ),
            ],
          ),
          if (!message.isUser && !isTyping && message.suggestions != null) ...[
            const SizedBox(height: 12),
            _buildSuggestions(message.suggestions!),
            const SizedBox(height: 12),
            _buildFeedbackButtons(message),
          ],
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Container(
      width: 6,
      height: 6,
      decoration: const BoxDecoration(color: AppColors.textDisabled, shape: BoxShape.circle),
    ).animate(onPlay: (controller) => controller.repeat())
     .scale(
       duration: 600.ms, 
       delay: (index * 200).ms, 
       begin: const Offset(1, 1), 
       end: const Offset(1.5, 1.5)
     ).then().scale(duration: 600.ms, begin: const Offset(1.5, 1.5), end: const Offset(1, 1));
  }

  Widget _buildSuggestions(List<String> suggestions) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: suggestions.map((s) => ActionChip(
        label: Text(s),
        onPressed: () {
          _messageController.text = s;
          _sendMessage();
        },
        backgroundColor: AppColors.primaryLight,
        labelStyle: const TextStyle(color: AppColors.primary, fontSize: 12, fontWeight: FontWeight.bold),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        side: BorderSide.none,
      )).toList(),
    ).animate().fadeIn(delay: 500.ms).slideY(begin: 0.2, end: 0);
  }

  Widget _buildFeedbackButtons(ChatMessage message) {
    final hasThumbsUp = message.feedback == 'positive';
    final hasThumbsDown = message.feedback == 'negative';

    return Row(
      children: [
        const SizedBox(width: 40),
        IconButton(
          onPressed: () {
            ref.read(chatProvider.notifier).updateMessageFeedback(message.id, 'positive');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feedback saved. Thank you!')),
            );
          },
          icon: Icon(
            hasThumbsUp ? Icons.thumb_up_rounded : Icons.thumb_up_off_alt,
            size: 16,
            color: hasThumbsUp ? AppColors.primary : AppColors.textDisabled,
          ),
        ),
        IconButton(
          onPressed: () {
            ref.read(chatProvider.notifier).updateMessageFeedback(message.id, 'negative');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feedback saved. We will improve!')),
            );
          },
          icon: Icon(
            hasThumbsDown ? Icons.thumb_down_rounded : Icons.thumb_down_off_alt,
            size: 16,
            color: hasThumbsDown ? Colors.redAccent : AppColors.textDisabled,
          ),
        ),
      ],
    ).animate().fadeIn(delay: 700.ms);
  }


  Widget _buildInputArea() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 20, offset: const Offset(0, -5)),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: GlassCard(
                borderRadius: 24,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                color: Colors.white.withOpacity(0.8),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Type your message...',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              decoration: const BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
              child: IconButton(
                onPressed: _sendMessage,
                icon: const Icon(Icons.send_rounded, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
