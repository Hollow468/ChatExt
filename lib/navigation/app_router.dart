import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/auth/screens/create_identity_screen.dart';
import '../features/chat/screens/chat_list_screen.dart';
import '../features/chat/screens/chat_detail_screen.dart';
import '../features/contacts/screens/contact_list_screen.dart';

/// Application router configuration.
final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const CreateIdentityScreen(),
    ),
    GoRoute(
      path: '/chat-list',
      name: 'chatList',
      builder: (context, state) => const ChatListScreen(),
    ),
    GoRoute(
      path: '/chat/:peerId',
      name: 'chatDetail',
      builder: (context, state) {
        final peerId = state.pathParameters['peerId']!;
        return ChatDetailScreen(peerId: peerId);
      },
    ),
    GoRoute(
      path: '/contacts',
      name: 'contacts',
      builder: (context, state) => const ContactListScreen(),
    ),
  ],
);
