import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;

import '../../core/constants/app_constants.dart';
import '../../core/constants/waku_topics.dart';
import '../../core/utils/key_utils.dart';
import '../../data/local/daos/contact_dao.dart';
import '../../data/local/database.dart';
import '../storage/local_storage.dart';
import '../waku/waku_message_codec.dart';
import '../waku/waku_service.dart';
import 'identity_service.dart';

/// Maximum allowed nickname length.
const int kMaxNicknameLength = 32;

/// Regex matching allowed nickname characters: alphanumeric, underscores,
/// and CJK unified ideographs.
final RegExp _kNicknamePattern = RegExp(
  r'^[\w一-鿿㐀-䶿]+$',
);

/// Hive key under which the local user's nickname is persisted.
const String _kLocalNicknameKey = 'local_nickname';

/// Manages user nicknames on the P2P network.
///
/// Nicknames are registered by publishing a signed [NicknameClaim] to the
/// Waku presence topic. Other users verify the signature and cache the
/// mapping.
///
/// Display priority: user-set nickname > contact DB name > abbreviated peer ID
class NicknameService {
  NicknameService({
    required IdentityService identity,
    required WakuService waku,
    required ContactDao contactDao,
    LocalStorage? storage,
  })  : _identity = identity,
        _waku = waku,
        _contactDao = contactDao,
        _storage = storage ?? LocalStorage();

  final IdentityService _identity;
  final WakuService _waku;
  final ContactDao _contactDao;
  final LocalStorage _storage;

  /// In-memory cache: peerId -> nickname.
  final Map<String, String> _nicknameCache = {};

  bool _isListening = false;

  /// Sets the local user's nickname and broadcasts a signed claim.
  ///
  /// The nickname must be 1-32 characters from the set `[A-Za-z0-9_]` or
  /// CJK unified ideographs. Throws [ArgumentError] on invalid input.
  Future<void> setNickname(String nickname) async {
    final trimmed = nickname.trim();
    if (trimmed.isEmpty || trimmed.length > kMaxNicknameLength) {
      throw ArgumentError(
        'Nickname must be 1-$kMaxNicknameLength characters.',
      );
    }
    if (!_kNicknamePattern.hasMatch(trimmed)) {
      throw ArgumentError(
        'Nickname may only contain letters, digits, underscores, '
        'or Chinese characters.',
      );
    }

    // Persist locally.
    await _storage.put(AppConstants.settingsBox, _kLocalNicknameKey, trimmed);

    // Update in-memory cache.
    _nicknameCache[_identity.getPeerId()] = trimmed;

    // Broadcast the claim.
    await _broadcastClaim(trimmed);

    log('[NicknameService] Nickname set to "$trimmed"');
  }

  /// Returns the display name for [peerId] using the priority chain:
  /// nickname cache > contact DB > abbreviated peer ID.
  String getDisplayName(String peerId) {
    // 1. In-memory nickname cache.
    final cached = _nicknameCache[peerId];
    if (cached != null && cached.isNotEmpty) return cached;

    // 2. Contact DB display name (synchronous Hive lookup via LocalStorage
    //    mirrors the PeerResolver pattern).
    final stored = _storage.get(AppConstants.contactsBox, peerId) as String?;
    if (stored != null && stored.isNotEmpty) return stored;

    // 3. Abbreviated peer ID.
    return _abbreviatedId(peerId);
  }

  /// Returns the local user's nickname, or `null` if not set.
  String? getLocalNickname() {
    return _storage.get(AppConstants.settingsBox, _kLocalNicknameKey)
        as String?;
  }

  /// Resolves a peer's nickname from cache or contact DB.
  ///
  /// Returns `null` if no nickname is found (caller may fall back to
  /// abbreviated ID).
  String? resolveNickname(String peerId) {
    final cached = _nicknameCache[peerId];
    if (cached != null && cached.isNotEmpty) return cached;

    final stored = _storage.get(AppConstants.contactsBox, peerId) as String?;
    if (stored != null && stored.isNotEmpty) return stored;

    return null;
  }

  /// Subscribes to the Waku presence topic to receive nickname claims.
  ///
  /// Call once after Waku initialisation.
  void startListening() {
    if (_isListening) return;
    _isListening = true;

    _waku.onMessage(WakuTopics.presence, _onPresenceMessage);
  }

  // ---------------------------------------------------------------------------
  // Internals
  // ---------------------------------------------------------------------------

  /// Publishes a signed nickname claim to the presence topic.
  Future<void> _broadcastClaim(String nickname) async {
    final peerId = _identity.getPeerId();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final signPayload = '$peerId:$nickname:$timestamp';
    final signature = _identity.signMessage(
      Uint8List.fromList(utf8.encode(signPayload)),
    );

    final claim = NicknameClaim(
      peerId: peerId,
      nickname: nickname,
      timestamp: timestamp,
      signature: base64Encode(signature),
    );

    final payload = jsonEncode(claim.toJson());
    await _waku.publish(
      WakuTopics.presence,
      Uint8List.fromList(utf8.encode(payload)),
    );
  }

  /// Handles incoming presence messages, filtering for nickname claims.
  void _onPresenceMessage(ChatMessage message) {
    try {
      final data = jsonDecode(message.content) as Map<String, dynamic>;
      final type = data['type'] as String?;
      if (type != 'nickname_claim') return;

      if (!_verifyClaim(data)) {
        log('[NicknameService] Invalid signature on nickname claim, ignoring');
        return;
      }

      final peerId = data['peerId'] as String;
      final nickname = data['nickname'] as String;

      if (peerId == _identity.getPeerId()) return; // Ignore own claims.

      _nicknameCache[peerId] = nickname;
      _updateContactName(peerId, nickname);
      log('[NicknameService] Cached nickname "$nickname" for $peerId');
    } catch (e) {
      log('[NicknameService] Failed to process presence message: $e');
    }
  }

  /// Updates the contact DB record for [peerId] with the new display name.
  Future<void> _updateContactName(String peerId, String nickname) async {
    try {
      final existing = await _contactDao.getContactByPeerId(peerId);
      if (existing != null) {
        await _contactDao.insertOrUpdate(
          ContactsCompanion(
            peerId: drift.Value(peerId),
            displayName: drift.Value(nickname),
            publicKeyData: drift.Value(existing.publicKeyData),
          ),
        );
      }
    } catch (e) {
      log('[NicknameService] Failed to update contact name: $e');
    }
  }

  /// Verifies the Ed25519 signature on a nickname claim.
  bool _verifyClaim(Map<String, dynamic> claim) {
    try {
      final peerId = claim['peerId'] as String;
      final nickname = claim['nickname'] as String;
      final timestamp = claim['timestamp'] as int;
      final signatureB64 = claim['signature'] as String;

      final signPayload = '$peerId:$nickname:$timestamp';
      final messageBytes = Uint8List.fromList(utf8.encode(signPayload));
      final signatureBytes = base64Decode(signatureB64);
      final publicKeyBytes = KeyUtils.peerIdToPublicKeyBytes(peerId);
      final publicKey = ed.PublicKey(publicKeyBytes);

      return KeyUtils.verifySignature(publicKey, messageBytes, signatureBytes);
    } catch (e) {
      log('[NicknameService] Signature verification error: $e');
      return false;
    }
  }

  /// Abbreviates a peer ID for display when no name is available.
  static String _abbreviatedId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 6)}...${id.substring(id.length - 4)}';
  }

  /// Cleans up resources.
  void dispose() {
    _nicknameCache.clear();
    _isListening = false;
  }
}

/// A signed claim binding a peer ID to a nickname.
class NicknameClaim {
  const NicknameClaim({
    required this.peerId,
    required this.nickname,
    required this.timestamp,
    required this.signature,
  });

  final String peerId;
  final String nickname;
  final int timestamp;
  final String signature;

  Map<String, dynamic> toJson() => {
        'type': 'nickname_claim',
        'peerId': peerId,
        'nickname': nickname,
        'timestamp': timestamp,
        'signature': signature,
      };

  factory NicknameClaim.fromJson(Map<String, dynamic> json) => NicknameClaim(
        peerId: json['peerId'] as String,
        nickname: json['nickname'] as String,
        timestamp: json['timestamp'] as int,
        signature: json['signature'] as String,
      );
}
