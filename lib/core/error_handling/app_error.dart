/// 应用错误类型和模型
///
/// 对错误进行分类，便于用户友好展示和日志记录。
enum AppErrorType {
  /// Waku 网络连接问题
  network,

  /// 加解密失败
  crypto,

  /// 数据库或 Hive 存储错误
  storage,

  /// 输入校验错误
  validation,

  /// 未预期的错误
  unknown,
}

/// 应用错误模型
class AppError {
  AppError({
    required this.type,
    required this.message,
    this.details,
    this.originalError,
    this.stackTrace,
  });

  /// 错误类型分类。
  final AppErrorType type;

  /// 原始错误信息（用于日志）。
  final String message;

  /// 附加详情（可选）。
  final String? details;

  /// 原始异常对象。
  final dynamic originalError;

  /// 原始堆栈信息。
  final StackTrace? stackTrace;

  /// 用户友好的错误提示文案。
  String get userMessage {
    switch (type) {
      case AppErrorType.network:
        return '网络连接失败，请检查网络设置';
      case AppErrorType.crypto:
        return '消息加密失败';
      case AppErrorType.storage:
        return '数据存储错误';
      case AppErrorType.validation:
        return message;
      case AppErrorType.unknown:
        return '发生未知错误';
    }
  }

  @override
  String toString() => 'AppError($type): $message';
}
