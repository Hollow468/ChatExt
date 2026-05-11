import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatext/core/utils/key_utils.dart';

void main() {
  group('IdentityService / KeyUtils', () {
    test('generateKeyPair creates valid pair', () {
      final keyPair = KeyUtils.generateKeyPair();

      expect(keyPair.publicKey, isNotNull);
      expect(keyPair.privateKey, isNotNull);
      // Ed25519 public key is 32 bytes
      expect(KeyUtils.publicKeyBytes(keyPair.publicKey).length, 32);
    });

    test('publicKeyToPeerId returns Base58', () {
      final keyPair = KeyUtils.generateKeyPair();
      final peerId = KeyUtils.publicKeyToPeerId(keyPair.publicKey);

      expect(peerId, isNotEmpty);
      // Base58 alphabet does not include 0, O, I, l
      expect(peerId, isNot(contains('0')));
      expect(peerId, isNot(contains('O')));
      expect(peerId, isNot(contains('I')));
      expect(peerId, isNot(contains('l')));
    });

    test('sign and verify roundtrip', () {
      final keyPair = KeyUtils.generateKeyPair();
      final message = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);

      final signature = KeyUtils.signMessage(keyPair.privateKey, message);
      expect(signature, isNotEmpty);

      final isValid = KeyUtils.verifySignature(
        keyPair.publicKey,
        message,
        signature,
      );
      expect(isValid, isTrue);
    });

    test('verify rejects tampered message', () {
      final keyPair = KeyUtils.generateKeyPair();
      final message = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 8]);

      final signature = KeyUtils.signMessage(keyPair.privateKey, message);

      final tampered = Uint8List.fromList([1, 2, 3, 4, 5, 6, 7, 9]);
      final isValid = KeyUtils.verifySignature(
        keyPair.publicKey,
        tampered,
        signature,
      );
      expect(isValid, isFalse);
    });

    test('peerId is consistent for same key pair', () {
      final keyPair = KeyUtils.generateKeyPair();
      final peerId1 = KeyUtils.publicKeyToPeerId(keyPair.publicKey);
      final peerId2 = KeyUtils.publicKeyToPeerId(keyPair.publicKey);

      expect(peerId1, equals(peerId2));
    });

    test('peerIdToPublicKeyBytes roundtrips correctly', () {
      final keyPair = KeyUtils.generateKeyPair();
      final peerId = KeyUtils.publicKeyToPeerId(keyPair.publicKey);
      final recovered = KeyUtils.peerIdToPublicKeyBytes(peerId);
      final original = KeyUtils.publicKeyBytes(keyPair.publicKey);

      expect(recovered, orderedEquals(original));
    });
  });
}
