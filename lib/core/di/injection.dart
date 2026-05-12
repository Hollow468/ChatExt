import 'package:get_it/get_it.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/local/daos/contact_dao.dart';
import '../../data/local/daos/group_dao.dart';
import '../../data/local/daos/message_dao.dart';
import '../../data/local/database.dart';
import '../../data/repositories/contact_repository.dart';
import '../../data/repositories/message_repository.dart';
import '../../services/crypto/key_store.dart';
import '../../services/crypto/session_manager.dart';
import '../../services/crypto/signal_service.dart';
import '../../services/group/group_invitation.dart';
import '../../services/group/group_registry.dart';
import '../../services/group/group_sync.dart';
import '../../services/identity/avatar_service.dart';
import '../../services/identity/identity_service.dart';
import '../../services/identity/nickname_service.dart';
import '../../services/identity/peer_resolver.dart';
import '../../services/identity/profile_broadcast.dart';
import '../../services/media/media_cache.dart';
import '../../services/media/media_transfer.dart';
import '../../services/push/fcm_service.dart';
import '../../services/push/notification_handler.dart';
import '../../services/push/push_registry.dart';
import '../../services/storage/local_storage.dart';
import '../../services/waku/history_sync.dart';
import '../../services/waku/store_service.dart';
import '../../services/waku/sync_state.dart';
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
  await Hive.openBox<dynamic>(AppConstants.signalBox);

  // ── Core services ──────────────────────────────────────────────────────────
  getIt.registerSingleton<LocalStorage>(LocalStorage());

  // ── Database ───────────────────────────────────────────────────────────────
  final database = AppDatabase();
  getIt.registerSingleton<AppDatabase>(database);

  // Register DAOs (provided by AppDatabase)
  getIt.registerSingleton<ContactDao>(database.contactDao);
  getIt.registerSingleton<GroupDao>(database.groupDao);
  getIt.registerSingleton<MessageDao>(database.messageDao);

  // ── Services ───────────────────────────────────────────────────────────────
  getIt.registerSingleton<IdentityService>(IdentityService());
  getIt.registerSingleton<PeerResolver>(PeerResolver());

  // WakuService — register implementation (not yet connected to native layer)
  getIt.registerSingleton<WakuService>(WakuServiceImpl());

  // Signal Protocol (E2E encryption)
  final signalKeyStore = SignalKeyStore();
  getIt.registerSingleton<SignalKeyStore>(signalKeyStore);
  getIt.registerSingleton<SessionManager>(
    SessionManager(keyStore: signalKeyStore),
  );
  getIt.registerSingleton<SignalService>(
    SignalService(keyStore: signalKeyStore),
  );

  // Media transfer
  getIt.registerSingleton<MediaCache>(MediaCache());
  getIt.registerSingleton<MediaTransferService>(
    MediaTransferService(waku: getIt<WakuService>()),
  );

  // Push notifications
  getIt.registerSingleton<FcmService>(FcmService());
  getIt.registerSingleton<NotificationHandler>(NotificationHandler());
  getIt.registerSingleton<PushRegistry>(
    PushRegistry(
      waku: getIt<WakuService>(),
      fcm: getIt<FcmService>(),
      identity: getIt<IdentityService>(),
    ),
  );

  // ── Group services ──────────────────────────────────────────────────────────
  final groupRegistry = GroupRegistry(
    waku: getIt<WakuService>(),
    groupDao: getIt<GroupDao>(),
  );
  getIt.registerSingleton<GroupRegistry>(groupRegistry);

  getIt.registerSingleton<GroupInvitationService>(
    GroupInvitationService(
      waku: getIt<WakuService>(),
      identity: getIt<IdentityService>(),
      registry: groupRegistry,
      groupDao: getIt<GroupDao>(),
    ),
  );

  getIt.registerSingleton<GroupSyncService>(
    GroupSyncService(
      waku: getIt<WakuService>(),
      groupDao: getIt<GroupDao>(),
      registry: groupRegistry,
    ),
  );

  // ── Identity / profile services ────────────────────────────────────────────
  final nicknameService = NicknameService(
    identity: getIt<IdentityService>(),
    waku: getIt<WakuService>(),
    contactDao: getIt<ContactDao>(),
  );
  getIt.registerSingleton<NicknameService>(nicknameService);

  final avatarService = AvatarService(
    identity: getIt<IdentityService>(),
    waku: getIt<WakuService>(),
    contactDao: getIt<ContactDao>(),
  );
  getIt.registerSingleton<AvatarService>(avatarService);

  getIt.registerSingleton<ProfileBroadcastService>(
    ProfileBroadcastService(
      identity: getIt<IdentityService>(),
      waku: getIt<WakuService>(),
      nickname: nicknameService,
      avatar: avatarService,
    ),
  );

  // ── Waku Store / history sync ──────────────────────────────────────────────
  getIt.registerSingleton<StoreService>(StoreService());

  final syncStateManager = SyncStateManager();
  await syncStateManager.init();
  getIt.registerSingleton<SyncStateManager>(syncStateManager);

  getIt.registerSingleton<HistorySyncService>(
    HistorySyncService(
      store: getIt<StoreService>(),
      messageDao: getIt<MessageDao>(),
      identity: getIt<IdentityService>(),
      syncState: syncStateManager,
      signal: getIt<SignalService>(),
    ),
  );

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
