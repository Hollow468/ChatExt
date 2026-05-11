import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 身份操作按钮组件
///
/// 显示 peer ID 缩写，点击可复制完整 peer ID，并显示身份状态。
class IdentityButton extends StatelessWidget {
  const IdentityButton({
    super.key,
    this.peerId,
    this.isCreated = false,
  });

  /// 完整的 Base58 peer ID。为 null 时表示身份未创建。
  final String? peerId;

  /// 身份是否已创建。
  final bool isCreated;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // 缩写 peer ID：取前6位和后4位
    final abbreviated = _abbreviatePeerId(peerId);

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: peerId != null ? () => _copyPeerId(context) : null,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 状态指示图标
            Icon(
              isCreated ? Icons.check_circle : Icons.help_outline,
              size: 20,
              color: isCreated ? colorScheme.primary : colorScheme.outline,
            ),
            const SizedBox(width: 8),

            // 显示内容
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isCreated ? '已创建' : '未创建',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  abbreviated,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontFamily: 'monospace',
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),

            // 复制图标（仅身份已创建时显示）
            if (peerId != null) ...[
              const SizedBox(width: 8),
              Icon(
                Icons.copy,
                size: 16,
                color: colorScheme.onSurfaceVariant,
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// 缩写 peer ID：前6位 + "..." + 后4位
  static String _abbreviatePeerId(String? peerId) {
    if (peerId == null || peerId.isEmpty) return '---';
    if (peerId.length <= 12) return peerId;
    return '${peerId.substring(0, 6)}...${peerId.substring(peerId.length - 4)}';
  }

  /// 将完整 peer ID 复制到剪贴板，并显示提示
  void _copyPeerId(BuildContext context) {
    if (peerId == null) return;
    Clipboard.setData(ClipboardData(text: peerId!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Peer ID 已复制到剪贴板'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}
