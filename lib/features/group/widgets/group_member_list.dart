import 'package:flutter/material.dart';

/// Displays a list of group members with their peer IDs.
///
/// When [canManage] is true, each member row shows a remove action.
/// An optional [onRemove] callback is invoked with the peer ID.
class GroupMemberList extends StatelessWidget {
  const GroupMemberList({
    super.key,
    required this.memberPeerIds,
    required this.myPeerId,
    this.canManage = false,
    this.onRemove,
  });

  /// List of member peer IDs to display.
  final List<String> memberPeerIds;

  /// Current user's peer ID (used to label "you" and prevent self-removal).
  final String myPeerId;

  /// Whether the current user can manage (add/remove) members.
  final bool canManage;

  /// Callback when the remove action is tapped. Receives the peer ID.
  final ValueChanged<String>? onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (memberPeerIds.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            '暂无成员',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: memberPeerIds.length,
      itemBuilder: (context, index) {
        final peerId = memberPeerIds[index];
        final isMe = peerId == myPeerId;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isMe
                ? colorScheme.primaryContainer
                : colorScheme.surfaceContainerHighest,
            child: Text(
              peerId.isNotEmpty ? peerId[0].toUpperCase() : '?',
              style: TextStyle(
                color: isMe
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurface,
              ),
            ),
          ),
          title: Text(
            isMe ? '我' : _abbreviatePeerId(peerId),
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            _abbreviatePeerId(peerId),
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: canManage && !isMe
              ? IconButton(
                  icon: Icon(
                    Icons.remove_circle_outline,
                    color: colorScheme.error,
                  ),
                  tooltip: '移除成员',
                  onPressed: () => onRemove?.call(peerId),
                )
              : null,
        );
      },
    );
  }

  static String _abbreviatePeerId(String peerId) {
    if (peerId.length <= 12) return peerId;
    return '${peerId.substring(0, 6)}...${peerId.substring(peerId.length - 4)}';
  }
}
