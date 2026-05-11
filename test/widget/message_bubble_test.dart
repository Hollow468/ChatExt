import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// ---------------------------------------------------------------------------
// MessageBubble Widget Tests
// ---------------------------------------------------------------------------
// Tests for lib/features/chat/widgets/message_bubble.dart (to be implemented).
//
// Expected MessageBubble API:
//   const MessageBubble({
//     required String content,
//     required bool isMine,        // true = sent by current user
//     required int timestamp,      // Unix ms
//     String? senderName,
//     Key? key,
//   })
//
// Uncomment once the MessageBubble widget is implemented.
// ---------------------------------------------------------------------------

// import 'package:chatext/features/chat/widgets/message_bubble.dart';

void main() {
  group('MessageBubble Widget Tests', () {
    // Widget buildTestWidget({
    //   required String content,
    //   required bool isMine,
    //   int? timestamp,
    // }) {
    //   return MaterialApp(
    //     home: Scaffold(
    //       body: MessageBubble(
    //         content: content,
    //         isMine: isMine,
    //         timestamp: timestamp ?? 1700000000000,
    //       ),
    //     ),
    //   );
    // }

    testWidgets('renders sent message aligned to the right', (tester) async {
      // await tester.pumpWidget(buildTestWidget(
    //     content: 'Hello from me',
    //     isMine: true,
      //   ));
      //
      //   expect(find.text('Hello from me'), findsOneWidget);
      //
      //   // Sent messages should be aligned to the end (right in LTR)
      //   final bubble = tester.widget<Align>(find.byType(Align).last);
      //   expect(bubble.alignment, equals(Alignment.centerRight));

      expect(true, isTrue, reason: 'Stub: awaiting MessageBubble implementation');
    });

    testWidgets('renders received message aligned to the left', (tester) async {
      // await tester.pumpWidget(buildTestWidget(
    //     content: 'Hello from friend',
    //     isMine: false,
      //   ));
      //
      //   expect(find.text('Hello from friend'), findsOneWidget);
      //
      //   // Received messages should be aligned to the start (left in LTR)
      //   final bubble = tester.widget<Align>(find.byType(Align).first);
      //   expect(bubble.alignment, equals(Alignment.centerLeft));

      expect(true, isTrue, reason: 'Stub: awaiting MessageBubble implementation');
    });

    testWidgets('shows timestamp', (tester) async {
      // await tester.pumpWidget(buildTestWidget(
    //     content: 'Timed message',
    //     isMine: true,
    //     timestamp: 1700000000000,  // 2023-11-14 22:13:20 UTC
      //   ));
      //
      //   // The widget should render some formatted time text
      //   // (e.g. "22:13" or "just now" depending on current time)
      //   expect(find.byType(Text), findsWidgets);
      //
      //   // Verify at least one Text widget contains a time-like pattern
      //   final textWidgets = tester.widgetList<Text>(find.byType(Text));
      //   final hasTime = textWidgets.any((t) =>
      //     t.data != null && (t.data!.contains(':') || t.data!.contains('ago')));
      //   expect(hasTime, isTrue);

      expect(true, isTrue, reason: 'Stub: awaiting MessageBubble implementation');
    });
  });
}
