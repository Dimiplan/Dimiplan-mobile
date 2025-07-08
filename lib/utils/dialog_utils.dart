import 'package:flutter/material.dart';

class DialogUtils {
  static Future<bool?> showConfirmDialog({
    required BuildContext context,
    required String title,
    required String content,
    String confirmText = '확인',
    String cancelText = '취소',
    Color? confirmColor,
  }) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                style:
                    confirmColor != null
                        ? TextButton.styleFrom(foregroundColor: confirmColor)
                        : null,
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }

  static Future<String?> showInputDialog({
    required BuildContext context,
    required String title,
    String? initialValue,
    String? hintText,
    String confirmText = '확인',
    String cancelText = '취소',
    String? Function(String?)? validator,
  }) {
    final controller = TextEditingController(text: initialValue);
    final ValueNotifier<String?> errorText = ValueNotifier(null);

    return showDialog<String>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: ValueListenableBuilder<String?>(
              valueListenable: errorText,
              builder: (context, error, child) {
                return TextField(
                  controller: controller,
                  decoration: InputDecoration(
                    hintText: hintText,
                    border: const OutlineInputBorder(),
                    errorText: error,
                  ),
                  autofocus: true,
                );
              },
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text(cancelText),
              ),
              TextButton(
                onPressed: () {
                  final text = controller.text.trim();
                  if (validator != null) {
                    final error = validator(text);
                    if (error != null) {
                      errorText.value = error;
                      return;
                    } else {
                      errorText.value = null;
                    }
                  }
                  if (text.isNotEmpty) {
                    Navigator.pop(context, text);
                  } else if (validator == null) {
                    Navigator.pop(context);
                  }
                },
                child: Text(confirmText),
              ),
            ],
          ),
    );
  }

  static void showLoadingDialog(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => PopScope(
            canPop: false,
            child: AlertDialog(
              content: Row(
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(width: 20),
                  Text(message ?? '처리 중...'),
                ],
              ),
            ),
          ),
    );
  }

  static void dismissDialog(BuildContext context) {
    Navigator.of(context).pop();
  }

  static Future<T?> showBottomSheet<T>({
    required BuildContext context,
    required Widget child,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isDismissible: isDismissible,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
      ),
      builder: (context) => SafeArea(child: child),
    );
  }
}
