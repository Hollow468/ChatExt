import 'package:drift/drift.dart';

/// Drift table definition for chat messages.
///
/// Each row represents a single message exchanged between peers.
class Messages extends Table {
  /// Unique message identifier (UUID v4).
  TextColumn get id => text()();

  /// Base58-encoded public key of the message sender.
  TextColumn get sender => text()();

  /// Plain-text body of the message.
  TextColumn get content => text()();

  /// Unix timestamp in milliseconds when the message was created.
  IntColumn get timestamp => integer()();

  /// Message type encoded as an integer (see [MessageType] enum).
  ///
  /// 0 = text, 1 = image, 2 = file, 3 = system.
  IntColumn get type => integer().withDefault(const Constant(0))();

  /// Optional ID of the message being replied to.
  TextColumn get replyTo => text().nullable()();

  /// Optional URL for media attachments.
  TextColumn get mediaUrl => text().nullable()();

  /// Whether the message has been read by the local user.
  BoolColumn get isRead => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}
