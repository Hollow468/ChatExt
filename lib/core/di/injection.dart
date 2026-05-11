import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/local/daos/contact_dao.dart';
import '../../data/local/daos/message_dao.dart';
import '../../data/local/database.dart';
import '../../data/repositories/contact_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../services/identity/identity_service.dart';
import '../../services/identity/peer_resolver.dart';
import '../../services/storage/local_storage.dart';
import '../../services/waku/waku_service.dart';
import '../constants/app_constants.dart';

/// Global service locator instance.
final GetIt getIt = GetIt.instance;

/// Configures all dependency injections.
///
/// Registers services and repositories as singletons. Concrete implementations
/// will be wired up as individual feature modules are completed.
Future<void> configureDependencies() async {
  // ── Initialize Hive ────────────────────────────────────────────────────────
  await Hive.initFlutter();

  // Open persistent boxes
  await Hive.openBox<dynamic>(AppConstants.identityBox);
  await Hive.openBox<dynamic>(AppConstants.settingsBox);
  await Hive.openBox<dynamic>(AppConstants.contactsBox);

  // ── Core services ──────────────────────────────────────────────────────────
  getIt.registerSingleton<LocalStorage>(LocalStorage());

  // ── Database ───────────────────────────────────────────────────────────────
  final database = AppDatabase();
  getIt.registerSingleton<AppDatabase>(database);

  // Register DAOs (provided by AppDatabase)
  getIt.registerSingleton<ContactDao>(database.contactDao);
  getIt.registerSingleton<MessageDao>(database.messageDao);

  // ── Services ───────────────────────────────────────────────────────────────
  getIt.registerSingleton<IdentityService>(IdentityService());
  getIt.registerSingleton<PeerResolver>(PeerResolver());

  // WakuService — register implementation (not yet connected to native layer)
  getIt.registerSingleton<WakuService>(WakuServiceImpl());

  // ── Repositories ───────────────────────────────────────────────────────────
  getIt.registerSingleton<ContactRepository>(
    ContactRepository(contactDao: getIt<ContactDao>()),
  );
  getIt.registerSingleton<MessageRepository>(
    MessageRepository(
      messageDao: getIt<MessageDao>(),
      wakuService: getIt<WakuService>(),
    ),
  );
}

/// Resets all registered dependencies. Useful for testing.
Future<void> resetDependencies() async {
  await getIt.reset();
}
