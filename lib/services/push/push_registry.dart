import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import '../../core/constants/waku_topics.dart';
import '../identity/identity_service.dart';
import '../waku/waku_service.dart';
import 'fcm_service.dart';

/// Registers the local device's FCM token on the Waku network.
///
/// When a peer wants to send a push notification, they look up the
/// recipient's FCM token from the Waku push-registry topic.
///
/// Protocol:
/// - Publish own FCM token to [WakuTopics.presence] on init
/// - Re-publish on token refresh
/// - Look up peer tokens from cached presence data
class PushRegistry {
  PushRegistry({
    required WakuService waku,
    required FcmService fcm,
    required IdentityService identity,
  })  : _waku = waku,
        _fcm = fcm,
        _identity = identity;

  final WakuService _waku;
  final FcmService _fcm;
  final IdentityService _identity;

  /// Token cache: peerId → FCM token.
  final Map<String, String> _tokenCache = {};

  /// Subscribes to presence updates and publishes the local token.
  ///
  /// Call this after [WakuService.init] and [FcmService.init] have completed.
  Future<void> registerToken() async {
    // Listen for other peers' presence updates.
    _waku.onMessage(WakuTopics.presence, (message) {
      try {
        final data = jsonDecode(message.content) as Map<String, dynamic>;
        _onPresenceUpdate(data);
      } catch (e) {
        log('[PushRegistry] Failed to decode presence: $e');
      }
    });

    await _publishOwnToken();
  }

  /// Looks up a peer's FCM token.
  ///
  /// Returns `null` if not found in cache.
  String? getPeerToken(String peerId) => _tokenCache[peerId];

  /// Publishes the local FCM token to the Waku presence topic.
  Future<void> _publishOwnToken() async {
    final token = await _fcm.getToken();
    if (token == null) {
      log('[PushRegistry] No FCM token available, skipping publish');
      return;
    }

    final peerId = _identity.getPeerId();
    final payload = jsonEncode({
      'type': 'presence',
      'peerId': peerId,
      'fcmToken': token,
      'online': true,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    await _waku.publish(
      WakuTopics.presence,
      Uint8List.fromList(utf8.encode(payload)),
    );
    log('[PushRegistry] Published FCM token for $peerId');

    // Also cache our own token.
    _tokenCache[peerId] = token;
  }

  /// Handles incoming presence updates to cache peer tokens.
  void _onPresenceUpdate(Map<String, dynamic> data) {
    final peerId = data['peerId'] as String?;
    final fcmToken = data['fcmToken'] as String?;
    if (peerId == null || fcmToken == null) return;

    final online = data['online'] as bool? ?? true;
    if (online) {
      _tokenCache[peerId] = fcmToken;
      log('[PushRegistry] Cached token for $peerId');
    } else {
      _tokenCache.remove(peerId);
      log('[PushRegistry] Removed token for $peerId (offline)');
    }
  }

  /// Cleans up resources.
  void dispose() {
    _tokenCache.clear();
  }
}
