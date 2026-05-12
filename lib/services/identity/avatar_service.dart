import 'dart:convert';
import 'dart:developer';
import 'dart:typed_data';

import 'package:drift/drift.dart' as drift;
import 'package:image/image.dart' as img;

import '../../core/constants/app_constants.dart';
import '../../core/constants/waku_topics.dart';
import '../../data/local/daos/contact_dao.dart';
import '../../data/local/database.dart';
import '../storage/local_storage.dart';
import '../waku/waku_message_codec.dart';
import '../waku/waku_service.dart';
import 'identity_service.dart';

/// Hive key under which the local user's avatar JPEG bytes are persisted.
const String _kLocalAvatarKey = 'local_avatar';

/// Maximum avatar dimension (width and height) in pixels.
const int _kAvatarMaxDimension = 100;

/// JPEG quality for avatar compression.
const int _kAvatarJpegQuality = 60;

/// Manages user avatar images.
///
/// Avatars are stored locally and broadcast as base64-encoded JPEG thumbnails
/// via the Waku presence topic.
///
/// Avatar update message format:
/// ```json
/// {
///   "type": "avatar_update",
///   "peerId": "...",
///   "avatar": "<base64 JPEG, max 100x100, quality 60>",
///   "timestamp": ...
/// }
/// ```
class AvatarService {
  AvatarService({
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

  /// In-memory cache: peerId -> compressed JPEG bytes.
  final Map<String, Uint8List> _avatarCache = {};

  bool _isListening = false;

  /// Sets the local user's avatar from raw [imageBytes].
  ///
  /// The image is compressed to a 100x100 JPEG at quality 60, persisted
  /// locally, and broadcast to the Waku presence topic.
  Future<void> setAvatar(Uint8List imageBytes) async {
    final compressed = _compressAvatar(imageBytes);

    // Persist locally.
    await _storage.put(
      AppConstants.settingsBox,
      _kLocalAvatarKey,
      base64Encode(compressed),
    );

    // Update in-memory cache.
    _avatarCache[_identity.getPeerId()] = compressed;

    // Broadcast.
    await _broadcastAvatar(compressed);

    log('[AvatarService] Avatar set (${compressed.length} bytes)');
  }

  /// Returns the avatar JPEG bytes for [peerId].
  ///
  /// Checks the in-memory cache first, then the contact DB.
  Future<Uint8List?> getAvatar(String peerId) async {
    // In-memory cache.
    final cached = _avatarCache[peerId];
    if (cached != null) return cached;

    // Contact DB.
    final contact = await _contactDao.getContactByPeerId(peerId);
    if (contact != null &&
        contact.avatarUrl != null &&
        contact.avatarUrl!.isNotEmpty) {
      try {
        final bytes = base64Decode(contact.avatarUrl!);
        _avatarCache[peerId] = bytes;
        return bytes;
      } catch (_) {
        // Corrupt data in DB, ignore.
      }
    }

    return null;
  }

  /// Returns the local user's avatar JPEG bytes, or `null` if not set.
  Future<Uint8List?> getLocalAvatar() async {
    // In-memory cache.
    final cached = _avatarCache[_identity.getPeerId()];
    if (cached != null) return cached;

    // Hive storage.
    final stored = _storage.get(AppConstants.settingsBox, _kLocalAvatarKey)
        as String?;
    if (stored != null && stored.isNotEmpty) {
      try {
        final bytes = base64Decode(stored);
        _avatarCache[_identity.getPeerId()] = bytes;
        return bytes;
      } catch (_) {
        return null;
      }
    }

    return null;
  }

  /// Subscribes to the Waku presence topic to receive avatar updates.
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

  /// Compresses [imageBytes] to a 100x100 JPEG thumbnail.
  Uint8List _compressAvatar(Uint8List imageBytes) {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw const FormatException('Failed to decode image for avatar');
    }

    final resized = img.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? _kAvatarMaxDimension : null,
      height: decoded.height > decoded.width ? _kAvatarMaxDimension : null,
      interpolation: img.Interpolation.linear,
    );

    final encoded = img.encodeJpg(resized, quality: _kAvatarJpegQuality);
    return Uint8List.fromList(encoded);
  }

  /// Publishes an avatar update to the Waku presence topic.
  Future<void> _broadcastAvatar(Uint8List compressed) async {
    final peerId = _identity.getPeerId();
    final payload = jsonEncode({
      'type': 'avatar_update',
      'peerId': peerId,
      'avatar': base64Encode(compressed),
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    await _waku.publish(
      WakuTopics.presence,
      Uint8List.fromList(utf8.encode(payload)),
    );
  }

  /// Handles incoming presence messages, filtering for avatar updates.
  void _onPresenceMessage(ChatMessage message) {
    try {
      final data = jsonDecode(message.content) as Map<String, dynamic>;
      final type = data['type'] as String?;
      if (type != 'avatar_update') return;

      final peerId = data['peerId'] as String?;
      final avatarB64 = data['avatar'] as String?;
      if (peerId == null || avatarB64 == null) return;

      if (peerId == _identity.getPeerId()) return; // Ignore own updates.

      final bytes = base64Decode(avatarB64);
      _avatarCache[peerId] = bytes;

      // Persist to contact DB so it survives restarts.
      _updateContactAvatar(peerId, avatarB64);

      log('[AvatarService] Cached avatar for $peerId (${bytes.length} bytes)');
    } catch (e) {
      log('[AvatarService] Failed to process presence message: $e');
    }
  }

  /// Updates the contact DB record for [peerId] with the new avatar.
  Future<void> _updateContactAvatar(
    String peerId,
    String avatarBase64,
  ) async {
    try {
      final existing = await _contactDao.getContactByPeerId(peerId);
      if (existing != null) {
        await _contactDao.insertOrUpdate(
          ContactsCompanion(
            peerId: drift.Value(peerId),
            displayName: drift.Value(existing.displayName),
            avatarUrl: drift.Value(avatarBase64),
            publicKeyData: drift.Value(existing.publicKeyData),
          ),
        );
      }
    } catch (e) {
      log('[AvatarService] Failed to update contact avatar: $e');
    }
  }

  /// Cleans up resources.
  void dispose() {
    _avatarCache.clear();
    _isListening = false;
  }
}
