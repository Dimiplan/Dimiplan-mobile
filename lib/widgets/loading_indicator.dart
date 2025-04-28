import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 로딩 인디케이터
class AppLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? message;

  const AppLoadingIndicator({
    Key? key,
    this.size = 48.0,
    this.color,
    this.strokeWidth = 4.0,
    this.message,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final indicatorColor = color ?? theme.colorScheme.primary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            color: indicatorColor,
            strokeWidth: strokeWidth,
          ),
        ),
        if (message != null) ...[
          const SizedBox(height: 16.0),
          Text(
            message!,
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}

/// 스켈레톤 로딩 효과
class SkeletonLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  const SkeletonLoading({
    Key? key,
    required this.width,
    required this.height,
    this.borderRadius = 4.0,
    this.isCircle = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final baseColor =
        theme.brightness == Brightness.light
            ? Colors.grey[300]!
            : Colors.grey[700]!;
    final highlightColor =
        theme.brightness == Brightness.light
            ? Colors.grey[100]!
            : Colors.grey[600]!;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius:
            isCircle
                ? BorderRadius.circular(height / 2)
                : BorderRadius.circular(borderRadius),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [baseColor, highlightColor, baseColor],
          stops: const [0.4, 0.5, 0.6],
        ),
      ),
    );
  }
}
