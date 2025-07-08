import 'package:flutter/material.dart';
import 'package:color_shade/color_shade.dart';

class EmptyChatScreen extends StatelessWidget {
  const EmptyChatScreen({super.key, required this.onSuggestionSelected});
  final Function(String) onSuggestionSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat,
              size: 64,
              color: theme.colorScheme.primary.shade700,
            ),
            const SizedBox(height: 24),
            Text(
              'AI 챗봇과 대화를 시작해보세요',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: 300,
              child: Text(
                '질문하거나, 학습 도움을 요청하거나, 아이디어를 공유해보세요.',
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 32),
            _buildSuggestionChips(theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionChips(ThemeData theme) {
    final suggestions = [
      '수학 문제 풀이를 도와줘',
      '프로그래밍 개념을 설명해줘',
      '영어 에세이 작성 팁',
      '스트레스 관리 방법',
      '공부 집중력 높이는 방법',
    ];

    return Wrap(
      spacing: 8.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children:
          suggestions.map((suggestion) {
            return ActionChip(
              label: Text(suggestion),
              backgroundColor: theme.colorScheme.surface,
              side: BorderSide(color: theme.colorScheme.primary.shade500),
              onPressed: () {
                onSuggestionSelected(suggestion);
              },
            );
          }).toList(),
    );
  }
}
