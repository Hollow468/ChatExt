import 'package:drift/drift.dart';

/// Drift table definition for chat contacts / peers.
///
/// Each row represents a known peer that the local user has interacted with.
class Contacts extends Table {
  /// Base58-encoded public key that uniquely identifies this peer.
  TextColumn get peerId => text()();

  /// Human-readable display name.
  TextColumn get displayName => text()();

  /// Optional URL for the contact's avatar image.
  TextColumn get avatarUrl => text().nullable()();

  /// Unix milliseconds of the last message exchanged with this contact.
  IntColumn get lastMessageAt => integer().nullable()();

  /// Whether the contact is currently online / reachable.
  BoolColumn get isOnline => boolean().withDefault(const Constant(false))();

  /// Raw public key bytes for cryptographic operations.
  BlobColumn get publicKeyData => blob()();

  @override
  Set<Column> get primaryKey => {peerId};
}
