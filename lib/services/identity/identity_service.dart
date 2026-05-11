import 'dart:typed_data';

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;

import '../../core/constants/app_constants.dart';
import '../../core/utils/key_utils.dart';
import '../storage/local_storage.dart';

/// Manages the local user's Ed25519 identity.
///
/// On [init] the service loads an existing key pair from Hive, or generates a
/// new one and persists it. The private key is stored as raw bytes in the
/// [AppConstants.identityBox] Hive box.
class IdentityService {
  IdentityService({LocalStorage? storage}) : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;

  ed.PrivateKey? _privateKey;
  ed.PublicKey? _publicKey;
  String? _peerId;

  // ── Hive keys ──────────────────────────────────────────────────────────────
  static const _kPrivateKey = 'private_key';
  static const _kPublicKey = 'public_key';
  static const _kPeerId = 'peer_id';

  // ── public API ─────────────────────────────────────────────────────────────

  /// Loads the identity from persistent storage, or generates a new one.
  Future<void> init() async {
    final existingPriv = _storage.get(AppConstants.identityBox, _kPrivateKey);

    if (existingPriv != null) {
      // Restore from storage.
      final privBytes = Uint8List.fromList(existingPriv as List<int>);
      _privateKey = ed.PrivateKey(privBytes);

      final pubBytes = Uint8List.fromList(
        _storage.get(AppConstants.identityBox, _kPublicKey) as List<int>,
      );
      _publicKey = ed.PublicKey(pubBytes);
      _peerId = _storage.get(AppConstants.identityBox, _kPeerId) as String;
    } else {
      // Generate fresh identity.
      final keyPair = KeyUtils.generateKeyPair();
      _privateKey = keyPair.privateKey;
      _publicKey = keyPair.publicKey;
      _peerId = KeyUtils.publicKeyToPeerId(_publicKey!);

      // Persist.
      await _storage.put(
        AppConstants.identityBox,
        _kPrivateKey,
        _privateKey!.bytes.toList(),
      );
      await _storage.put(
        AppConstants.identityBox,
        _kPublicKey,
        _publicKey!.bytes.toList(),
      );
      await _storage.put(AppConstants.identityBox, _kPeerId, _peerId);
    }
  }

  /// Returns `true` if the identity has been initialised (i.e. [init] has
  /// completed successfully).
  bool isInitialized() => _privateKey != null && _publicKey != null;

  /// Returns the Base58-encoded peer ID of the current user.
  String getPeerId() {
    _assertInitialized();
    return _peerId!;
  }

  /// Returns the raw 32-byte Ed25519 public key.
  Uint8List getPublicKey() {
    _assertInitialized();
    return KeyUtils.publicKeyBytes(_publicKey!);
  }

  /// Signs [data] with the user's private key.
  Uint8List signMessage(Uint8List data) {
    _assertInitialized();
    return KeyUtils.signMessage(_privateKey!, data);
  }

  // ── internals ──────────────────────────────────────────────────────────────

  void _assertInitialized() {
    if (!isInitialized()) {
      throw StateError(
        'IdentityService has not been initialised. Call init() first.',
      );
    }
  }
}
