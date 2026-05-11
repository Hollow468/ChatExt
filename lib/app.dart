import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'navigation/app_router.dart';

/// Root application widget.
class ChatExtApp extends StatelessWidget {
  const ChatExtApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'ChatExt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: appRouter,
    );
  }
}
