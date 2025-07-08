import 'package:flutter/material.dart';
import 'package:color_shade/color_shade.dart';
import 'package:dimiplan/widgets/button.dart';

class AccountUnauthenticatedState extends StatelessWidget {
  const AccountUnauthenticatedState({
    super.key,
    required this.fadeAnimation,
    required this.slideAnimation,
    required this.onLogin,
  });

  final Animation<double> fadeAnimation;
  final Animation<Offset> slideAnimation;
  final VoidCallback onLogin;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FadeTransition(
      opacity: fadeAnimation,
      child: SlideTransition(
        position: slideAnimation,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 40.0,
              vertical: 40.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 아이콘
                Icon(
                  Icons.account_circle,
                  size: 100,
                  color: theme.colorScheme.primary.shade700,
                ),
                const SizedBox(height: 32),

                // 제목
                Text(
                  '로그인이 필요합니다',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // 설명
                Text(
                  '디미플랜의 모든 기능을 이용하려면 로그인이 필요합니다.',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // 로그인 버튼
                AppButton(
                  text: '구글 계정으로 로그인',
                  icon: Icons.login,
                  size: ButtonSize.large,
                  isFullWidth: true,
                  rounded: true,
                  onPressed: onLogin,
                ),

                const SizedBox(height: 16),

                // 설명
                Text(
                  '디미고 구글 계정으로 로그인 시 학년/반이 자동으로 설정됩니다.',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.shade700,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
