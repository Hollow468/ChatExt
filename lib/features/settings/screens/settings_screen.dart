import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chatext/core/constants/app_constants.dart';
import 'package:chatext/core/di/injection.dart';
import 'package:chatext/features/settings/widgets/theme_switcher.dart';
import 'package:chatext/services/identity/identity_service.dart';
import 'package:chatext/services/storage/local_storage.dart';

/// 应用设置页面
///
/// 包含：
/// - 个人信息区域（昵称、头像）
/// - 主题切换（亮/暗色）
/// - 通知设置
/// - 隐私与安全
/// - 关于
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('设置'),
      ),
      body: ListView(
        children: [
          // 个人信息区域
          _ProfileSection(),

          const Divider(height: 1),

          // 主题切换
          const ThemeSwitcher(),

          const Divider(height: 1),

          // 通知设置
          _NotificationSection(),

          const Divider(height: 1),

          // 隐私与安全
          _PrivacySection(),

          const Divider(height: 1),

          // 关于
          _AboutSection(),
        ],
      ),
    );
  }
}

/// 个人信息区域 — 展示头像和昵称，点击进入编辑页面。
class _ProfileSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final identityService = getIt<IdentityService>();
    final storage = getIt<LocalStorage>();

    final nickname =
        storage.get(AppConstants.settingsBox, 'nickname') as String? ??
            '未设置昵称';
    final peerId = identityService.getPeerId();

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      leading: CircleAvatar(
        radius: 28,
        backgroundColor: colorScheme.primaryContainer,
        child: Text(
          nickname.isNotEmpty ? nickname[0].toUpperCase() : '?',
          style: theme.textTheme.titleMedium?.copyWith(
            color: colorScheme.onPrimaryContainer,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      title: Text(
        nickname,
        style: theme.textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
      ),
      subtitle: Text(
        '${peerId.substring(0, 12)}...',
        style: theme.textTheme.bodySmall?.copyWith(
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: colorScheme.onSurfaceVariant,
      ),
      onTap: () => context.push('/settings/profile'),
    );
  }
}

/// 通知设置区域
class _NotificationSection extends StatefulWidget {
  @override
  State<_NotificationSection> createState() => _NotificationSectionState();
}

class _NotificationSectionState extends State<_NotificationSection> {
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    final storage = getIt<LocalStorage>();
    _notificationsEnabled =
        storage.get(AppConstants.settingsBox, 'notifications_enabled')
                as bool? ??
            true;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '通知',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        SwitchListTile(
          title: const Text('消息通知'),
          subtitle: const Text('接收新消息时发送通知'),
          value: _notificationsEnabled,
          onChanged: (value) {
            setState(() => _notificationsEnabled = value);
            getIt<LocalStorage>().put(
              AppConstants.settingsBox,
              'notifications_enabled',
              value,
            );
          },
        ),
      ],
    );
  }
}

/// 隐私与安全区域
class _PrivacySection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '隐私与安全',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.lock_outline),
          title: const Text('端到端加密'),
          subtitle: const Text('所有消息均使用端到端加密'),
          trailing: Icon(
            Icons.check_circle,
            color: theme.colorScheme.primary,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.key),
          title: const Text('查看密钥'),
          subtitle: const Text('查看您的加密公钥指纹'),
          onTap: () {
            // TODO: 实现密钥指纹展示
          },
        ),
      ],
    );
  }
}

/// 关于区域
class _AboutSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            '关于',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.info_outline),
          title: const Text('ChatExt'),
          subtitle: Text('版本 ${AppConstants.version}'),
        ),
        ListTile(
          leading: const Icon(Icons.code),
          title: const Text('开源许可'),
          onTap: () {
            showLicensePage(
              context: context,
              applicationName: AppConstants.appName,
              applicationVersion: AppConstants.version,
            );
          },
        ),
      ],
    );
  }
}
