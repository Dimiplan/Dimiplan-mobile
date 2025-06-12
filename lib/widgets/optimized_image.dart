import 'package:flutter/material.dart';

/// 메모리 효율적인 이미지 위젯
class OptimizedImage extends StatelessWidget {
  const OptimizedImage({
    required this.imageUrl,
    super.key,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.cacheWidth,
    this.cacheHeight,
  });
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final int? cacheWidth;
  final int? cacheHeight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Image.network(
      imageUrl,
      width: width,
      height: height,
      fit: fit,
      cacheWidth: cacheWidth ?? (width?.toInt()),
      cacheHeight: cacheHeight ?? (height?.toInt()),
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return placeholder ?? _buildDefaultPlaceholder(theme);
      },
      errorBuilder: (context, error, stackTrace) {
        return errorWidget ?? _buildDefaultErrorWidget(theme);
      },
      // 이미지 품질 최적화
      // filterQuality: FilterQuality.medium, // 기본값이므로 제거
    );
  }

  Widget _buildDefaultPlaceholder(ThemeData theme) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2.0,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget(ThemeData theme) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Icon(
        Icons.broken_image,
        color: theme.colorScheme.onErrorContainer,
        size: 24,
      ),
    );
  }
}

/// 아바타용 최적화된 이미지
class OptimizedAvatar extends StatelessWidget {
  const OptimizedAvatar({
    required this.radius,
    super.key,
    this.imageUrl,
    this.child,
    this.backgroundColor,
  });
  final String? imageUrl;
  final double radius;
  final Widget? child;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (imageUrl == null || imageUrl!.isEmpty) {
      return CircleAvatar(
        radius: radius,
        backgroundColor: backgroundColor ?? theme.colorScheme.primary,
        child: child ?? Icon(Icons.person, size: radius, color: Colors.white),
      );
    }

    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? theme.colorScheme.surface,
      child: ClipOval(
        child: OptimizedImage(
          imageUrl: imageUrl!,
          width: radius * 2,
          height: radius * 2,
          // fit: BoxFit.cover, // 기본값이므로 제거
          cacheWidth: (radius * 2).toInt(),
          cacheHeight: (radius * 2).toInt(),
          errorWidget: Container(
            width: radius * 2,
            height: radius * 2,
            color: theme.colorScheme.errorContainer,
            child: Icon(
              Icons.person,
              size: radius,
              color: theme.colorScheme.onErrorContainer,
            ),
          ),
        ),
      ),
    );
  }
}

/// 썸네일용 최적화된 이미지
class OptimizedThumbnail extends StatelessWidget {
  const OptimizedThumbnail({
    required this.imageUrl,
    required this.size,
    super.key,
    this.onTap,
  });
  final String imageUrl;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final widget = OptimizedImage(
      imageUrl: imageUrl,
      width: size,
      height: size,
      cacheWidth: size.toInt(),
      cacheHeight: size.toInt(),
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: widget);
    }

    return widget;
  }
}

/// 이미지 캐시 유틸리티
class ImageCacheManager {
  // 이미지 캐시 클리어
  static void clearCache() {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  // 이미지 캐시 설정 최적화
  static void optimizeImageCache() {
    // 최대 캐시 크기 설정 (100MB)
    PaintingBinding.instance.imageCache.maximumSizeBytes = 100 * 1024 * 1024;
    // 최대 캐시 항목 수 설정
    PaintingBinding.instance.imageCache.maximumSize = 100;
  }

  // 특정 이미지 캐시 제거
  static void evictImage(String imageUrl) {
    final networkImage = NetworkImage(imageUrl);
    PaintingBinding.instance.imageCache.evict(networkImage);
  }
}
