import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// Waku Relay Integration Tests
// ---------------------------------------------------------------------------
// IMPORTANT: These tests require a real device or emulator to run because
// they exercise the Go-Waku native bridge via FFI / platform channels.
//
// Run with:
//   flutter test integration_test/waku_relay_test.dart
//   # or on a connected device:
//   flutter test --tags=integration test/integration/waku_relay_test.dart
//
// Prerequisites:
//   - Go-Waku native libs built (make build_android / make build_ios)
//   - Device/emulator with network access to Waku test fleet
//   - Bootstrap nodes reachable (see lib/core/constants/app_constants.dart)
//
// Uncomment and adapt once WakuService and native bridge are implemented.
// ---------------------------------------------------------------------------

// import 'package:chatext/services/waku/waku_service.dart';
// import 'package:chatext/services/identity/identity_service.dart';
// import 'package:chatext/data/models/message.dart';

/// Helper: creates two independent Waku nodes connected to the relay network.
///
/// Returns a tuple of two WakuService instances already peered with each
/// other via the bootstrap nodes.
Future<(dynamic, dynamic)> createTwoNodes() async {
  // TODO: Implement once WakuService is ready.
  //
  // final nodeA = WakuService();
  // await nodeA.start(
  //   host: '0.0.0.0',
  //   port: 60001,
  //   bootstrapNodes: AppConstants.bootstrapNodes,
  // );
  //
  // final nodeB = WakuService();
  // await nodeB.start(
  //   host: '0.0.0.0',
  //   port: 60002,
  //   bootstrapNodes: AppConstants.bootstrapNodes,
  // );
  //
  // return (nodeA, nodeB);

  throw UnimplementedError('Requires real device + native bridge');
}

/// Helper: publishes a message from [sender] and waits for [receiver] to
/// get it on the appropriate content topic.
///
/// Returns the received [ChatMessage] or throws on timeout.
Future<dynamic> sendAndReceive({
  required dynamic sender,
  required dynamic receiver,
  required String content,
  Duration timeout = const Duration(seconds: 10),
}) async {
  // TODO: Implement once WakuService is ready.
  //
  // final message = ChatMessage(
  //   id: const Uuid().v4(),
  //   sender: sender.peerId,
  //   content: content,
  //   timestamp: TimestampUtils.now(),
  //   type: MessageType.TEXT,
  //   replyTo: '',
  //   mediaUrl: '',
  // );
  //
  // await sender.publish(topic, message);
  //
  // final received = await receiver.incomingMessages
  //     .firstWhere((m) => m.id == message.id)
  //     .timeout(timeout);
  //
  // return received;

  throw UnimplementedError('Requires real device + native bridge');
}

void main() {
  group('Waku Relay Integration', () {
    test('two nodes can send and receive a message', () async {
      // final (nodeA, nodeB) = await createTwoNodes();
      //
      // final received = await sendAndReceive(
      //   sender: nodeA,
      //   receiver: nodeB,
      //   content: 'Hello from node A!',
      // );
      //
      // expect(received.content, equals('Hello from node A!'));
      //
      // await nodeA.stop();
      // await nodeB.stop();

    }, skip: 'Integration test – requires native Waku bridge');

    test('messages are received in order', () async {
      // final (nodeA, nodeB) = await createTwoNodes();
      //
      // final messages = <ChatMessage>[];
      // final sub = nodeB.incomingMessages.listen(messages.add);
      //
      // for (var i = 0; i < 5; i++) {
      //   await nodeA.publish(topic, createMessage('msg-$i'));
      //   await Future.delayed(const Duration(milliseconds: 200));
      // }
      //
      // await Future.delayed(const Duration(seconds: 3));
      // await sub.cancel();
      //
      // expect(messages.length, greaterThanOrEqualTo(5));
      //
      // await nodeA.stop();
      // await nodeB.stop();

    }, skip: 'Integration test – requires native Waku bridge');
  });
}
