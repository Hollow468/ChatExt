import 'package:drift/drift.dart';

import '../database.dart';
import '../tables/groups.dart';

part 'group_dao.g.dart';

/// Data-access object for the [Groups] and [GroupMembers] tables.
@DriftAccessor(tables: [Groups, GroupMembers])
class GroupDao extends DatabaseAccessor<AppDatabase> with _$GroupDaoMixin {
  GroupDao(AppDatabase db) : super(db);

  // ── Inserts / Updates ──────────────────────────────────────────────────────

  /// Inserts a new group or updates the existing one if [id] matches.
  Future<int> insertOrUpdateGroup(GroupsCompanion entry) {
    return into(groups).insertOnConflictUpdate(entry);
  }

  /// Adds a member to a group.
  Future<int> addMember(GroupMembersCompanion entry) {
    return into(groupMembers).insertOnConflictUpdate(entry);
  }

  // ── Queries ────────────────────────────────────────────────────────────────

  /// Returns all groups the local user is a member of.
  Future<List<Group>> getAllGroups() {
    return (select(groups)
          ..orderBy([(g) => OrderingTerm.desc(g.createdAt)]))
        .get();
  }

  /// Returns a single group by [id], or `null` if not found.
  Future<Group?> getGroupById(String id) {
    return (select(groups)..where((g) => g.id.equals(id))).getSingleOrNull();
  }

  /// Returns all member peer IDs for a given [groupId].
  Future<List<String>> getMemberPeerIds(String groupId) async {
    final rows = await (select(groupMembers)
          ..where((m) => m.groupId.equals(groupId)))
        .get();
    return rows.map((r) => r.peerId).toList();
  }

  /// Returns all group IDs that [peerId] is a member of.
  Future<List<String>> getGroupIdsForPeer(String peerId) async {
    final rows = await (select(groupMembers)
          ..where((m) => m.peerId.equals(peerId)))
        .get();
    return rows.map((r) => r.groupId).toList();
  }

  // ── Deletes ────────────────────────────────────────────────────────────────

  /// Removes a member from a group.
  Future<int> removeMember(String groupId, String peerId) {
    return (delete(groupMembers)
          ..where(
            (m) => m.groupId.equals(groupId) & m.peerId.equals(peerId),
          ))
        .go();
  }

  /// Deletes a group and all its members (cascade).
  Future<void> deleteGroup(String groupId) async {
    await (delete(groupMembers)..where((m) => m.groupId.equals(groupId))).go();
    await (delete(groups)..where((g) => g.id.equals(groupId))).go();
  }
}
