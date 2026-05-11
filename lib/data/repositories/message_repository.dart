import 'dart:async';

import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/waku_topics.dart';
import '../../core/utils/timestamp.dart';
import '../../services/waku/waku_message_codec.dart';
import '../../services/waku/waku_service.dart';
import '../local/daos/message_dao.dart';
import '../local/database.dart';
import '../models/message.dart' as model;

/// Repository that coordinates message persistence and Waku network I/O.
///
/// Outgoing messages are encoded via [WakuMessageCodec] and published through
/// [WakuService]. Incoming messages are decoded, converted to the domain
/// [model.Message] and persisted in the local Drift database via [MessageDao].
class MessageRepository {
  MessageRepository({
    required MessageDao messageDao,
    required WakuService wakuService,
  })  : _dao = messageDao,
        _waku = wakuService;

  final MessageDao _dao;
  final WakuService _waku;
  final WakuMessageCodec _codec = WakuMessageCodec();

  final StreamController<model.Message> _incomingController =
      StreamController<model.Message>.broadcast();

  /// Stream of newly received messages (from the Waku network).
  Stream<model.Message> get incomingMessages => _incomingController.stream;

  // ── Outgoing ───────────────────────────────────────────────────────────────

  /// Sends a text [content] message to the peer identified by [recipientPeerId].
  ///
  /// The message is persisted locally **and** published to the Waku relay
  /// network. The [senderPeerId] should be the local user's Base58 peer ID.
  Future<model.Message> sendMessage({
    required String senderPeerId,
    required String recipientPeerId,
    required String content,
    model.MessageType type = model.MessageType.text,
    String? replyTo,
    String? mediaUrl,
  }) async {
    final id = _generateId();
    final timestamp = TimestampUtils.now();

    // Persist locally first.
    await _dao.insertMessage(
      MessagesCompanion(
        id: Value(id),
        sender: Value(senderPeerId),
        content: Value(content),
        timestamp: Value(timestamp),
        type: Value(type.index),
        replyTo: Value(replyTo),
        mediaUrl: Value(mediaUrl),
      ),
    );

    // Encode and publish over Waku.
    final topic = WakuTopics.dmTopic(senderPeerId, recipientPeerId);
    final wireMessage = ChatMessage(
      id: id,
      senderPeerId: senderPeerId,
      content: content,
      timestamp: timestamp,
    );
    final payload = _codec.encode(wireMessage);
    await _waku.publish(topic, payload);

    return model.Message(
      id: id,
      sender: senderPeerId,
      content: content,
      timestamp: timestamp,
      type: type,
      replyTo: replyTo,
      mediaUrl: mediaUrl,
    );
  }

  // ── Incoming ───────────────────────────────────────────────────────────────

  /// Subscribes to the DM topic between [localPeerId] and [remotePeerId].
  ///
  /// Incoming messages are decoded, persisted to the local database, and
  /// emitted on [incomingMessages].
  Future<void> subscribeToConversation({
    required String localPeerId,
    required String remotePeerId,
  }) async {
    final topic = WakuTopics.dmTopic(localPeerId, remotePeerId);

    await _waku.subscribe(topic);
    _waku.onMessage(topic, (ChatMessage wireMsg) async {
      // Persist to local DB.
      await _dao.insertMessage(
        MessagesCompanion(
          id: Value(wireMsg.id),
          sender: Value(wireMsg.senderPeerId),
          content: Value(wireMsg.content),
          timestamp: Value(wireMsg.timestamp),
          type: const Value(0), // text
        ),
      );

      final msg = model.Message(
        id: wireMsg.id,
        sender: wireMsg.senderPeerId,
        content: wireMsg.content,
        timestamp: wireMsg.timestamp,
      );

      _incomingController.add(msg);
    });
  }

  // ── Local reads ────────────────────────────────────────────────────────────

  /// Returns locally stored messages with pagination.
  Future<List<model.Message>> getMessages({
    String? topic,
    int limit = 50,
    int offset = 0,
  }) async {
    final rows = topic != null
        ? await _dao.getMessagesByTopic(topic, limit: limit, offset: offset)
        : await _dao.getAllMessages(limit: limit, offset: offset);
    return rows.map(_fromRow).toList();
  }

  /// Returns the most recent message, or `null`.
  Future<model.Message?> getLatestMessage(String topic) async {
    final row = await _dao.getLatestMessage(topic);
    return row == null ? null : _fromRow(row);
  }

  /// Marks [messageId] as read.
  Future<void> markAsRead(String messageId) => _dao.markAsRead(messageId);

  /// Deletes [id] from the local database.
  Future<void> deleteMessage(String id) => _dao.deleteMessage(id);

  /// Disposes internal resources.
  void dispose() {
    _incomingController.close();
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  /// Converts a Drift [Message] row to the domain model.
  model.Message _fromRow(Message row) {
    return model.Message(
      id: row.id,
      sender: row.sender,
      content: row.content,
      timestamp: row.timestamp,
      type: model.MessageType.values[row.type],
      replyTo: row.replyTo,
      mediaUrl: row.mediaUrl,
    );
  }

  static const _uuid = Uuid();

  /// Generates a UUID v4 identifier.
  String _generateId() => _uuid.v4();
}
