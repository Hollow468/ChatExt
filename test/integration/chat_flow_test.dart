import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Chat Flow Integration Tests
// ---------------------------------------------------------------------------
// Full end-to-end flow: create identity -> add contact -> send -> receive.
//
// IMPORTANT: Requires a real device or emulator with native Go-Waku bridge.
//
// Run with:
//   flutter test integration_test/chat_flow_test.dart
//   # or:
//   flutter test --tags=integration test/integration/chat_flow_test.dart
//
// Uncomment and adapt once all services are implemented.
// ---------------------------------------------------------------------------

// import 'package:chatext/services/identity/identity_service.dart';
// import 'package:chatext/services/waku/waku_service.dart';
// import 'package:chatext/data/repositories/message_repository.dart';
// import 'package:chatext/data/repositories/contact_repository.dart';
// import 'package:chatext/data/models/message.dart';

void main() {
  group('Full Chat Flow Integration', () {
    // late IdentityService identityA;
    // late IdentityService identityB;
    // late WakuService wakuA;
    // late WakuService wakuB;
    // late MessageRepository msgRepoA;
    // late MessageRepository msgRepoB;
    // late ContactRepository contactRepoA;
    // late ContactRepository contactRepoB;

    setUp(() async {
      // 1. Create identities for both users
      // identityA = IdentityService();
      // await identityA.createIdentity(nickname: 'Alice');
      //
      // identityB = IdentityService();
      // await identityB.createIdentity(nickname: 'Bob');
      //
      // 2. Start Waku nodes
      // wakuA = WakuService();
      // await wakuA.start(host: '0.0.0.0', port: 60001, bootstrapNodes: [...]);
      //
      // wakuB = WakuService();
      // await wakuB.start(host: '0.0.0.0', port: 60002, bootstrapNodes: [...]);
      //
      // 3. Wire up repositories
      // msgRepoA = MessageRepository(dao: ..., waku: wakuA);
      // msgRepoB = MessageRepository(dao: ..., waku: wakuB);
      // contactRepoA = ContactRepository(...);
      // contactRepoB = ContactRepository(...);
    });

    tearDown(() async {
      // await wakuA.stop();
      // await wakuB.stop();
    });

    test('full flow: identity -> contact -> send -> receive', () async {
      // -- Step 1: Verify identities ------------------------------------------
      // final peerIdA = identityA.currentPeerId;
      // final peerIdB = identityB.currentPeerId;
      // expect(peerIdA, isNotEmpty);
      // expect(peerIdB, isNotEmpty);
      // expect(peerIdA, isNot(equals(peerIdB)));

      // -- Step 2: Add each other as contacts ---------------------------------
      // await contactRepoA.addContact(peerId: peerIdB, nickname: 'Bob');
      // await contactRepoB.addContact(peerId: peerIdA, nickname: 'Alice');
      //
      // final contactsA = await contactRepoA.getContacts();
      // expect(contactsA, hasLength(1));
      // expect(contactsA.first.peerId, equals(peerIdB));

      // -- Step 3: Alice sends a message to Bob -------------------------------
      // final message = ChatMessage(
      //   id: const Uuid().v4(),
      //   sender: peerIdA,
      //   content: 'Hey Bob, welcome to ChatExt!',
      //   timestamp: TimestampUtils.now(),
      //   type: MessageType.TEXT,
      //   replyTo: '',
      //   mediaUrl: '',
      // );
      // await msgRepoA.sendMessage(message);

      // -- Step 4: Bob receives the message -----------------------------------
      // final received = await wakuB.incomingMessages
      //     .firstWhere((m) => m.id == message.id)
      //     .timeout(const Duration(seconds: 15));
      //
      // expect(received.content, equals('Hey Bob, welcome to ChatExt!'));
      // expect(received.sender, equals(peerIdA));

      // -- Step 5: Bob replies ------------------------------------------------
      // final reply = ChatMessage(
      //   id: const Uuid().v4(),
      //   sender: peerIdB,
      //   content: 'Thanks Alice!',
      //   timestamp: TimestampUtils.now(),
      //   type: MessageType.TEXT,
      //   replyTo: message.id,
      //   mediaUrl: '',
      // );
      // await msgRepoB.sendMessage(reply);
      //
      // final replyReceived = await wakuA.incomingMessages
      //     .firstWhere((m) => m.id == reply.id)
      //     .timeout(const Duration(seconds: 15));
      //
      // expect(replyReceived.content, equals('Thanks Alice!'));
      // expect(replyReceived.replyTo, equals(message.id));

      // -- Step 6: Verify local message history -------------------------------
      // final historyA = await msgRepoA.getMessages(peerIdB);
      // expect(historyA.length, greaterThanOrEqualTo(2));

      expect(
        true,
        isTrue,
        reason: 'Stub: awaiting full implementation of services',
      );
    }, skip: 'Integration test – requires native Waku bridge');
  });
}
