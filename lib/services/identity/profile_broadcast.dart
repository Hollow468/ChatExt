import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:bs58/bs58.dart';

import '../../core/constants/waku_topics.dart';
import '../../core/utils/key_utils.dart';
import '../waku/waku_message_codec.dart';
import '../waku/waku_service.dart';
import 'avatar_service.dart';
import 'identity_service.dart';
import 'nickname_service.dart';

/// Interval between periodic profile broadcasts.
const Duration _kBroadcastInterval = Duration(minutes: 5);

/// Broadcasts the local user's profile (nickname, avatar, online status) on
/// the Waku presence topic and listens for other users' profiles.
///
/// Profile message format:
/// ```json
/// {
///   "type": "profile",
///   "peerId": "...",
///   "nickname": "...",
///   "avatar": "<base64>" (optional, only on change),
///   "online": true,
///   "timestamp": ...,
///   "signature": "..."
/// }
/// ```
///
/// Broadcasts on [WakuTopics.presence] every 5 minutes while online, and
/// immediately on any profile change.
class ProfileBroadcastService {
  ProfileBroadcastService({
    required IdentityService identity,
    required WakuService waku,
    required NicknameService nickname,
    required AvatarService avatar,
  })  : _identity = identity,
        _waku = waku,
        _nickname = nickname,
        _avatar = avatar;

  final IdentityService _identity;
  final WakuService _waku;
  final NicknameService _nickname;
  final AvatarService _avatar;

  Timer? _broadcastTimer;
  bool _isRunning = false;

  /// Starts periodic profile broadcasting and listens for incoming profiles.
  ///
  /// Call after Waku and identity services have been initialised.
  Future<void> start() async {
    if (_isRunning) return;
    _isRunning = true;

    _waku.onMessage(WakuTopics.presence, _onPresenceMessage);

    // Broadcast immediately on start.
    await broadcastNow();

    // Then every 5 minutes.
    _broadcastTimer = Timer.periodic(_kBroadcastInterval, (_) {
      broadcastNow();
    });
  }

  /// Stops periodic broadcasting.
  void stop() {
    _broadcastTimer?.cancel();
    _broadcastTimer = null;
    _isRunning = false;
  }

  /// Immediately broadcasts the current profile to the presence topic.
  Future<void> broadcastNow() async {
    try {
      final peerId = _identity.getPeerId();
      final nickname = _nickname.getLocalNickname();
      final avatarBytes = await _avatar.getLocalAvatar();

      final timestamp = DateTime.now().millisecondsSinceEpoch;

      // Sign: "peerId:nickname:timestamp"
      final signPayload = '$peerId:${nickname ?? ""}:$timestamp';
      final signature = _identity.signMessage(
        Uint8List.fromList(utf8.encode(signPayload)),
      );

      final profile = <String, dynamic>{
        'type': 'profile',
        'peerId': peerId,
        'online': true,
        'timestamp': timestamp,
        'signature': base64Encode(signature),
      };

      if (nickname != null) {
        profile['nickname'] = nickname;
      }
      if (avatarBytes != null) {
        profile['avatar'] = base64Encode(avatarBytes);
      }

      final payload = jsonEncode(profile);
      await _waku.publish(
        WakuTopics.presence,
        Uint8List.fromList(utf8.encode(payload)),
      );

      log('[ProfileBroadcast] Published profile for $peerId');
    } catch (e) {
      log('[ProfileBroadcast] Failed to broadcast profile: $e');
    }
  }

  /// Handles incoming profile messages from other users.
  void _onPresenceMessage(ChatMessage message) {
    try {
      final data = jsonDecode(message.content) as Map<String, dynamic>;
      final type = data['type'] as String?;
      if (type != 'profile') return;

      final peerId = data['peerId'] as String?;
      if (peerId == null) return;
      if (peerId == _identity.getPeerId()) return; // Ignore own.

      final online = data['online'] as bool? ?? true;
      log('[ProfileBroadcast] Profile from $peerId (online: $online)');

      // NicknameService and AvatarService each independently handle their own
      // message types (nickname_claim and avatar_update). Profile messages are
      // a combined format. The individual services subscribe to the same
      // presence topic and filter on their respective `type` values.
    } catch (e) {
      log('[ProfileBroadcast] Failed to process profile message: $e');
    }
  }

  /// Verifies the Ed25519 signature on a profile message.
  ///
  /// Returns `true` if the signature is valid for the given peer's public key.
  static bool verifyProfileSignature(Map<String, dynamic> data) {
    try {
      final peerId = data['peerId'] as String;
      final nickname = data['nickname'] as String? ?? '';
      final timestamp = data['timestamp'] as int;
      final signatureB64 = data['signature'] as String?;

      if (signatureB64 == null) return false;

      final signPayload = '$peerId:$nickname:$timestamp';
      final messageBytes = Uint8List.fromList(utf8.encode(signPayload));
      final signatureBytes = base64Decode(signatureB64);

      final publicKeyBytes = base58.decode(peerId);
      final publicKey = ed.PublicKey(publicKeyBytes);

      return KeyUtils.verifySignature(publicKey, messageBytes, signatureBytes);
    } catch (e) {
      log('[ProfileBroadcast] Signature verification error: $e');
      return false;
    }
  }

  /// Cleans up resources.
  void dispose() {
    stop();
  }
}
