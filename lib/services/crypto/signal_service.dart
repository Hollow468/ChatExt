import 'package:flutter/foundation.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import 'crypto_utils.dart';
import 'key_store.dart';
import 'session_manager.dart';

/// High-level Signal Protocol encryption service.
///
/// Manages identity key generation, pre-key publication, session establishment
/// via X3DH, and message encryption/decryption via Double Ratchet.
class SignalService {
  SignalService({
    SignalKeyStore? keyStore,
    SessionManager? sessionManager,
  })  : _keyStore = keyStore ?? SignalKeyStore(),
        _sessionManager = sessionManager ??
            SessionManager(keyStore: keyStore ?? SignalKeyStore());

  final SignalKeyStore _keyStore;
  final SessionManager _sessionManager;

  bool _initialized = false;

  /// Initializes the Signal Protocol service.
  ///
  /// Generates an identity key pair and pre-keys if they don't already exist
  /// in the key store.
  Future<void> init() async {
    if (_initialized) return;

    try {
      await _keyStore.getIdentityKeyPair();
      await _keyStore.getLocalRegistrationId();
    } on StateError {
      await _generateInitialKeys();
    }

    _initialized = true;
  }

  /// Returns the local key bundle for publishing to Waku.
  ///
  /// The bundle includes the identity key, signed pre-key, and optionally
  /// a one-time pre-key for X3DH.
  Future<Map<String, dynamic>> getKeyBundle() async {
    _assertInitialized();

    final identityKeyPair = await _keyStore.getIdentityKeyPair();
    final registrationId = await _keyStore.getLocalRegistrationId();

    // Get the latest signed pre-key
    final signedPreKeys = await _keyStore.loadSignedPreKeys();
    if (signedPreKeys.isEmpty) {
      throw StateError('No signed pre-keys available');
    }
    final signedPreKey = signedPreKeys.last;

    // Get a one-time pre-key if available
    PreKeyRecord? oneTimePreKey;
    for (var i = 1; i <= 100; i++) {
      if (await _keyStore.containsPreKey(i)) {
        oneTimePreKey = await _keyStore.loadPreKey(i);
        break;
      }
    }

    return CryptoUtils.serializeKeyBundle(
      registrationId: registrationId,
      identityKey: identityKeyPair.getPublicKey(),
      signedPreKey: signedPreKey,
      oneTimePreKey: oneTimePreKey,
    );
  }

  /// Processes a received key bundle and establishes a session with the peer.
  ///
  /// This initiates the X3DH key agreement on the sender side.
  Future<void> processKeyBundle(
    String peerId,
    Map<String, dynamic> bundle,
  ) async {
    _assertInitialized();

    final preKeyBundle = CryptoUtils.deserializeKeyBundle(bundle);
    final address = CryptoUtils.peerIdToAddress(peerId);
    final sessionBuilder = SessionBuilder.fromSignalStore(_keyStore, address);
    await sessionBuilder.processPreKeyBundle(preKeyBundle);
  }

  /// Encrypts [plaintext] for [peerId] using the Double Ratchet.
  Future<Uint8List> encryptMessage(String peerId, String plaintext) async {
    _assertInitialized();
    return _sessionManager.encryptMessage(peerId, plaintext);
  }

  /// Decrypts [ciphertext] from [peerId] using the Double Ratchet.
  Future<String> decryptMessage(
    String peerId,
    Uint8List ciphertext,
  ) async {
    _assertInitialized();

    if (await _sessionManager.hasSession(peerId)) {
      return _sessionManager.decryptMessage(peerId, ciphertext);
    }

    // No session — try as a pre-key message (first contact)
    return _sessionManager.processPreKeyMessage(peerId, ciphertext);
  }

  /// Returns `true` if a session has been established with [peerId].
  Future<bool> hasSession(String peerId) {
    return _sessionManager.hasSession(peerId);
  }

  // ── internal ─────────────────────────────────────────────────────────────

  /// Generates fresh identity key, signed pre-key, and one-time pre-keys.
  Future<void> _generateInitialKeys() async {
    final identityKeyPair = generateIdentityKeyPair();
    final registrationId = CryptoUtils.generateRegistrationId();

    _keyStore.saveIdentityKeyPair(identityKeyPair);
    _keyStore.saveLocalRegistrationId(registrationId);

    // Generate signed pre-key (ID = 1)
    final signedPreKey = generateSignedPreKey(identityKeyPair, 1);
    await _keyStore.storeSignedPreKey(1, signedPreKey);

    // Generate one-time pre-keys (IDs 1–10).
    final preKeys = generatePreKeys(1, 10);
    for (final preKey in preKeys) {
      await _keyStore.storePreKey(preKey.id, preKey);
    }

    debugPrint(
      'SignalService: Generated identity key, 1 signed pre-key, '
      '10 one-time pre-keys',
    );
  }

  void _assertInitialized() {
    if (!_initialized) {
      throw StateError(
        'SignalService has not been initialized. Call init() first.',
      );
    }
  }
}
