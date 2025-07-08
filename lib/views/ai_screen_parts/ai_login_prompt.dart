import 'package:flutter/material.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/widgets/button.dart';

class AiLoginPrompt extends StatelessWidget {
  const AiLoginPrompt({super.key, this.onTabChange});
  final void Function(int)? onTabChange;

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
              Icons.lock_outline,
              size: 80,
              color: theme.colorScheme.primary.shade700,
            ),
            const SizedBox(height: 24),
            Text(
              'AI 챗봇 사용을 위해\n로그인이 필요합니다',
              style: theme.textTheme.titleLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Text(
              '로그인하고 AI 챗봇과 대화하여 학습에 도움을 받으세요.',
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            AppButton(
              text: '로그인하기',
              icon: Icons.login,
              size: ButtonSize.large,
              rounded: true,
              onPressed: () {
                onTabChange!(3);
              },
            ),
          ],
        ),
      ),
    );
  }
}
