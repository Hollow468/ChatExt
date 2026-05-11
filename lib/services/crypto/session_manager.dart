import 'dart:convert';
import 'dart:typed_data';

import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

import 'crypto_utils.dart';
import 'key_store.dart';

/// Manages Signal Protocol sessions with remote peers.
///
/// Handles session creation, lookup, and the X3DH pre-key message flow.
/// Wraps [SessionBuilder] and [SessionCipher] with a simpler API.
class SessionManager {
  SessionManager({required SignalKeyStore keyStore}) : _keyStore = keyStore;

  final SignalKeyStore _keyStore;

  /// Builds a [SessionCipher] for communicating with [peerId].
  SessionCipher getCipher(String peerId) {
    final address = CryptoUtils.peerIdToAddress(peerId);
    return SessionCipher.fromStore(_keyStore, address);
  }

  /// Processes an incoming pre-key message from a new peer.
  ///
  /// This completes the X3DH handshake on the receiving side (Bob).
  /// Returns the decrypted plaintext if successful.
  Future<String> processPreKeyMessage(
    String peerId,
    Uint8List ciphertext,
  ) async {
    final address = CryptoUtils.peerIdToAddress(peerId);
    final cipher = SessionCipher.fromStore(_keyStore, address);
    final preKeyMessage = PreKeySignalMessage(ciphertext);
    final padded = await cipher.decrypt(preKeyMessage);
    return utf8.decode(padded, allowMalformed: true);
  }

  /// Encrypts [plaintext] for [peerId] using the established session.
  ///
  /// Returns the serialized ciphertext bytes.
  Future<Uint8List> encryptMessage(String peerId, String plaintext) async {
    final cipher = getCipher(peerId);
    final paddedMessage =
        _padMessage(Uint8List.fromList(utf8.encode(plaintext)));
    final ciphertext = await cipher.encrypt(paddedMessage);
    return ciphertext.serialize();
  }

  /// Decrypts [ciphertext] from [peerId] using the established session.
  ///
  /// Returns the decrypted plaintext string.
  Future<String> decryptMessage(
    String peerId,
    Uint8List ciphertext,
  ) async {
    final cipher = getCipher(peerId);
    final message = SignalMessage.fromSerialized(ciphertext);
    final padded = await cipher.decryptFromSignal(message);
    return utf8.decode(padded, allowMalformed: true);
  }

  /// Returns `true` if a session exists with [peerId].
  Future<bool> hasSession(String peerId) async {
    final address = CryptoUtils.peerIdToAddress(peerId);
    return _keyStore.containsSession(address);
  }

  /// Deletes the session with [peerId].
  Future<void> deleteSession(String peerId) async {
    final address = CryptoUtils.peerIdToAddress(peerId);
    await _keyStore.deleteSession(address);
  }

  // ── internal ─────────────────────────────────────────────────────────────

  /// Pads a message to a multiple of 16 bytes for AES block alignment.
  static Uint8List _padMessage(Uint8List message) {
    const blockSize = 16;
    final padLen = blockSize - (message.length % blockSize);
    final padded = Uint8List(message.length + padLen);
    padded.setRange(0, message.length, message);
    for (var i = message.length; i < padded.length; i++) {
      padded[i] = padLen;
    }
    return padded;
  }
}
