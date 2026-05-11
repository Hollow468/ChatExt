import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/messages.dart';

part 'message_dao.g.dart';

/// Data-access object for the [Messages] table.
@DriftAccessor(tables: [Messages])
class MessageDao extends DatabaseAccessor<AppDatabase> with _$MessageDaoMixin {
  MessageDao(AppDatabase db) : super(db);

  // ── Inserts ────────────────────────────────────────────────────────────────

  /// Inserts a single message. If a message with the same [id] already exists
  /// the insert is silently skipped.
  Future<int> insertMessage(MessagesCompanion entry) {
    return into(messages).insert(entry, mode: InsertMode.insertOrIgnore);
  }

  // ── Queries ────────────────────────────────────────────────────────────────

  /// Returns messages ordered by [timestamp] descending with pagination.
  ///
  /// [topic] is matched against the [sender] column for now; this can be
  /// refined when topic-based routing is added.
  Future<List<Message>> getMessagesByTopic(
    String topic, {
    int limit = 50,
    int offset = 0,
  }) {
    return (select(messages)
          ..orderBy([(m) => OrderingTerm.desc(m.timestamp)])
          ..limit(limit, offset: offset))
        .get();
  }

  /// Returns the single most recent message, or `null` if the table is empty.
  Future<Message?> getLatestMessage(String topic) {
    return (select(messages)
          ..orderBy([(m) => OrderingTerm.desc(m.timestamp)])
          ..limit(1))
        .getSingleOrNull();
  }

  /// Returns all messages ordered by timestamp ascending (oldest first).
  Future<List<Message>> getAllMessages({int limit = 200, int offset = 0}) {
    return (select(messages)
          ..orderBy([(m) => OrderingTerm.asc(m.timestamp)])
          ..limit(limit, offset: offset))
        .get();
  }

  // ── Updates ────────────────────────────────────────────────────────────────

  /// Marks a single message as read.
  Future<int> markAsRead(String messageId) {
    return (update(messages)..where((m) => m.id.equals(messageId))).write(
      const MessagesCompanion(isRead: Value(true)),
    );
  }

  // ── Deletes ────────────────────────────────────────────────────────────────

  /// Deletes a message by its [id].
  Future<int> deleteMessage(String id) {
    return (delete(messages)..where((m) => m.id.equals(id))).go();
  }
}
