import 'package:chatext/core/error_handling/app_error.dart';
import 'package:chatext/core/logging/logger.dart';

/// 全局错误处理器
///
/// 集中捕获、记录并上报错误。
/// 提供 [guard] 方法包装异步操作，以及监听器机制
/// 便于 UI 层（如 SnackBar）响应错误。
class ErrorHandler {
  ErrorHandler._();

  static final ErrorHandler _instance = ErrorHandler._();

  /// 单例访问。
  factory ErrorHandler() => _instance;

  final List<void Function(AppError)> _listeners = [];

  /// 处理错误 — 记录日志并通知所有监听器。
  void handle(dynamic error, [StackTrace? stackTrace]) {
    final appError = _wrap(error, stackTrace);
    AppLogger.error(
      appError.message,
      tag: 'ErrorHandler',
      error: appError.originalError,
      stackTrace: appError.stackTrace,
    );
    for (final listener in _listeners) {
      listener(appError);
    }
  }

  /// 包装异步操作，捕获异常并通过 [handle] 处理。
  ///
  /// 返回操作结果，发生异常时返回 `null`。
  Future<T?> guard<T>(Future<T> Function() operation) async {
    try {
      return await operation();
    } catch (e, st) {
      handle(e, st);
      return null;
    }
  }

  /// 注册错误监听器（例如用于显示 SnackBar）。
  void addListener(void Function(AppError) listener) {
    _listeners.add(listener);
  }

  /// 移除错误监听器。
  void removeListener(void Function(AppError) listener) {
    _listeners.remove(listener);
  }

  /// 将原始异常包装为 [AppError]。
  AppError _wrap(dynamic error, StackTrace? stackTrace) {
    if (error is AppError) return error;

    final message = error?.toString() ?? 'Unknown error';

    // 简单分类：根据异常类型推断 AppErrorType
    AppErrorType type;
    if (error is FormatException || error is ArgumentError) {
      type = AppErrorType.validation;
    } else if (error is StateError) {
      type = AppErrorType.storage;
    } else {
      type = AppErrorType.unknown;
    }

    return AppError(
      type: type,
      message: message,
      originalError: error,
      stackTrace: stackTrace,
    );
  }
}
