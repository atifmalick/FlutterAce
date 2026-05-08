import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../domain/entities/chat_message.dart';

class ChatBubble extends StatelessWidget {
  final ChatMessage message;
  const ChatBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(
          left: message.isUser ? 60 : 0,
          right: message.isUser ? 0 : 60,
          bottom: 12,
        ),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: message.isUser ? AppColors.primary : AppColors.cardBackground,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(message.isUser ? 16 : 4),
            bottomRight: Radius.circular(message.isUser ? 4 : 16),
          ),
          boxShadow: message.isUser ? null : AppColors.cardShadow,
        ),
        child: Text(
          message.content,
          style: AppTextStyles.body.copyWith(
            color: message.isUser ? Colors.white : AppColors.textPrimary,
            height: 1.5,
          ),
        ),
      ),
    );
  }
}
