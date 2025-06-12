import 'package:flutter/foundation.dart';

mixin LoadingStateMixin on ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  void setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      safeNotifyListeners();
    }
  }

  void safeNotifyListeners() {
    if (!_isDisposed) {
      Future.microtask(() => notifyListeners());
    }
  }

  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}

class AsyncOperationHandler {
  static Future<T?> execute<T>({
    required Future<T> Function() operation,
    void Function(bool)? setLoading,
    void Function(dynamic)? onError,
    String? errorContext,
  }) async {
    setLoading?.call(true);

    try {
      return await operation();
    } catch (e) {
      if (errorContext != null) {
        print('$errorContext 중 오류 발생: $e');
      }
      onError?.call(e);
      rethrow;
    } finally {
      setLoading?.call(false);
    }
  }
}
