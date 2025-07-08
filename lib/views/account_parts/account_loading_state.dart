import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class AccountLoadingState extends StatelessWidget {
  const AccountLoadingState({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 프로필 이미지 스켈레톤
          Shimmer.fromColors(
            baseColor: theme.colorScheme.surface,
            highlightColor: theme.colorScheme.surfaceContainerHighest,
            child: CircleAvatar(
              radius: 60,
              backgroundColor: theme.colorScheme.surface,
            ),
          ),
          const SizedBox(height: 24),

          // 이름 스켈레톤
          Shimmer.fromColors(
            baseColor: theme.colorScheme.surface,
            highlightColor: theme.colorScheme.surfaceContainerHighest,
            child: Container(
              width: 200,
              height: 24,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 학년/반 스켈레톤
          Shimmer.fromColors(
            baseColor: theme.colorScheme.surface,
            highlightColor: theme.colorScheme.surfaceContainerHighest,
            child: Container(
              width: 120,
              height: 18,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
          const SizedBox(height: 32),

          // 버튼 스켈레톤
          Shimmer.fromColors(
            baseColor: theme.colorScheme.surface,
            highlightColor: theme.colorScheme.surfaceContainerHighest,
            child: Container(
              width: 180,
              height: 48,
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
