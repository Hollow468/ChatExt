import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:chatext/core/di/injection.dart';
import 'package:chatext/data/repositories/message_repository.dart';
import 'package:chatext/features/chat/viewmodels/chat_detail_viewmodel.dart';
import 'package:chatext/features/chat/widgets/message_bubble.dart';
import 'package:chatext/features/chat/widgets/message_input.dart';
import 'package:chatext/services/identity/identity_service.dart';
import 'package:chatext/services/identity/peer_resolver.dart';

/// 聊天详情屏幕
///
/// 显示与某位联系人的一对一聊天消息。
/// 支持发送消息、接收实时消息、自动滚动到底部。
class ChatDetailScreen extends StatelessWidget {
  const ChatDetailScreen({super.key, required this.peerId});

  /// 对方的 peer ID。
  final String peerId;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) {
        final viewModel = ChatDetailViewModel(
          remotePeerId: peerId,
          identityService: getIt<IdentityService>(),
          messageRepository: getIt<MessageRepository>(),
          peerResolver: getIt<PeerResolver>(),
        );
        viewModel.init();
        return viewModel;
      },
      child: const _ChatDetailView(),
    );
  }
}

class _ChatDetailView extends StatefulWidget {
  const _ChatDetailView();

  @override
  State<_ChatDetailView> createState() => _ChatDetailViewState();
}

class _ChatDetailViewState extends State<_ChatDetailView> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// 滚动到消息列表底部
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = context.watch<ChatDetailViewModel>();

    // 新消息到达时自动滚动到底部
    if (viewModel.messages.isNotEmpty) {
      _scrollToBottom();
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // 显示对方昵称
            Text(
              viewModel.displayName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            // 显示对方 peer ID 缩写
            Text(
              _abbreviatePeerId(viewModel.remotePeerId),
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          // ── 消息列表 ──────────────────────────────────────────────────
          Expanded(
            child: _buildMessageList(viewModel, theme, colorScheme),
          ),

          // ── 消息输入框 ────────────────────────────────────────────────
          MessageInput(
            onSend: (text) => viewModel.sendMessage(text),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(
    ChatDetailViewModel viewModel,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // 加载中
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 错误状态
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
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.loadMessages,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 空消息状态
    if (viewModel.messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
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
              '发送第一条消息开始对话',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    // 消息列表
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: viewModel.messages.length,
      itemBuilder: (context, index) {
        final message = viewModel.messages[index];
        final isMine = message.sender == viewModel.myPeerId;

        return MessageBubble(
          message: message,
          isMine: isMine,
        );
      },
    );
  }

  /// 缩写 peer ID 用于 AppBar 副标题
  static String _abbreviatePeerId(String peerId) {
    if (peerId.length <= 12) return peerId;
    return '${peerId.substring(0, 6)}...${peerId.substring(peerId.length - 4)}';
  }
}
