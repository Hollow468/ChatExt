import 'package:flutter/material.dart';

import 'package:chatext/core/constants/app_constants.dart';
import 'package:chatext/core/di/injection.dart';
import 'package:chatext/services/storage/local_storage.dart';

/// 主题切换组件
///
/// 使用 SwitchListTile 在亮色和暗色主题之间切换。
/// 选择结果持久化到 Hive settings box。
class ThemeSwitcher extends StatefulWidget {
  const ThemeSwitcher({super.key});

  @override
  State<ThemeSwitcher> createState() => _ThemeSwitcherState();
}

class _ThemeSwitcherState extends State<ThemeSwitcher> {
  static const String _themeKey = 'theme_mode';

  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    final storage = getIt<LocalStorage>();
    final stored =
        storage.get(AppConstants.settingsBox, _themeKey) as String?;
    _themeMode = _parseThemeMode(stored);
  }

  ThemeMode _parseThemeMode(String? value) {
    switch (value) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.light:
        return 'light';
      case ThemeMode.system:
        return 'system';
    }
  }

  IconData _themeIcon(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return Icons.light_mode;
      case ThemeMode.dark:
        return Icons.dark_mode;
      case ThemeMode.system:
        return Icons.brightness_auto;
    }
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return '浅色';
      case ThemeMode.dark:
        return '深色';
      case ThemeMode.system:
        return '跟随系统';
    }
  }

  void _setThemeMode(ThemeMode mode) {
    setState(() => _themeMode = mode);
    getIt<LocalStorage>().put(
      AppConstants.settingsBox,
      _themeKey,
      _themeModeToString(mode),
    );

    // 通知 MaterialApp 更新主题
    // 通过 ChangeNotifier 模式或回调通知上层
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
            '外观',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        ...ThemeMode.values.map(
          (mode) => RadioListTile<ThemeMode>(
            secondary: Icon(_themeIcon(mode)),
            title: Text(_themeLabel(mode)),
            value: mode,
            groupValue: _themeMode,
            onChanged: (value) {
              if (value != null) _setThemeMode(value);
            },
          ),
        ),
      ],
    );
  }
}
