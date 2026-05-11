import 'dart:developer';

import 'package:firebase_messaging/firebase_messaging.dart';

/// Top-level function for background message handling.
///
/// Must be a top-level or static function — Firebase requires this so the
/// handler can be invoked even when the app is terminated.
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  log('[FcmService] Background message: ${message.messageId}');
  // Background messages are persisted by the system and displayed via
  // flutter_local_notifications in NotificationHandler. No additional work
  // is needed here beyond logging.
}

/// Firebase Cloud Messaging service for push notifications.
///
/// Handles:
/// - FCM token retrieval and refresh
/// - Foreground message handling
/// - Background message handling (via static handler)
/// - Topic subscription for targeted notifications
///
/// **Important:** [Firebase.initializeApp] must be called before [init].
class FcmService {
  String? _fcmToken;
  String? get fcmToken => _fcmToken;

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  final List<void Function(RemoteMessage)> _foregroundHandlers = [];
  final List<void Function(RemoteMessage)> _messageOpenedAppHandlers = [];

  bool _initialized = false;

  /// Initializes FCM and requests permissions.
  ///
  /// Must be called after [Firebase.initializeApp].
  /// Registers the background handler and sets up listeners for foreground
  /// messages and notification taps.
  Future<void> init() async {
    if (_initialized) return;

    // Register background handler.
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

    // Request permission (iOS and Android 13+).
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );
    log('[FcmService] Authorization status: ${settings.authorizationStatus}');

    // Retrieve the current token.
    _fcmToken = await _messaging.getToken();
    log('[FcmService] FCM token: $_fcmToken');

    // Listen for token refreshes.
    _messaging.onTokenRefresh.listen((newToken) {
      _fcmToken = newToken;
      log('[FcmService] Token refreshed: $newToken');
    });

    // Foreground messages.
    FirebaseMessaging.onMessage.listen((message) {
      log('[FcmService] Foreground message: ${message.messageId}');
      for (final handler in _foregroundHandlers) {
        handler(message);
      }
    });

    // Notification tap (app opened from background).
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      log('[FcmService] Message opened app: ${message.messageId}');
      for (final handler in _messageOpenedAppHandlers) {
        handler(message);
      }
    });

    // Check if the app was opened from a terminated state by a notification.
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      // Defer so the caller has a chance to register handlers first.
      Future.microtask(() {
        for (final handler in _messageOpenedAppHandlers) {
          handler(initialMessage);
        }
      });
    }

    _initialized = true;
  }

  /// Returns the current FCM token, refreshing if needed.
  Future<String?> getToken() async {
    if (_fcmToken != null) return _fcmToken;
    _fcmToken = await _messaging.getToken();
    return _fcmToken;
  }

  /// Subscribes to an FCM topic (for broadcast notifications).
  Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    log('[FcmService] Subscribed to topic: $topic');
  }

  /// Unsubscribes from an FCM topic.
  Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    log('[FcmService] Unsubscribed from topic: $topic');
  }

  /// Registers a callback for foreground messages.
  void onForegroundMessage(void Function(RemoteMessage) handler) {
    _foregroundHandlers.add(handler);
  }

  /// Registers a callback for when the user taps a notification.
  void onMessageOpenedApp(void Function(RemoteMessage) handler) {
    _messageOpenedAppHandlers.add(handler);
  }
}
