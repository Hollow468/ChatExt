import 'package:chatext/core/constants/app_constants.dart';
import 'package:chatext/core/logging/logger.dart';
import 'package:chatext/services/storage/local_storage.dart';

/// 隐私友好的本地分析统计
///
/// 所有使用数据仅保存在本地，不会上传至任何服务器。
/// 统计计数持久化存储在 Hive 的 settings box 中。
///
/// 统计指标：
/// - 消息发送/接收数量
/// - 创建群组数量
/// - 应用打开次数
/// - 会话时长
class PrivacyAnalytics {
  PrivacyAnalytics({LocalStorage? storage})
      : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;

  static const String _prefix = 'analytics_';
  static const String _sessionStartKey = '${_prefix}session_start';

  /// 自增某个计数指标。
  Future<void> increment(String metric) async {
    final key = '$_prefix$metric';
    final current = getCount(metric);
    await _storage.put(AppConstants.settingsBox, key, current + 1);
  }

  /// 获取某个计数指标的当前值。
  int getCount(String metric) {
    final key = '$_prefix$metric';
    final value = _storage.get(AppConstants.settingsBox, key);
    if (value is int) return value;
    if (value is num) return value.toInt();
    return 0;
  }

  /// 记录会话开始时间。
  Future<void> recordSessionStart() async {
    await _storage.put(
      AppConstants.settingsBox,
      _sessionStartKey,
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// 记录会话结束并计算持续时长（秒）。
  Future<void> recordSessionEnd() async {
    final startMs =
        _storage.get(AppConstants.settingsBox, _sessionStartKey) as int?;
    if (startMs == null) return;

    final durationSec =
        (DateTime.now().millisecondsSinceEpoch - startMs) ~/ 1000;
    final totalKey = '${_prefix}total_session_seconds';
    final current =
        _storage.get(AppConstants.settingsBox, totalKey) as int? ?? 0;
    await _storage.put(
      AppConstants.settingsBox,
      totalKey,
      current + durationSec,
    );
    await _storage.delete(AppConstants.settingsBox, _sessionStartKey);

    AppLogger.debug(
      '会话结束，持续 ${durationSec}s，累计 ${current + durationSec}s',
      tag: 'Analytics',
    );
  }

  /// 获取所有指标数据。
  Map<String, int> getAllMetrics() {
    final result = <String, int>{};

    // 已知指标列表
    const metrics = [
      'messages_sent',
      'messages_received',
      'groups_created',
      'app_open_count',
      'total_session_seconds',
    ];

    for (final metric in metrics) {
      result[metric] = getCount(metric);
    }

    return result;
  }

  /// 清除所有分析数据。
  Future<void> clear() async {
    const metrics = [
      'messages_sent',
      'messages_received',
      'groups_created',
      'app_open_count',
      'total_session_seconds',
      'session_start',
    ];
    for (final metric in metrics) {
      await _storage.delete(AppConstants.settingsBox, '$_prefix$metric');
    }
  }
}
