import 'package:flutter/material.dart';

/// 애플리케이션 전체에서 일관된 스타일의 스낵바를 표시
void showSnackBar(
  BuildContext context,
  String message, {
  bool isError = false,
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  final theme = Theme.of(context);

  final snackBar = SnackBar(
    content: Text(
      message,
      style: theme.textTheme.bodyMedium?.copyWith(color: Colors.white),
    ),
    backgroundColor:
        isError ? theme.colorScheme.error : theme.colorScheme.primary,
    duration: duration,
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
    margin: const EdgeInsets.all(16.0),
    action: action,
  );

  ScaffoldMessenger.of(context).hideCurrentSnackBar();
  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}

/// 성공 메시지 스낵바
void showSuccessSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  showSnackBar(
    context,
    message,
    isError: false,
    duration: duration,
    action: action,
  );
}

/// 오류 메시지 스낵바
void showErrorSnackBar(
  BuildContext context,
  String message, {
  Duration duration = const Duration(seconds: 3),
  SnackBarAction? action,
}) {
  showSnackBar(
    context,
    message,
    isError: true,
    duration: duration,
    action: action,
  );
}
