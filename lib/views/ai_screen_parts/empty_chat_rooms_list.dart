import 'package:flutter/material.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/widgets/button.dart';

class EmptyChatRoomsList extends StatelessWidget {
  const EmptyChatRoomsList({super.key, required this.onCreateNewChatRoom});
  final VoidCallback onCreateNewChatRoom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 48,
              color: theme.colorScheme.primary.shade700,
            ),
            const SizedBox(height: 16),
            Text(
              '아직 채팅방이 없습니다',
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              '새 채팅 버튼을 눌러 대화를 시작하세요',
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            AppButton(
              text: '새 채팅 시작',
              icon: Icons.add,
              onPressed: onCreateNewChatRoom,
            ),
          ],
        ),
      ),
    );
  }
}
