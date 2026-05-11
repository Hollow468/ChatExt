import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import 'package:chatext/core/di/injection.dart';
import 'package:chatext/data/repositories/contact_repository.dart';
import 'package:chatext/features/contacts/viewmodels/contact_viewmodel.dart';
import 'package:chatext/services/identity/peer_resolver.dart';

/// 联系人列表屏幕
///
/// 显示所有已保存的联系人，支持搜索过滤和添加新联系人。
class ContactListScreen extends StatelessWidget {
  const ContactListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ContactViewModel(
        contactRepository: getIt<ContactRepository>(),
        peerResolver: getIt<PeerResolver>(),
      )..loadContacts(),
      child: const _ContactListView(),
    );
  }
}

class _ContactListView extends StatefulWidget {
  const _ContactListView();

  @override
  State<_ContactListView> createState() => _ContactListViewState();
}

class _ContactListViewState extends State<_ContactListView> {
  final _searchController = TextEditingController();
  bool _isSearchVisible = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// 显示添加联系人对话框
  void _showAddContactDialog(BuildContext context) {
    final peerIdController = TextEditingController();
    final nameController = TextEditingController();
    final formKey = GlobalKey<FormState>();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('添加联系人'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: peerIdController,
                  decoration: const InputDecoration(
                    labelText: 'Peer ID',
                    hintText: '输入对方的 Base58 Peer ID',
                  ),
                  maxLines: 2,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入 Peer ID';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: '显示名称',
                    hintText: '为联系人设置一个昵称',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return '请输入显示名称';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('取消'),
            ),
            FilledButton(
              onPressed: () async {
                if (!formKey.currentState!.validate()) return;

                final viewModel = context.read<ContactViewModel>();
                final success = await viewModel.addContact(
                  peerIdController.text.trim(),
                  nameController.text.trim(),
                );

                if (dialogContext.mounted) {
                  Navigator.pop(dialogContext);
                  if (success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('联系人添加成功')),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(viewModel.error ?? '添加失败'),
                        backgroundColor: Theme.of(context).colorScheme.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('添加'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final viewModel = context.watch<ContactViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: _isSearchVisible
            ? TextField(
                controller: _searchController,
                autofocus: true,
                decoration: const InputDecoration(
                  hintText: '搜索联系人...',
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (query) => viewModel.searchContacts(query),
              )
            : const Text('联系人'),
        actions: [
          // 搜索/取消搜索切换
          IconButton(
            icon: Icon(_isSearchVisible ? Icons.close : Icons.search),
            tooltip: _isSearchVisible ? '关闭搜索' : '搜索',
            onPressed: () {
              setState(() {
                _isSearchVisible = !_isSearchVisible;
                if (!_isSearchVisible) {
                  _searchController.clear();
                  viewModel.loadContacts();
                }
              });
            },
          ),
        ],
      ),
      body: _buildBody(viewModel, theme, colorScheme),

      // FAB：添加联系人
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddContactDialog(context),
        tooltip: '添加联系人',
        child: const Icon(Icons.person_add),
      ),
    );
  }

  Widget _buildBody(
    ContactViewModel viewModel,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    // 加载中
    if (viewModel.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    // 错误状态
    if (viewModel.error != null && viewModel.contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(
              viewModel.error!,
              style: theme.textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: viewModel.loadContacts,
              child: const Text('重试'),
            ),
          ],
        ),
      );
    }

    // 空状态
    if (viewModel.contacts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_outline,
              size: 80,
              color: colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              viewModel.searchQuery.isNotEmpty ? '未找到匹配的联系人' : '暂无联系人',
              style: theme.textTheme.titleMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              viewModel.searchQuery.isNotEmpty
                  ? '尝试其他关键词'
                  : '点击右下角按钮添加联系人',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      );
    }

    // 联系人列表
    return ListView.builder(
      itemCount: viewModel.contacts.length,
      itemBuilder: (context, index) {
        final contact = viewModel.contacts[index];

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              contact.displayName.isNotEmpty
                  ? contact.displayName[0].toUpperCase()
                  : '?',
              style: TextStyle(color: colorScheme.onPrimaryContainer),
            ),
          ),
          title: Text(
            contact.displayName,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
          subtitle: Text(
            _abbreviatePeerId(contact.peerId),
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: 'monospace',
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          trailing: contact.isOnline
              ? Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                )
              : null,
          onTap: () {
            // 点击联系人跳转到聊天详情
            context.push('/chat/${contact.peerId}');
          },
        );
      },
    );
  }

  /// 缩写 peer ID
  static String _abbreviatePeerId(String peerId) {
    if (peerId.length <= 12) return peerId;
    return '${peerId.substring(0, 6)}...${peerId.substring(peerId.length - 4)}';
  }
}
