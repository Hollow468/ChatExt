import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:chatext/core/di/injection.dart';
import 'package:chatext/core/utils/timestamp.dart';
import 'package:chatext/data/repositories/contact_repository.dart';
import 'package:chatext/data/repositories/message_repository.dart';
import 'package:chatext/features/chat/viewmodels/chat_list_viewmodel.dart';
import 'package:chatext/services/identity/identity_service.dart';
import 'package:chatext/services/identity/peer_resolver.dart';

/// 聊天列表屏幕
///
/// 显示所有活跃聊天，按最近消息时间排序。
/// 支持下拉刷新、空状态提示、FAB 创建新聊天。
class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatListViewModel(
        contactRepository: getIt<ContactRepository>(),
        messageRepository: getIt<MessageRepository>(),
      )..loadChats(),
      child: const _ChatListView(),
    );
  }
}

class _ChatListView extends StatelessWidget {
  const _ChatListView();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = context.watch<ChatListViewModel>();

    // 获取当前用户 peer ID 缩写用于 AppBar 显示
    String appBarTitle = 'ChatExt';
    try {
      final identityService = getIt<IdentityService>();
      if (identityService.isInitialized()) {
        final peerId = identityService.getPeerId();
        final peerResolver = getIt<PeerResolver>();
        appBarTitle = peerResolver.getDisplayName(peerId);
      }
    } catch (_) {
      // 身份未初始化时使用默认标题
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(appBarTitle),
        actions: [
          // 跳转到联系人页面
          IconButton(
            icon: const Icon(Icons.people),
            tooltip: '联系人',
            onPressed: () => context.push('/contacts'),
          ),
        ],
      ),
      body: _buildBody(context, viewModel, theme, colorScheme),

      // FAB：创建新聊天（跳转到联系人选择）
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/contacts'),
        tooltip: '新建聊天',
        child: const Icon(Icons.message),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    ChatListViewModel viewModel,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // 加载中
    if (viewModel.isLoading && viewModel.chats.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    // 错误状态
    if (viewModel.error != null && viewModel.chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.error!,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.loadChats,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 空状态
    if (viewModel.chats.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              '暂无聊天',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '点击右下角按钮开始新对话',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    // 聊天列表
    return RefreshIndicator(
      onRefresh: viewModel.loadChats,
      child: ListView.builder(
        itemCount: viewModel.chats.length,
        itemBuilder: (context, index) {
          final chat = viewModel.chats[index];
          final contact = chat.contact;
          final lastMsg = chat.lastMessage;

          // 显示名称
          final displayName = contact.displayName;
          // 最后消息预览
          final subtitle = lastMsg?.content ?? '暂无消息';
          // 时间标签
          final timeLabel = lastMsg != null
              ? TimestampUtils.formatDateTime(lastMsg.timestamp)
              : contact.lastMessageAt != null
                  ? TimestampUtils.formatDateTime(contact.lastMessageAt!)
                  : '';

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: colorScheme.primaryContainer,
              child: Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : '?',
                style: TextStyle(color: colorScheme.onPrimaryContainer),
              ),
            ),
            title: Text(
              displayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              subtitle,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 时间标签
                if (timeLabel.isNotEmpty)
                  Text(
                    timeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                // 未读数标记
                if (chat.unreadCount > 0) ...[
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${chat.unreadCount}',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: colorScheme.onPrimary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            onTap: () {
              // 跳转到聊天详情
              context.push('/chat/${contact.peerId}');
            },
          );
        },
      ),
    );
  }
}
