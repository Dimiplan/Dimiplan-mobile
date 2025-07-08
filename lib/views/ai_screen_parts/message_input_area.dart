import 'package:flutter/material.dart';
import 'package:color_shade/color_shade.dart';

class MessageInputArea extends StatelessWidget {
  const MessageInputArea({
    super.key,
    required this.messageController,
    required this.inputFocusNode,
    required this.isComposing,
    required this.isLoading,
    required this.onSendMessage,
    required this.onChanged,
  });

  final TextEditingController messageController;
  final FocusNode inputFocusNode;
  final bool isComposing;
  final bool isLoading;
  final VoidCallback onSendMessage;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Container(
        padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 16.0),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.shade100,
              blurRadius: 4,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 텍스트 입력 필드
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  borderRadius: BorderRadius.circular(24.0),
                  border: Border.all(color: theme.colorScheme.outline.shade500),
                ),
                child: TextField(
                  controller: messageController,
                  focusNode: inputFocusNode,
                  decoration: const InputDecoration(
                    hintText: '메시지를 입력하세요...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 12.0,
                    ),
                    isDense: true,
                  ),
                  maxLines: 4,
                  minLines: 1,
                  textInputAction: TextInputAction.newline,
                  style: theme.textTheme.bodyLarge,
                  onChanged: onChanged,
                  onSubmitted: (value) {
                    if (isComposing) {
                      onSendMessage();
                    }
                  },
                ),
              ),
            ),

            const SizedBox(width: 12.0),

            // 전송 버튼
            IconButton(
              onPressed: isComposing ? onSendMessage : null,
              icon:
                  isLoading
                      ? const SizedBox(
                        width: 24.0,
                        height: 24.0,
                        child: CircularProgressIndicator(strokeWidth: 2.0),
                      )
                      : Icon(
                        Icons.send,
                        color:
                            isComposing
                                ? theme.colorScheme.primary
                                : theme.disabledColor,
                      ),
              tooltip: '메시지 전송',
            ),
          ],
        ),
      ),
    );
  }
}
