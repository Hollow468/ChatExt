import 'package:drift/drift.dart';

/// Drift table definition for chat groups.
class Groups extends Table {
  /// Unique group identifier (UUID v4).
  TextColumn get id => text()();

  /// Display name of the group.
  TextColumn get name => text()();

  /// Peer ID of the group creator / admin.
  TextColumn get creatorPeerId => text()();

  /// Optional avatar URL.
  TextColumn get avatarUrl => text().nullable()();

  /// Optional group description.
  TextColumn get description => text().nullable()();

  /// Unix timestamp in milliseconds when the group was created.
  IntColumn get createdAt => integer()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Junction table mapping group members to groups.
class GroupMembers extends Table {
  /// Group ID (foreign key to [Groups.id]).
  TextColumn get groupId => text()();

  /// Peer ID of the member.
  TextColumn get peerId => text()();

  /// Unix timestamp in milliseconds when the member joined.
  IntColumn get joinedAt => integer()();

  @override
  Set<Column> get primaryKey => {groupId, peerId};
}
