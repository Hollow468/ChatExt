import 'package:flutter/material.dart';

import 'package:chatext/core/utils/timestamp.dart';
import 'package:chatext/data/models/message.dart';

/// 消息气泡组件
///
/// 根据是否为当前用户发送的消息，显示不同对齐方向和样式的气泡。
/// 包含消息内容和时间戳。
class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    required this.isMine,
  });

  /// 消息数据模型。
  final Message message;

  /// 是否为当前用户发送的消息。
  final bool isMine;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 根据发送/接收方向选择配色
    final bgColor = isMine
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final textColor = isMine
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    final timeColor = isMine
        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.6)
        : colorScheme.onSurfaceVariant;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        margin: EdgeInsets.only(
          left: isMine ? 48 : 12,
          right: isMine ? 12 : 48,
          top: 2,
          bottom: 2,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(isMine ? 16 : 4),
            bottomRight: Radius.circular(isMine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            // 消息内容
            Text(
              message.content,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),

            // 时间戳
            Text(
              TimestampUtils.formatDateTime(message.timestamp),
              style: theme.textTheme.labelSmall?.copyWith(
                color: timeColor,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
