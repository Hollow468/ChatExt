import 'package:flutter/material.dart';

/// 消息投递状态
enum MessageStatus {
  /// 发送中
  sending,

  /// 已发送
  sent,

  /// 已送达
  delivered,

  /// 已读
  read,

  /// 发送失败
  failed,
}

/// 消息投递状态指示器
///
/// 根据状态显示不同图标：
/// - sending: 旋转加载指示器
/// - sent: 单勾
/// - delivered: 双勾
/// - read: 蓝色双勾
/// - failed: 感叹号
class MessageStatusIndicator extends StatelessWidget {
  const MessageStatusIndicator({
    super.key,
    required this.status,
    this.size = 16,
  });

  /// 消息状态。
  final MessageStatus status;

  /// 图标尺寸。
  final double size;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    switch (status) {
      case MessageStatus.sending:
        return SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(
            strokeWidth: 1.5,
            color: colorScheme.onSurfaceVariant,
          ),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.done,
          size: size,
          color: colorScheme.onSurfaceVariant,
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: size,
          color: colorScheme.onSurfaceVariant,
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: size,
          color: colorScheme.primary,
        );
      case MessageStatus.failed:
        return Icon(
          Icons.error_outline,
          size: size,
          color: colorScheme.error,
        );
    }
  }
}
