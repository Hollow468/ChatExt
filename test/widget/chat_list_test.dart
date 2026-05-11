import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:chatext/screens/chat_list/chat_list_screen.dart';

void main() {
  group('ChatListScreen Widget Tests', () {
    Widget buildTestWidget() {
      return const MaterialApp(
        home: ChatListScreen(),
      );
    }

    testWidgets('renders without errors', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Verify the scaffold exists
      expect(find.byType(Scaffold), findsOneWidget);
    });

    testWidgets('shows app bar with title', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // AppBar with the app name
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('ChatExt'), findsOneWidget);
    });

    testWidgets('shows placeholder state when no chats', (tester) async {
      await tester.pumpWidget(buildTestWidget());

      // Current placeholder implementation shows centered text
      expect(
        find.text('ChatListScreen – placeholder'),
        findsOneWidget,
      );
    });

    // Once the real ChatListScreen is implemented with a ListView, uncomment:
    // testWidgets('shows chat items when data is available', (tester) async {
    //   // TODO: Provide mock ViewModel / Provider with test data
    //   // await tester.pumpWidget(buildTestWidgetWithData());
    //   // expect(find.byType(ListView), findsOneWidget);
    //   // expect(find.byType(ChatListItem), findsWidgets);
    // });
  });
}
