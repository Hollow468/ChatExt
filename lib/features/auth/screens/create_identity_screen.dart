import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:chatext/core/di/injection.dart';
import 'package:chatext/features/auth/widgets/identity_button.dart';
import 'package:chatext/services/identity/identity_service.dart';

/// 身份创建屏幕
///
/// 首次启动时显示，引导用户创建 Ed25519 密钥对身份。
/// 如果身份已存在，自动跳转到聊天列表。
class CreateIdentityScreen extends StatefulWidget {
  const CreateIdentityScreen({super.key});

  @override
  State<CreateIdentityScreen> createState() => _CreateIdentityScreenState();
}

class _CreateIdentityScreenState extends State<CreateIdentityScreen> {
  final _identityService = getIt<IdentityService>();

  bool _isCreating = false;
  bool _identityCreated = false;
  String? _peerId;
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkExistingIdentity();
  }

  /// 检查是否已有身份，若有则自动跳转到聊天列表
  Future<void> _checkExistingIdentity() async {
    try {
      await _identityService.init();
      if (_identityService.isInitialized()) {
        if (mounted) {
          // 已有身份，自动跳转
          context.go('/chat-list');
        }
      }
    } catch (e) {
      // 初始化失败，显示创建界面
      debugPrint('检查身份失败: $e');
    }
  }

  /// 创建身份：生成 Ed25519 密钥对
  Future<void> _createIdentity() async {
    setState(() {
      _isCreating = true;
      _error = null;
    });

    try {
      await _identityService.init();

      if (_identityService.isInitialized()) {
        setState(() {
          _peerId = _identityService.getPeerId();
          _identityCreated = true;
        });
      } else {
        setState(() {
          _error = '身份创建失败，请重试';
        });
      }
    } catch (e) {
      setState(() {
        _error = '创建身份时出错: $e';
      });
    } finally {
      setState(() {
        _isCreating = false;
      });
    }
  }

  /// 复制 peer ID 到剪贴板
  void _copyPeerId() {
    if (_peerId == null) return;
    Clipboard.setData(ClipboardData(text: _peerId!));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Peer ID 已复制到剪贴板'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  /// 跳转到聊天列表
  void _goToChatList() {
    context.go('/chat-list');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('ChatExt')),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // ── App Logo ──────────────────────────────────────────────
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Icon(
                    Icons.chat_bubble_rounded,
                    size: 56,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(height: 24),

                // ── 欢迎文字 ──────────────────────────────────────────────
                Text(
                  '欢迎使用 ChatExt',
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '去中心化的点对点即时通讯',
                  style: theme.textTheme.bodyLarge?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 48),

                // ── 根据状态显示不同内容 ──────────────────────────────────
                if (!_identityCreated) ...[
                  // 创建身份按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isCreating ? null : _createIdentity,
                      icon: _isCreating
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.vpn_key),
                      label: Text(_isCreating ? '正在创建...' : '创建身份'),
                    ),
                  ),

                  // 错误提示
                  if (_error != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _error!,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ] else ...[
                  // 身份创建成功，显示 peer ID
                  Icon(
                    Icons.check_circle,
                    size: 64,
                    color: colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '身份创建成功！',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Peer ID 显示区域（可复制）
                  Text(
                    '你的 Peer ID',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: _copyPeerId,
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest
                            .withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: colorScheme.outlineVariant,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _peerId ?? '',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: 'monospace',
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Icon(
                            Icons.copy,
                            size: 20,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '点击可复制',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // 身份按钮组件展示
                  IdentityButton(
                    peerId: _peerId,
                    isCreated: true,
                  ),
                  const SizedBox(height: 32),

                  // 开始使用按钮
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _goToChatList,
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('开始使用'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
