import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chatext/core/di/injection.dart';
import 'package:chatext/data/local/database.dart' hide Group;
import 'package:chatext/features/group/viewmodels/group_chat_viewmodel.dart';
import 'package:chatext/features/group/widgets/group_member_list.dart';
import 'package:chatext/features/chat/widgets/message_input.dart';
import 'package:chatext/services/identity/identity_service.dart';
import 'package:chatext/services/waku/group_topic_manager.dart';
import 'package:chatext/services/waku/waku_service.dart';

/// Group chat conversation screen.
///
/// Displays messages from group members, allows sending messages,
/// and provides access to the member list via the app bar.
class GroupChatScreen extends StatelessWidget {
  const GroupChatScreen({super.key, required this.groupId});

  /// The group ID to display.
  final String groupId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = GroupChatViewModel(
          groupId: groupId,
          identityService: getIt<IdentityService>(),
          topicManager: GroupTopicManager(waku: getIt<WakuService>()),
          groupDao: getIt<AppDatabase>().groupDao,
        );
        viewModel.init();
        return viewModel;
      },
      child: const _GroupChatView(),
    );
  }
}

class _GroupChatView extends StatefulWidget {
  const _GroupChatView();

  @override
  State<_GroupChatView> createState() => _GroupChatViewState();
}

class _GroupChatViewState extends State<_GroupChatView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  /// Shows a bottom sheet with the group member list.
  void _showMemberList(BuildContext context, GroupChatViewModel viewModel) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5,
          minChildSize: 0.3,
          maxChildSize: 0.85,
          expand: false,
          builder: (_, scrollController) {
            return Column(
              children: [
                // Handle bar.
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Theme.of(context)
                          .colorScheme
                          .onSurfaceVariant
                          .withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '群成员 (${viewModel.memberPeerIds.length})',
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      if (viewModel.isCreator)
                        IconButton(
                          icon: const Icon(Icons.person_add),
                          tooltip: '添加成员',
                          onPressed: () {
                            // TODO: navigate to add-member flow
                            Navigator.pop(context);
                          },
                        ),
                    ],
                  ),
                ),
                const Divider(),
                Expanded(
                  child: ListView(
                    controller: scrollController,
                    children: [
                      GroupMemberList(
                        memberPeerIds: viewModel.memberPeerIds,
                        myPeerId: viewModel.myPeerId,
                        canManage: viewModel.isCreator,
                        onRemove: (peerId) {
                          viewModel.removeMember(peerId);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = context.watch<GroupChatViewModel>();

    if (viewModel.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              viewModel.group?.name ?? '群聊',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${viewModel.memberPeerIds.length} 位成员',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: '查看成员',
            onPressed: () => _showMemberList(context, viewModel),
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'leave') {
                _confirmLeave(context, viewModel);
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'leave',
                child: Text('退出群组'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _buildMessageList(viewModel, theme, colorScheme),
          ),
          MessageInput(
            onSend: (text) => viewModel.sendMessage(text),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    GroupChatViewModel viewModel,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (viewModel.error != null && viewModel.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              viewModel.error!,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (viewModel.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.forum_outlined,
              size: 64,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无消息',
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '发送第一条消息开始群聊',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: viewModel.messages.length,
      itemBuilder: (context, index) {
        final message = viewModel.messages[index];
        final isMine = message.sender == viewModel.myPeerId;
        final isSystem = message.type.name == 'system';

        if (isSystem) {
          return _SystemMessageBubble(message: message.content);
        }

        return _GroupMessageBubble(
          message: message.content,
          senderPeerId: message.sender,
          isMine: isMine,
          timestamp: message.timestamp,
        );
      },
    );
  }

  void _confirmLeave(BuildContext context, GroupChatViewModel viewModel) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('退出群组'),
          content: const Text('确定要退出该群组吗？'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                viewModel.leaveGroup();
                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
              child: const Text('退出'),
            ),
          ],
        );
      },
    );
  }
}

/// Bubble for regular group messages, showing sender peer ID prefix.
class _GroupMessageBubble extends StatelessWidget {
  const _GroupMessageBubble({
    required this.message,
    required this.senderPeerId,
    required this.isMine,
    required this.timestamp,
  });

  final String message;
  final String senderPeerId;
  final bool isMine;
  final int timestamp;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = isMine
        ? colorScheme.primaryContainer
        : colorScheme.surfaceContainerHighest;
    final textColor = isMine
        ? colorScheme.onPrimaryContainer
        : colorScheme.onSurface;
    final senderColor = isMine
        ? colorScheme.onPrimaryContainer.withValues(alpha: 0.7)
        : colorScheme.primary;

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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sender peer ID (abbreviated).
            if (!isMine)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Text(
                  _abbreviatePeerId(senderPeerId),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: senderColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            // Content.
            Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(color: textColor),
            ),
            const SizedBox(height: 4),
            // Timestamp.
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                _formatTime(timestamp),
                style: theme.textTheme.labelSmall?.copyWith(
                  color: textColor.withValues(alpha: 0.5),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _abbreviatePeerId(String peerId) {
    if (peerId.length <= 12) return peerId;
    return '${peerId.substring(0, 6)}...${peerId.substring(peerId.length - 4)}';
  }

  static String _formatTime(int millis) {
    final dt = DateTime.fromMillisecondsSinceEpoch(millis);
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}

/// Inline system message (join / leave / name change).
class _SystemMessageBubble extends StatelessWidget {
  const _SystemMessageBubble({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
          ),
        ),
      ),
    );
  }
}
