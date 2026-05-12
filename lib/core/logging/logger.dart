import 'dart:developer' as developer;

import 'package:flutter/foundation.dart';

/// 日志级别
enum LogLevel {
  debug,
  info,
  warning,
  error,
}

/// 应用日志工具
///
/// 使用 `dart:developer` 的 [developer.log] 输出日志。
/// Release 模式下仅输出 warning 及以上级别。
class AppLogger {
  AppLogger._();

  static const String _tag = 'ChatExt';

  /// 当前最低日志级别，低于此级别的日志将被忽略。
  static LogLevel level = kReleaseMode ? LogLevel.warning : LogLevel.debug;

  /// Debug 级别日志。
  static void debug(String message, {String? tag}) {
    _log(LogLevel.debug, message, tag: tag);
  }

  /// Info 级别日志。
  static void info(String message, {String? tag}) {
    _log(LogLevel.info, message, tag: tag);
  }

  /// Warning 级别日志。
  static void warning(String message, {String? tag, Object? error}) {
    _log(LogLevel.warning, message, tag: tag, error: error);
  }

  /// Error 级别日志。
  static void error(
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    _log(
      LogLevel.error,
      message,
      tag: tag,
      error: error,
      stackTrace: stackTrace,
    );
  }

  static void _log(
    LogLevel logLevel,
    String message, {
    String? tag,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (logLevel.index < level.index) return;

    final name = tag ?? _tag;
    developer.log(
      message,
      name: name,
      level: _levelValue(logLevel),
      error: error,
      stackTrace: stackTrace,
    );
  }

  /// Maps [LogLevel] to `dart:developer` numeric levels.
  static int _levelValue(LogLevel logLevel) {
    switch (logLevel) {
      case LogLevel.debug:
        return 500;
      case LogLevel.info:
        return 800;
      case LogLevel.warning:
        return 900;
      case LogLevel.error:
        return 1000;
    }
  }
}
