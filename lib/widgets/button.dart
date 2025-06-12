import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dimiplan/theme/app_theme.dart';
import 'package:color_shade/color_shade.dart';

/// 앱 전체에서 사용되는 일관된 버튼 디자인
/// 웹 버전과 동일한 디자인 시스템 적용
class AppButton extends StatelessWidget {

  const AppButton({
    required this.text,
    required this.onPressed,
    super.key,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.variant = ButtonVariant.primary,
    this.size = ButtonSize.medium,
    this.disabled = false,
    this.rounded = false,
  });
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final ButtonVariant variant;
  final ButtonSize size;
  final bool disabled;
  final bool rounded;

  @override
  Widget build(BuildContext context) {
    // 버튼 색상 및 스타일 정의
    final theme = Theme.of(context);

    // 버튼 크기 설정
    final padding = _getPadding();
    final textStyle = _getTextStyle(theme);
    final height = _getHeight();

    // 버튼 배경 및 전경색 설정
    final backgroundColor = _getBackgroundColor(theme);
    final foregroundColor = _getForegroundColor(theme);

    // 버튼 테두리 스타일 설정
    final BorderSide borderSide = _getBorderSide(theme);

    return Semantics(
      button: true,
      enabled: !disabled && !isLoading,
      label: text,
      hint: _getSemanticHint(),
      child: SizedBox(
        width: isFullWidth ? double.infinity : null,
        height: height,
        child: ElevatedButton(
        onPressed: (disabled || isLoading) ? null : () {
          HapticFeedback.lightImpact();
          onPressed();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          padding: padding,
          textStyle: textStyle,
          elevation: variant == ButtonVariant.text ? 0 : 2,
          shadowColor:
              variant == ButtonVariant.primary
                  ? AppTheme.primaryColor.shade300
                  : Colors.black.shade100,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(rounded ? 30.0 : 8.0),
            side: borderSide,
          ),
          disabledBackgroundColor: backgroundColor.shade700,
          disabledForegroundColor: foregroundColor.shade500,
        ),
        child:
            isLoading
                ? _buildLoadingIndicator(foregroundColor)
                : _buildButtonContent(foregroundColor),
      ),
    ),
    );
  }

  Widget _buildLoadingIndicator(Color color) {
    final double spinnerSize =
        size == ButtonSize.large
            ? 24.0
            : (size == ButtonSize.medium ? 20.0 : 16.0);

    return SizedBox(
      height: spinnerSize,
      width: spinnerSize,
      child: CircularProgressIndicator(strokeWidth: 2.0, color: color),
    );
  }

  Widget _buildButtonContent(Color color) {
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size:
                size == ButtonSize.large
                    ? 24.0
                    : (size == ButtonSize.medium ? 20.0 : 16.0),
            color: color,
          ),
          const SizedBox(width: 8.0),
          Text(text),
        ],
      );
    }

    return Text(text);
  }

  EdgeInsetsGeometry _getPadding() {
    switch (size) {
      case ButtonSize.small:
        return const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0);
      case ButtonSize.medium:
        return const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0);
      case ButtonSize.large:
        return const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0);
    }
  }

  TextStyle _getTextStyle(ThemeData theme) {
    final baseStyle = theme.textTheme.labelMedium ?? const TextStyle();

    switch (size) {
      case ButtonSize.small:
        return baseStyle.copyWith(fontSize: 14.0, fontWeight: FontWeight.w500);
      case ButtonSize.medium:
        return baseStyle.copyWith(fontSize: 16.0, fontWeight: FontWeight.w500);
      case ButtonSize.large:
        return baseStyle.copyWith(fontSize: 18.0, fontWeight: FontWeight.w600);
    }
  }

  double _getHeight() {
    switch (size) {
      case ButtonSize.small:
        return 36.0;
      case ButtonSize.medium:
        return 48.0;
      case ButtonSize.large:
        return 56.0;
    }
  }

  Color _getBackgroundColor(ThemeData theme) {
    if (disabled) {
      return theme.disabledColor.shade100;
    }

    switch (variant) {
      case ButtonVariant.primary:
        return theme.primaryColor;
      case ButtonVariant.secondary:
        return theme.colorScheme.surface;
      case ButtonVariant.danger:
        return AppTheme.error;
      case ButtonVariant.success:
        return AppTheme.success;
      case ButtonVariant.text:
        return Colors.transparent;
    }
  }

  Color _getForegroundColor(ThemeData theme) {
    if (disabled) {
      return theme.disabledColor;
    }

    switch (variant) {
      case ButtonVariant.primary:
        return Colors.white;
      case ButtonVariant.secondary:
        return theme.textTheme.bodyLarge?.color ?? Colors.black;
      case ButtonVariant.danger:
        return Colors.white;
      case ButtonVariant.success:
        return Colors.white;
      case ButtonVariant.text:
        return theme.primaryColor;
    }
  }

  BorderSide _getBorderSide(ThemeData theme) {
    if (variant == ButtonVariant.secondary) {
      return BorderSide(color: theme.colorScheme.outline);
    }

    if (variant == ButtonVariant.text) {
      return BorderSide.none;
    }

    return BorderSide.none;
  }

  String _getSemanticHint() {
    if (isLoading) return '로딩 중입니다';
    if (disabled) return '비활성화된 버튼입니다';
    
    switch (variant) {
      case ButtonVariant.primary:
        return '기본 버튼';
      case ButtonVariant.secondary:
        return '보조 버튼';
      case ButtonVariant.danger:
        return '위험한 동작을 수행하는 버튼입니다';
      case ButtonVariant.success:
        return '성공 동작을 수행하는 버튼입니다';
      case ButtonVariant.text:
        return '텍스트 버튼';
    }
  }
}

/// 버튼 크기 정의
enum ButtonSize { small, medium, large }

/// 버튼 종류 정의
enum ButtonVariant { primary, secondary, danger, success, text }
