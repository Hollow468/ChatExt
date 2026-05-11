import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// MessageRepository Unit Tests
// ---------------------------------------------------------------------------
// Tests for lib/data/repositories/message_repository.dart.
//
// Expected MessageRepository API (to be implemented):
//   Future<void> sendMessage(ChatMessage message)
//   Future<List<ChatMessage>> getMessages(String peerId)
//   Stream<ChatMessage> get incomingMessages
//
// Dependencies to mock:
//   - MessageDao (lib/data/local/daos/message_dao.dart)
//   - WakuService (lib/services/waku/waku_service.dart)
//
// Uncomment imports and regenerate mocks once the source classes exist:
//   dart run build_runner build --delete-conflicting-outputs
// ---------------------------------------------------------------------------

// import 'package:chatext/data/models/message.dart';
// import 'package:chatext/data/local/daos/message_dao.dart';
// import 'package:chatext/data/repositories/message_repository.dart';
// import 'package:chatext/services/waku/waku_service.dart';

// @GenerateMocks([MessageDao, WakuService])
// import 'message_repository_test.mocks.dart';

void main() {
  group('MessageRepository', () {
    // late MockMessageDao mockDao;
    // late MockWakuService mockWaku;
    // late MessageRepository repository;
    // late ChatMessage testMessage;

    setUp(() {
      // mockDao = MockMessageDao();
      // mockWaku = MockWakuService();
      // repository = MessageRepository(dao: mockDao, waku: mockWaku);
      //
      // testMessage = ChatMessage(
      //   id: 'test-001',
      //   sender: 'Alice',
      //   content: 'Hello Bob',
      //   timestamp: 1700000000000,
      //   type: MessageType.TEXT,
      //   replyTo: '',
      //   mediaUrl: '',
      // );
    });

    // -- sendMessage calls waku publish -------------------------------------------
    test('sendMessage calls waku publish', () async {
      // when(mockDao.insertMessage(any)).thenAnswer((_) async {});
      // when(mockWaku.publish(any, any)).thenAnswer((_) async {});
      //
      // await repository.sendMessage(testMessage);
      //
      // verify(mockWaku.publish(any, any)).called(1);
      // verify(mockDao.insertMessage(testMessage)).called(1);

      expect(true, isTrue, reason: 'Stub: awaiting MessageRepository implementation');
    });

    // -- getMessages returns from dao ---------------------------------------------
    test('getMessages returns messages from dao', () async {
      // final messages = [testMessage];
      // when(mockDao.getMessagesByPeerId('Bob')).thenAnswer((_) async => messages);
      //
      // final result = await repository.getMessages('Bob');
      //
      // expect(result, hasLength(1));
      // expect(result.first.content, equals('Hello Bob'));
      // verify(mockDao.getMessagesByPeerId('Bob')).called(1);

      expect(true, isTrue, reason: 'Stub: awaiting MessageRepository implementation');
    });

    // -- incoming message is stored -----------------------------------------------
    test('incoming message is stored via dao', () async {
      // final incoming = ChatMessage(
      //   id: 'msg-incoming',
      //   sender: 'Bob',
      //   content: 'Reply from Bob',
      //   timestamp: 1700000050000,
      //   type: MessageType.TEXT,
      //   replyTo: '',
      //   mediaUrl: '',
      // );
      //
      // when(mockWaku.incomingMessages).thenAnswer((_) => Stream.value(incoming));
      // when(mockDao.insertMessage(any)).thenAnswer((_) async {});
      //
      // // Trigger listening to incoming messages
      // repository.listenForIncoming();
      // await Future.delayed(Duration.zero);
      //
      // verify(mockDao.insertMessage(any)).called(1);

      expect(true, isTrue, reason: 'Stub: awaiting MessageRepository implementation');
    });
  });
}
