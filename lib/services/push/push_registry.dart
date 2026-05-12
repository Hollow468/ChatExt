import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import '../../core/constants/waku_topics.dart';
import '../identity/identity_service.dart';
import '../waku/waku_service.dart';

/// Tracks peer online presence via the Waku network.
///
/// Protocol:
/// - Publish own presence to [WakuTopics.presence] on init
/// - Re-publish periodically to signal liveness
/// - Cache peer online status from incoming presence messages
class PushRegistry {
  PushRegistry({
    required WakuService waku,
    required IdentityService identity,
  })  : _waku = waku,
        _identity = identity;

  final WakuService _waku;
  final IdentityService _identity;

  /// Online status cache: peerId → true.
  final Map<String, bool> _onlinePeers = {};

  /// Subscribes to presence updates and publishes own presence.
  ///
  /// Call this after [WakuService.init] has completed.
  Future<void> registerPresence() async {
    _waku.onMessage(WakuTopics.presence, (message) {
      try {
        final data = jsonDecode(message.content) as Map<String, dynamic>;
        _onPresenceUpdate(data);
      } catch (e) {
        log('[PushRegistry] Failed to decode presence: $e');
      }
    });

    await _publishPresence();
  }

  /// Whether [peerId] was recently seen online.
  bool isPeerOnline(String peerId) => _onlinePeers[peerId] == true;

  /// Publishes own presence to the Waku presence topic.
  Future<void> _publishPresence() async {
    final peerId = _identity.getPeerId();
    final payload = jsonEncode({
      'type': 'presence',
      'peerId': peerId,
      'online': true,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    await _waku.publish(
      WakuTopics.presence,
      Uint8List.fromList(utf8.encode(payload)),
    );
    log('[PushRegistry] Published presence for $peerId');
  }

  /// Handles incoming presence updates.
  void _onPresenceUpdate(Map<String, dynamic> data) {
    final peerId = data['peerId'] as String?;
    if (peerId == null) return;

    final online = data['online'] as bool? ?? true;
    if (online) {
      _onlinePeers[peerId] = true;
      log('[PushRegistry] Peer $peerId is online');
    } else {
      _onlinePeers.remove(peerId);
      log('[PushRegistry] Peer $peerId went offline');
    }
  }

  /// Cleans up resources.
  void dispose() {
    _onlinePeers.clear();
  }
}
