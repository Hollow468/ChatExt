import 'package:flutter/material.dart';

import 'app.dart';
import 'core/di/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize dependency injection (including Hive setup).
  await configureDependencies();

  runApp(const ChatExtApp());
}
