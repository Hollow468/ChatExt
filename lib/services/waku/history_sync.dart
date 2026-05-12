import 'dart:convert';
import 'dart:developer';

import 'package:drift/drift.dart';

import '../../core/constants/waku_topics.dart';
import '../../data/local/daos/message_dao.dart';
import '../../data/local/database.dart';
import '../../data/models/message.dart' as model;
import '../crypto/signal_service.dart';
import '../identity/identity_service.dart';
import 'store_service.dart';
import 'sync_state.dart';

/// Result of a history sync or pagination operation.
class SyncResult {
  const SyncResult({
    required this.messages,
    this.nextCursor,
    required this.hasMore,
    required this.syncedCount,
  });

  /// Decoded messages (decrypted when possible).
  final List<model.Message> messages;

  /// Cursor for the next page. `null` when there are no more pages.
  final String? nextCursor;

  /// Whether more pages are available.
  final bool hasMore;

  /// Number of new messages written to the local database.
  final int syncedCount;
}

/// Synchronizes message history from the Waku Store.
///
/// Flow:
/// 1. Open chat → check last local message timestamp.
/// 2. Query Store for messages after that timestamp.
/// 3. Decrypt messages (if E2E session exists).
/// 4. Write to local database.
/// 5. Return results for UI update.
///
/// For first-time chats, fetches all available history (paginated).
class HistorySyncService {
  HistorySyncService({
    required StoreService store,
    required MessageDao messageDao,
    required IdentityService identity,
    required SyncStateManager syncState,
    SignalService? signal,
  })  : _store = store,
        _messageDao = messageDao,
        _identity = identity,
        _syncState = syncState,
        _signal = signal;

  final StoreService _store;
  final MessageDao _messageDao;
  final IdentityService _identity;
  final SyncStateManager _syncState;
  final SignalService? _signal;

  /// Syncs history for a DM conversation with [remotePeerId].
  ///
  /// Returns the number of new messages written to the local database.
  Future<int> syncDM(String remotePeerId) async {
    final localPeerId = _identity.getPeerId();
    final topic = WakuTopics.dmTopic(localPeerId, remotePeerId);
    return _syncTopic(
      contentTopic: topic,
      remotePeerId: remotePeerId,
    );
  }

  /// Syncs history for a group chat identified by [groupId].
  ///
  /// Returns the number of new messages written to the local database.
  Future<int> syncGroup(String groupId) async {
    final topic = WakuTopics.groupTopic(groupId);
    return _syncTopic(contentTopic: topic);
  }

  /// Loads the next page of history for a conversation.
  ///
  /// [contentTopic] is the Waku content topic to query.
  /// [cursor] is the pagination cursor from a previous result.
  /// [pageSize] controls how many messages to fetch per page.
  Future<SyncResult> loadMore({
    required String contentTopic,
    required String? cursor,
    int pageSize = 20,
  }) async {
    await _syncState.setStatus(contentTopic, SyncStatus.syncing);

    try {
      final result = await _store.query(
        contentTopics: [contentTopic],
        pageSize: pageSize,
        cursor: cursor,
      );

      final messages = await _decodeMessages(result.messages);
      final syncedCount = await _persistMessages(messages);

      await _syncState.setCursor(contentTopic, result.nextCursor);
      await _syncState.setStatus(contentTopic, SyncStatus.idle);

      return SyncResult(
        messages: messages,
        nextCursor: result.nextCursor,
        hasMore: result.hasMore,
        syncedCount: syncedCount,
      );
    } catch (e) {
      await _syncState.setStatus(contentTopic, SyncStatus.error);
      rethrow;
    }
  }

  /// Gets the timestamp of the last local message for [contentTopic].
  Future<int?> getLastLocalTimestamp(String contentTopic) async {
    final latest = await _messageDao.getLatestMessage(contentTopic);
    return latest?.timestamp;
  }

  // ── Internal helpers ────────────────────────────────────────────────────────

  /// Syncs messages for a single content topic.
  Future<int> _syncTopic({
    required String contentTopic,
    String? remotePeerId,
  }) async {
    await _syncState.setStatus(contentTopic, SyncStatus.syncing);

    try {
      final lastSync = _syncState.getLastSyncTime(contentTopic);
      final lastLocal = await getLastLocalTimestamp(contentTopic);
      final startTime = _earliest(lastSync, lastLocal);

      int totalSynced = 0;
      String? cursor = _syncState.getCursor(contentTopic);
      bool hasMore = true;

      while (hasMore) {
        final result = await _store.query(
          contentTopics: [contentTopic],
          startTime: startTime,
          pageSize: 20,
          cursor: cursor,
        );

        if (result.messages.isEmpty) break;

        final messages = await _decodeMessages(
          result.messages,
          remotePeerId: remotePeerId,
        );
        final synced = await _persistMessages(messages);
        totalSynced += synced;

        cursor = result.nextCursor;
        hasMore = result.hasMore;

        await _syncState.setCursor(contentTopic, cursor);

        // Stop if we got fewer messages than the page size — no more to fetch.
        if (result.messages.length < 20) break;
      }

      final now = DateTime.now().millisecondsSinceEpoch;
      await _syncState.setLastSyncTime(contentTopic, now);
      await _syncState.setStatus(contentTopic, SyncStatus.idle);

      return totalSynced;
    } catch (e) {
      await _syncState.setStatus(contentTopic, SyncStatus.error);
      log('HistorySync: failed to sync $contentTopic: $e');
      return 0;
    }
  }

  /// Decodes store messages into domain [model.Message] objects.
  ///
  /// Attempts E2E decryption when a [remotePeerId] is provided and
  /// a Signal session exists. Falls back to storing raw ciphertext.
  Future<List<model.Message>> _decodeMessages(
    List<StoreMessage> storeMessages, {
    String? remotePeerId,
  }) async {
    final messages = <model.Message>[];

    for (final sm in storeMessages) {
      try {
        final json = utf8.decode(sm.payload);
        final map = jsonDecode(json) as Map<String, dynamic>;

        String content = map['content'] as String? ?? '';

        // Attempt E2E decryption if this is a DM and a session exists.
        if (remotePeerId != null && _signal != null) {
          final hasSession = await _signal.hasSession(remotePeerId);
          if (hasSession && content.isNotEmpty) {
            try {
              final ciphertext = base64Decode(content);
              content = await _signal.decryptMessage(
                remotePeerId,
                Uint8List.fromList(ciphertext),
              );
            } catch (_) {
              // Decryption failed — keep the raw ciphertext string.
            }
          }
        }

        messages.add(model.Message(
          id: map['id'] as String?,
          sender: map['sender'] as String? ?? '',
          content: content,
          timestamp: map['timestamp'] as int? ?? sm.timestamp,
          type: model.MessageType.values.firstWhere(
            (t) => t.index == (map['type'] as int? ?? 0),
            orElse: () => model.MessageType.text,
          ),
          replyTo: map['replyTo'] as String?,
          mediaUrl: map['mediaUrl'] as String?,
        ));
      } catch (e) {
        log('HistorySync: skipping unparseable store message: $e');
      }
    }

    return messages;
  }

  /// Persists decoded messages to the local database, skipping duplicates.
  ///
  /// Returns the count of newly inserted messages.
  Future<int> _persistMessages(List<model.Message> messages) async {
    int count = 0;
    for (final msg in messages) {
      final inserted = await _messageDao.insertMessage(
        MessagesCompanion(
          id: Value(msg.id),
          sender: Value(msg.sender),
          content: Value(msg.content),
          timestamp: Value(msg.timestamp),
          type: Value(msg.type.index),
          replyTo: Value(msg.replyTo),
          mediaUrl: Value(msg.mediaUrl),
          isRead: const Value(false),
        ),
      );
      if (inserted > 0) count++;
    }
    return count;
  }

  /// Returns the earlier of two nullable timestamps, ignoring `null` values.
  int? _earliest(int? a, int? b) {
    if (a == null) return b;
    if (b == null) return a;
    return a < b ? a : b;
  }
}
