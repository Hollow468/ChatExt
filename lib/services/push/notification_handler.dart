import 'dart:developer';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

/// Handles local notification display and tap actions.
///
/// Uses [FlutterLocalNotificationsPlugin] to show notifications on both
/// Android and iOS when messages arrive while the app is in foreground
/// or background.
class NotificationHandler {
  static const String _channelId = 'chatext_messages';
  static const String _channelName = 'Chat Messages';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  final List<void Function(String? payload)> _tapHandlers = [];

  bool _initialized = false;

  /// Initializes the notification plugin and creates notification channels.
  ///
  /// Must be called once during app startup, before any notifications are
  /// shown.
  Future<void> init() async {
    if (_initialized) return;

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (response) {
        _handleTap(response.payload);
      },
    );

    // Create the Android notification channel.
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: 'Notifications for incoming chat messages',
        importance: Importance.high,
        playSound: true,
        enableVibration: true,
      ),
    );

    _initialized = true;
    log('[NotificationHandler] Initialized');
  }

  /// Shows a notification for an incoming direct message.
  Future<void> showMessageNotification({
    required String title,
    required String body,
    required String peerId,
    String? groupId,
    String? payload,
  }) async {
    _assertInitialized();

    final id = peerId.hashCode & 0x7FFFFFFF;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifications for incoming chat messages',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation(body),
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id,
      title,
      body,
      details,
      payload: payload ?? peerId,
    );
  }

  /// Shows a notification for a group message.
  Future<void> showGroupNotification({
    required String groupName,
    required String senderName,
    required String body,
    required String groupId,
    String? payload,
  }) async {
    _assertInitialized();

    final id = groupId.hashCode & 0x7FFFFFFF;

    final androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: 'Notifications for incoming chat messages',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
      styleInformation: BigTextStyleInformation('$senderName: $body'),
      groupKey: groupId,
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id,
      groupName,
      '$senderName: $body',
      details,
      payload: payload ?? groupId,
    );
  }

  /// Registers a callback for when the user taps a notification.
  void onNotificationTap(void Function(String? payload) handler) {
    _tapHandlers.add(handler);
  }

  /// Cancels all displayed notifications.
  Future<void> cancelAll() async {
    _assertInitialized();
    await _plugin.cancelAll();
  }

  /// Cancels a specific notification by [id].
  Future<void> cancel(int id) async {
    _assertInitialized();
    await _plugin.cancel(id);
  }

  // ── internals ──────────────────────────────────────────────────────────────

  void _handleTap(String? payload) {
    log('[NotificationHandler] Notification tapped: $payload');
    for (final handler in _tapHandlers) {
      handler(payload);
    }
  }

  void _assertInitialized() {
    if (!_initialized) {
      throw StateError(
        'NotificationHandler has not been initialised. Call init() first.',
      );
    }
  }
}
