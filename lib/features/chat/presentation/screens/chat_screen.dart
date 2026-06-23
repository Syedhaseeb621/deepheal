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
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!message.isUser)
                Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.primary,
                    child: Icon(Icons.auto_awesome, size: 14, color: Colors.white),
                  ),
                ),
              const SizedBox(width: 10),
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    gradient: message.isUser ? AppColors.primaryGradient : null,
                    color: message.isUser ? null : Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(22),
                      topRight: const Radius.circular(22),
                      bottomLeft: Radius.circular(message.isUser ? 22 : 4),
                      bottomRight: Radius.circular(message.isUser ? 4 : 22),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: (message.isUser ? AppColors.primary : Colors.black).withOpacity(0.08),
                        blurRadius: 12,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: isTyping 
                    ? Row(
                        mainAxisSize: MainAxisSize.min,
                        children: List.generate(3, (index) => _buildDot(index)),
                      )
                    : Text(
                        message.text,
                        style: TextStyle(
                          color: message.isUser ? Colors.white : AppColors.textPrimary,
                          fontSize: 16,
                          height: 1.5,
                          fontWeight: message.isUser ? FontWeight.w500 : FontWeight.normal,
                        ),
                      ),
                ).animate().scale(begin: const Offset(0.9, 0.9), curve: Curves.easeOutBack, duration: 400.ms),
              ),
              const SizedBox(width: 10),
              if (message.isUser)
                const CircleAvatar(
                  radius: 15,
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, size: 14, color: AppColors.primary),
                ),
            ],
          ),
          if (!message.isUser && !isTyping && message.suggestions != null) ...[
            const SizedBox(height: 16),
            _buildSuggestions(message.suggestions!),
            const SizedBox(height: 12),
            _buildFeedbackButtons(message),
          ],
        ],
      ),
    );
  }

  Widget _buildDot(int index) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Container(
        width: 6,
        height: 6,
        decoration: const BoxDecoration(color: AppColors.textDisabled, shape: BoxShape.circle),
      ).animate(onPlay: (controller) => controller.repeat())
       .scale(
         duration: 600.ms, 
         delay: (index * 200).ms, 
         begin: const Offset(1, 1), 
         end: const Offset(1.5, 1.5)
       ).then().scale(duration: 600.ms, begin: const Offset(1.5, 1.5), end: const Offset(1, 1)),
    );
  }

  Widget _buildSuggestions(List<String> suggestions) {
    return Padding(
      padding: const EdgeInsets.only(left: 40),
      child: Wrap(
        spacing: 10,
        runSpacing: 10,
        children: suggestions.map((s) => ActionChip(
          label: Text(s),
          onPressed: () {
            _messageController.text = s;
            _sendMessage();
          },
          backgroundColor: AppColors.primary.withOpacity(0.08),
          labelStyle: const TextStyle(color: AppColors.primary, fontSize: 13, fontWeight: FontWeight.w600),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          side: BorderSide(color: AppColors.primary.withOpacity(0.2)),
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        )).toList(),
      ),
    ).animate().fadeIn(delay: 500.ms).slideX(begin: 0.1, end: 0);
  }

  Widget _buildFeedbackButtons(ChatMessage message) {
    final hasThumbsUp = message.feedback == 'positive';
    final hasThumbsDown = message.feedback == 'negative';

    return Padding(
      padding: const EdgeInsets.only(left: 32),
      child: Row(
        children: [
          _buildIconButton(
            icon: hasThumbsUp ? Icons.thumb_up_rounded : Icons.thumb_up_off_alt,
            color: hasThumbsUp ? AppColors.primary : AppColors.textDisabled,
            onPressed: () => ref.read(chatProvider.notifier).updateMessageFeedback(message.id, 'positive'),
          ),
          const SizedBox(width: 8),
          _buildIconButton(
            icon: hasThumbsDown ? Icons.thumb_down_rounded : Icons.thumb_down_off_alt,
            color: hasThumbsDown ? Colors.redAccent : AppColors.textDisabled,
            onPressed: () => ref.read(chatProvider.notifier).updateMessageFeedback(message.id, 'negative'),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 700.ms);
  }

  Widget _buildIconButton({required IconData icon, required Color color, required VoidCallback onPressed}) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: color.withOpacity(0.05),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, size: 16, color: color),
      ),
    );
  }


  Widget _buildInputArea() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 16, 20, MediaQuery.of(context).padding.bottom + 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: AppColors.background,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.black.withOpacity(0.03)),
              ),
              child: TextField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Share what\'s on your mind...',
                  hintStyle: TextStyle(color: AppColors.textDisabled, fontSize: 15),
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
            height: 48,
            width: 48,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.primary.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: _sendMessage,
              icon: const Icon(Icons.send_rounded, color: Colors.white, size: 22),
            ),
          ),
        ],
      ),
    ).animate().slideY(begin: 1, end: 0, duration: 600.ms, curve: Curves.easeOutCubic);
  }
}
