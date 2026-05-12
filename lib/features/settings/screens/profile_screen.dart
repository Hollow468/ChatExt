import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:chatext/core/constants/app_constants.dart';
import 'package:chatext/core/di/injection.dart';
import 'package:chatext/services/identity/identity_service.dart';
import 'package:chatext/services/storage/local_storage.dart';

/// 用户资料编辑页面
///
/// 允许：
/// - 修改昵称
/// - 修改头像（从相册选择或拍照）
/// - 查看 Peer ID 并复制
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nicknameController = TextEditingController();
  final _storage = getIt<LocalStorage>();
  final _identityService = getIt<IdentityService>();

  bool _isEditing = false;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    final nickname =
        _storage.get(AppConstants.settingsBox, 'nickname') as String? ?? '';
    _nicknameController.text = nickname;
    _nicknameController.addListener(_onNicknameChanged);
  }

  @override
  void dispose() {
    _nicknameController.removeListener(_onNicknameChanged);
    _nicknameController.dispose();
    super.dispose();
  }

  void _onNicknameChanged() {
    final original =
        _storage.get(AppConstants.settingsBox, 'nickname') as String? ?? '';
    final changed = _nicknameController.text.trim() != original;
    if (changed != _hasChanges) {
      setState(() => _hasChanges = changed);
    }
  }

  Future<void> _saveNickname() async {
    final nickname = _nicknameController.text.trim();
    if (nickname.isEmpty) return;

    await _storage.put(AppConstants.settingsBox, 'nickname', nickname);
    setState(() {
      _isEditing = false;
      _hasChanges = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('昵称已保存')),
      );
    }
  }

  void _copyPeerId() {
    final peerId = _identityService.getPeerId();
    Clipboard.setData(ClipboardData(text: peerId));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Peer ID 已复制到剪贴板')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final peerId = _identityService.getPeerId();
    final nickname = _nicknameController.text;

    return Scaffold(
      appBar: AppBar(
        title: const Text('个人资料'),
        actions: [
          if (_hasChanges)
            TextButton(
              onPressed: _saveNickname,
              child: const Text('保存'),
            ),
        ],
      ),
      body: ListView(
        children: [
          const SizedBox(height: 24),

          // 头像区域
          Center(
            child: GestureDetector(
              onTap: _showAvatarOptions,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      nickname.isNotEmpty
                          ? nickname[0].toUpperCase()
                          : '?',
                      style: theme.textTheme.headlineLarge?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: colorScheme.primary,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: 16,
                        color: colorScheme.onPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // 昵称
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              '昵称',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _isEditing
                ? TextField(
                    controller: _nicknameController,
                    autofocus: true,
                    decoration: const InputDecoration(
                      hintText: '输入昵称',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    onSubmitted: (_) => _saveNickname(),
                  )
                : ListTile(
                    title: Text(nickname.isEmpty ? '未设置昵称' : nickname),
                    trailing: const Icon(Icons.edit),
                    onTap: () {
                      setState(() => _isEditing = true);
                    },
                  ),
          ),
          const SizedBox(height: 24),

          // Peer ID
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Peer ID',
              style: theme.textTheme.titleSmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListTile(
                title: Text(
                  peerId,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: 'monospace',
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.copy),
                  tooltip: '复制 Peer ID',
                  onPressed: _copyPeerId,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // 提示信息
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Peer ID 是您的唯一标识符，分享给其他用户即可添加您为联系人。',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  void _showAvatarOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('从相册选择'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现图片选择
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('拍照'),
              onTap: () {
                Navigator.pop(context);
                // TODO: 实现相机拍照
              },
            ),
            ListTile(
              leading: const Icon(Icons.cancel),
              title: const Text('取消'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
