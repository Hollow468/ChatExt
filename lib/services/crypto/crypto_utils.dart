import 'dart:convert';

import 'package:libsignal_protocol_dart/libsignal_protocol_dart.dart';

/// The default device ID used for all Signal Protocol addresses.
///
/// ChatExt targets single-device peers, so every address uses device ID 1.
const int defaultDeviceId = 1;

/// Utility functions for mapping between peer IDs and Signal Protocol types.
class CryptoUtils {
  CryptoUtils._();

  // ── address mapping ────────────────────────────────────────────────────────

  /// Converts a Base58 [peerId] to a [SignalProtocolAddress].
  ///
  /// Uses the full peer ID as the address name with [defaultDeviceId].
  static SignalProtocolAddress peerIdToAddress(String peerId) {
    return SignalProtocolAddress(peerId, defaultDeviceId);
  }

  /// Extracts the peer ID string from a [SignalProtocolAddress].
  static String addressToPeerId(SignalProtocolAddress address) {
    return address.getName();
  }

  // ── key bundle serialization ───────────────────────────────────────────────

  /// Serializes a key bundle to a [Map] for transport over Waku.
  ///
  /// Returns a JSON-encodable map with Base64-encoded key material.
  static Map<String, dynamic> serializeKeyBundle({
    required int registrationId,
    required IdentityKey identityKey,
    required SignedPreKeyRecord signedPreKey,
    PreKeyRecord? oneTimePreKey,
  }) {
    final signedPreKeyPair = signedPreKey.getKeyPair();
    return {
      'registrationId': registrationId,
      'deviceId': defaultDeviceId,
      'identityKey': base64Encode(identityKey.serialize()),
      'signedPreKeyId': signedPreKey.id,
      'signedPreKeyPublic':
          base64Encode(signedPreKeyPair.publicKey.serialize()),
      'signedPreKeySignature': base64Encode(signedPreKey.signature),
      if (oneTimePreKey != null) ...{
        'preKeyId': oneTimePreKey.id,
        'preKeyPublic':
            base64Encode(oneTimePreKey.getKeyPair().publicKey.serialize()),
      },
    };
  }

  /// Deserializes a key bundle [map] received over Waku into a [PreKeyBundle].
  ///
  /// Throws [FormatException] if required fields are missing or malformed.
  static PreKeyBundle deserializeKeyBundle(Map<String, dynamic> map) {
    try {
      final registrationId = map['registrationId'] as int;
      final deviceId = map['deviceId'] as int? ?? defaultDeviceId;

      final identityKeyBytes = base64Decode(map['identityKey'] as String);
      final identityKey = IdentityKey.fromBytes(identityKeyBytes, 0);

      final signedPreKeyId = map['signedPreKeyId'] as int;
      final signedPreKeyPublicBytes =
          base64Decode(map['signedPreKeyPublic'] as String);
      final signedPreKeyPublic =
          Curve.decodePoint(signedPreKeyPublicBytes, 0);
      final signedPreKeySignature =
          base64Decode(map['signedPreKeySignature'] as String);

      final preKeyId = map['preKeyId'] as int?;
      ECPublicKey? preKeyPublic;
      if (preKeyId != null && map['preKeyPublic'] != null) {
        final preKeyBytes = base64Decode(map['preKeyPublic'] as String);
        preKeyPublic = Curve.decodePoint(preKeyBytes, 0);
      }

      return PreKeyBundle(
        registrationId,
        deviceId,
        preKeyId,
        preKeyPublic,
        signedPreKeyId,
        signedPreKeyPublic,
        signedPreKeySignature,
        identityKey,
      );
    } catch (e) {
      throw FormatException('Failed to deserialize key bundle: $e');
    }
  }

  // ── registration ID ───────────────────────────────────────────────────────

  /// Generates a new random registration ID for the local user.
  ///
  /// Uses the extended range to minimize collision probability.
  static int generateRegistrationId() {
    // Generate a random registration ID in the extended range [0, 2^31-1].
    final random = DateTime.now().microsecondsSinceEpoch ^ 0x7FFFFFFF;
    return random & 0x7FFFFFFF;
  }
}
