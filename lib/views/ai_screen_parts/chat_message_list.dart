import 'package:flutter/material.dart';
import 'package:gpt_markdown/gpt_markdown.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:dimiplan/models/chat_models.dart';

class ChatMessageList extends StatelessWidget {
  const ChatMessageList({
    super.key,
    required this.messages,
    required this.isLoading,
    required this.scrollController,
  });
  final List<ChatMessage> messages;
  final bool isLoading;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ListView.builder(
      controller: scrollController,
      padding: const EdgeInsets.all(16.0),
      itemCount: messages.length + (isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == messages.length) {
          // 로딩 중인 AI 메시지
          return _buildLoadingMessage(context, theme);
        }

        final message = messages[index];
        return _buildChatBubble(context, message, theme);
      },
    );
  }

  // 로딩 중인 메시지
  Widget _buildLoadingMessage(BuildContext context, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Card(
          color: theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(16.0),
              topRight: Radius.circular(16.0),
              bottomRight: Radius.circular(16.0),
              bottomLeft: Radius.circular(4.0),
            ),
            side: BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: AnimatedTextKit(
              animatedTexts: [
                TyperAnimatedText(
                  '생각 중...',
                  speed: const Duration(milliseconds: 50),
                ),
              ],
              repeatForever: true,
            ),
          ),
        ),
      ),
    );
  }

  // 채팅 버블
  Widget _buildChatBubble(
    BuildContext context,
    ChatMessage message,
    ThemeData theme,
  ) {
    final isUser = message.sender == 'user';

    return Align(
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Card(
          color: isUser ? theme.colorScheme.primary : theme.colorScheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16.0),
              topRight: const Radius.circular(16.0),
              bottomRight:
                  isUser
                      ? const Radius.circular(4.0)
                      : const Radius.circular(16.0),
              bottomLeft:
                  isUser
                      ? const Radius.circular(16.0)
                      : const Radius.circular(4.0),
            ),
            side:
                isUser
                    ? BorderSide.none
                    : BorderSide(color: theme.colorScheme.outlineVariant),
          ),
          margin: const EdgeInsets.symmetric(vertical: 8.0),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child:
                isUser
                    ? Text(
                      message.message,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                      ),
                    )
                    : _buildMarkdownBody(message.message, theme),
          ),
        ),
      ),
    );
  }

  // 마크다운 형식 AI 메시지 표시
  Widget _buildMarkdownBody(String message, ThemeData theme) {
    return GptMarkdown(message, style: theme.textTheme.bodyMedium);
  }
}
