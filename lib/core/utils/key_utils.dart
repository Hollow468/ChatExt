import 'dart:typed_data';

import 'package:ed25519_edwards/ed25519_edwards.dart' as ed;
import 'package:bs58/bs58.dart';

/// Ed25519 key pair utilities for identity and message signing.
class KeyUtils {
  /// Generates a new Ed25519 key pair.
  static ed.KeyPair generateKeyPair() {
    return ed.generateKey();
  }

  /// Extracts the raw 32-byte public key from an Ed25519 [KeyPair].
  static Uint8List publicKeyBytes(ed.PublicKey publicKey) {
    return Uint8List.fromList(publicKey.bytes);
  }

  /// Converts a raw 32-byte Ed25519 public key to a Base58-encoded peer ID.
  ///
  /// The peer ID is the Base58 encoding of the raw public key bytes.
  static String publicKeyToPeerId(ed.PublicKey publicKey) {
    return base58.encode(Uint8List.fromList(publicKey.bytes));
  }

  /// Decodes a Base58-encoded peer ID back to raw public key bytes.
  static Uint8List peerIdToPublicKeyBytes(String peerId) {
    return base58.decode(peerId);
  }

  /// Signs [message] with the given Ed25519 private key.
  static Uint8List signMessage(ed.PrivateKey privateKey, Uint8List message) {
    return ed.sign(privateKey, message);
  }

  /// Verifies that [signature] is valid for [message] under [publicKey].
  static bool verifySignature(
    ed.PublicKey publicKey,
    Uint8List message,
    Uint8List signature,
  ) {
    return ed.verify(publicKey, message, signature);
  }
}
