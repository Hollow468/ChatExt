import 'dart:typed_data';

import 'package:hive_flutter/hive_flutter.dart';
import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import 'crypto_utils.dart';

/// Persistent [SignalProtocolStore] implementation backed by Hive.
///
/// Stores Signal Protocol identity keys, pre-keys, signed pre-keys,
/// and session records in a dedicated Hive box named 'signal_keys'.
///
/// Key format conventions:
///   'identity_key_pair'    → serialized IdentityKeyPair
///   'registration_id'      → int
///   'prekey_{id}'          → serialized PreKeyRecord
///   'signed_prekey_{id}'   → serialized SignedPreKeyRecord
///   'session_{name}.{id}'  → serialized SessionRecord
///   'trusted_{name}'       → serialized IdentityKey
class SignalKeyStore implements SignalProtocolStore {
  SignalKeyStore({Box<dynamic>? box}) : _box = box ?? Hive.box('signal_keys');

  final Box<dynamic> _box;

  // ── Key prefixes ─────────────────────────────────────────────────────────

  static const _identityKeyPairKey = 'identity_key_pair';
  static const _registrationIdKey = 'registration_id';
  static const _preKeyPrefix = 'prekey_';
  static const _signedPreKeyPrefix = 'signed_prekey_';
  static const _sessionPrefix = 'session_';
  static const _trustedPrefix = 'trusted_';

  // ── Identity Key Store ───────────────────────────────────────────────────

  @override
  Future<IdentityKeyPair> getIdentityKeyPair() async {
    final data = _box.get(_identityKeyPairKey) as List<int>?;
    if (data == null) {
      throw StateError('Identity key pair not found in store');
    }
    return IdentityKeyPair.fromSerialized(Uint8List.fromList(data));
  }

  /// Persists the identity key pair.
  void saveIdentityKeyPair(IdentityKeyPair keyPair) {
    _box.put(_identityKeyPairKey, keyPair.serialize().toList());
  }

  @override
  Future<int> getLocalRegistrationId() async {
    final id = _box.get(_registrationIdKey) as int?;
    if (id == null) {
      throw StateError('Registration ID not found in store');
    }
    return id;
  }

  /// Persists the local registration ID.
  void saveLocalRegistrationId(int registrationId) {
    _box.put(_registrationIdKey, registrationId);
  }

  @override
  Future<bool> saveIdentity(
    SignalProtocolAddress address,
    IdentityKey? identityKey,
  ) async {
    if (identityKey == null) return false;
    final key = '$_trustedPrefix${address.getName()}';
    final existing = _box.get(key) as List<int>?;
    _box.put(key, identityKey.serialize().toList());
    // Returns true if this is a new identity or the identity changed.
    if (existing == null) return true;
    return !_bytesEqual(existing, identityKey.serialize().toList());
  }

  @override
  Future<bool> isTrustedIdentity(
    SignalProtocolAddress address,
    IdentityKey? identityKey,
    Direction direction,
  ) async {
    if (identityKey == null) return false;
    final key = '$_trustedPrefix${address.getName()}';
    final stored = _box.get(key) as List<int>?;
    if (stored == null) return true; // First contact — trust on first use
    final storedKey = IdentityKey.fromBytes(Uint8List.fromList(stored), 0);
    return _bytesEqual(storedKey.serialize(), identityKey.serialize());
  }

  @override
  Future<IdentityKey?> getIdentity(SignalProtocolAddress address) async {
    final key = '$_trustedPrefix${address.getName()}';
    final data = _box.get(key) as List<int>?;
    if (data == null) return null;
    return IdentityKey.fromBytes(Uint8List.fromList(data), 0);
  }

  // ── PreKey Store ─────────────────────────────────────────────────────────

  @override
  Future<PreKeyRecord> loadPreKey(int preKeyId) async {
    final data = _box.get('$_preKeyPrefix$preKeyId') as List<int>?;
    if (data == null) {
      throw InvalidKeyIdException('Pre-key $preKeyId not found');
    }
    return PreKeyRecord.fromBuffer(Uint8List.fromList(data));
  }

  @override
  Future<void> storePreKey(int preKeyId, PreKeyRecord record) async {
    _box.put('$_preKeyPrefix$preKeyId', record.serialize().toList());
  }

  @override
  Future<bool> containsPreKey(int preKeyId) async {
    return _box.containsKey('$_preKeyPrefix$preKeyId');
  }

  @override
  Future<void> removePreKey(int preKeyId) async {
    _box.delete('$_preKeyPrefix$preKeyId');
  }

  // ── SignedPreKey Store ───────────────────────────────────────────────────

  @override
  Future<SignedPreKeyRecord> loadSignedPreKey(int signedPreKeyId) async {
    final data =
        _box.get('$_signedPreKeyPrefix$signedPreKeyId') as List<int>?;
    if (data == null) {
      throw InvalidKeyIdException(
        'Signed pre-key $signedPreKeyId not found',
      );
    }
    return SignedPreKeyRecord.fromSerialized(Uint8List.fromList(data));
  }

  @override
  Future<List<SignedPreKeyRecord>> loadSignedPreKeys() async {
    return _box.keys
        .where((k) => k is String && k.startsWith(_signedPreKeyPrefix))
        .map((k) {
      final data = _box.get(k) as List<int>;
      return SignedPreKeyRecord.fromSerialized(Uint8List.fromList(data));
    }).toList();
  }

  @override
  Future<void> storeSignedPreKey(
    int signedPreKeyId,
    SignedPreKeyRecord record,
  ) async {
    _box.put(
      '$_signedPreKeyPrefix$signedPreKeyId',
      record.serialize().toList(),
    );
  }

  @override
  Future<bool> containsSignedPreKey(int signedPreKeyId) async {
    return _box.containsKey('$_signedPreKeyPrefix$signedPreKeyId');
  }

  @override
  Future<void> removeSignedPreKey(int signedPreKeyId) async {
    _box.delete('$_signedPreKeyPrefix$signedPreKeyId');
  }

  // ── Session Store ────────────────────────────────────────────────────────

  @override
  Future<SessionRecord> loadSession(SignalProtocolAddress address) async {
    final key = _sessionKey(address);
    final data = _box.get(key) as List<int>?;
    if (data == null) {
      return SessionRecord(); // Empty / fresh session
    }
    return SessionRecord.fromSerialized(Uint8List.fromList(data));
  }

  @override
  Future<List<int>> getSubDeviceSessions(String name) async {
    return _box.keys
        .where((k) =>
            k is String &&
            k.startsWith('$_sessionPrefix$name.') &&
            k != '$_sessionPrefix$name.$defaultDeviceId')
        .map((k) {
      final parts = (k as String).split('.');
      return int.parse(parts.last);
    }).toList();
  }

  @override
  Future<void> storeSession(
    SignalProtocolAddress address,
    SessionRecord record,
  ) async {
    _box.put(_sessionKey(address), record.serialize().toList());
  }

  @override
  Future<bool> containsSession(SignalProtocolAddress address) async {
    return _box.containsKey(_sessionKey(address));
  }

  @override
  Future<void> deleteSession(SignalProtocolAddress address) async {
    _box.delete(_sessionKey(address));
  }

  @override
  Future<void> deleteAllSessions(String name) async {
    final keysToRemove = _box.keys
        .where((k) =>
            k is String && k.startsWith('$_sessionPrefix$name.'))
        .toList();
    for (final k in keysToRemove) {
      _box.delete(k);
    }
  }

  // ── helpers ──────────────────────────────────────────────────────────────

  String _sessionKey(SignalProtocolAddress address) {
    return '$_sessionPrefix${address.getName()}.${address.getDeviceId()}';
  }

  static bool _bytesEqual(List<int> a, List<int> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }
}
