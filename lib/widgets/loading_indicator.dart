import 'package:flutter/material.dart';

/// 앱 전체에서 사용하는 로딩 인디케이터
class AppLoadingIndicator extends StatelessWidget {
  const AppLoadingIndicator({
    super.key,
    this.size = 48.0,
    this.color,
    this.strokeWidth = 4.0,
    this.message,
  });
  final double size;
  final Color? color;
  final double strokeWidth;
  final String? message;

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

/// 스켈레톤 로딩 효과 (애니메이션 포함)
class SkeletonLoading extends StatefulWidget {
  const SkeletonLoading({
    required this.width,
    required this.height,
    super.key,
    this.borderRadius = 4.0,
    this.isCircle = false,
  });
  final double width;
  final double height;
  final double borderRadius;
  final bool isCircle;

  @override
  State<SkeletonLoading> createState() => _SkeletonLoadingState();
}

class _SkeletonLoadingState extends State<SkeletonLoading>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

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

    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            borderRadius:
                widget.isCircle
                    ? BorderRadius.circular(widget.height / 2)
                    : BorderRadius.circular(widget.borderRadius),
            gradient: LinearGradient(
              begin: Alignment(-1.0 + 2 * _animation.value, 0.0),
              end: Alignment(1.0 + 2 * _animation.value, 0.0),
              colors: [baseColor, highlightColor, baseColor],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}

/// 작업 목록용 스켈레톤 로더
class TaskListSkeleton extends StatelessWidget {
  const TaskListSkeleton({super.key, this.itemCount = 5});
  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 80.0),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(8.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              children: [
                SkeletonLoading(width: 24, height: 24, isCircle: true),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SkeletonLoading(width: double.infinity, height: 16),
                      SizedBox(height: 8),
                      SkeletonLoading(width: 120, height: 12),
                    ],
                  ),
                ),
                SizedBox(width: 16),
                SkeletonLoading(width: 60, height: 20, borderRadius: 10),
              ],
            ),
          ),
        );
      },
    );
  }
}
