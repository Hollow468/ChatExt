import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'package:chatext/core/constants/waku_topics.dart';
import 'package:chatext/data/local/daos/group_dao.dart';
import 'package:chatext/data/local/database.dart' as db;
import 'package:chatext/data/models/group.dart';
import 'package:chatext/services/waku/waku_service.dart';

/// Manages group registration and metadata on the Waku network.
///
/// Groups are identified by UUID and their metadata (name, members, etc.)
/// is broadcast via Waku relay on the group's meta topic.
///
/// Protocol:
/// - Group creation: creator generates UUID, publishes GroupCreated event
/// - Group lookup: query local cache or listen for GroupInfo broadcasts
/// - Group dissolution: creator publishes GroupDissolved event
class GroupRegistry {
  GroupRegistry({
    required WakuService waku,
    required GroupDao groupDao,
  })  : _waku = waku,
        _groupDao = groupDao;

  final WakuService _waku;
  final GroupDao _groupDao;

  /// Pending lookup completers keyed by group ID.
  final Map<String, Completer<Group?>> _pendingLookups = {};

  /// Registered callbacks for group events.
  final List<void Function(String groupId, Map<String, dynamic> event)>
      _eventCallbacks = [];

  /// Set of group meta topics currently subscribed to.
  final Set<String> _subscribedTopics = {};

  bool _isDisposed = false;

  /// Converts a Drift [db.Group] row to a model [Group].
  Future<Group> _driftToModel(db.Group g) async {
    final members = await _groupDao.getMemberPeerIds(g.id);
    return Group(
      id: g.id,
      name: g.name,
      creatorPeerId: g.creatorPeerId,
      avatarUrl: g.avatarUrl,
      description: g.description,
      createdAt: g.createdAt,
      memberPeerIds: members,
    );
  }

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Creates a new group and broadcasts its existence on the Waku network.
  ///
  /// The [creatorPeerId] is automatically added as the first member.
  /// Returns the newly created [Group].
  Future<Group> createGroup({
    required String name,
    required String creatorPeerId,
    String? description,
  }) async {
    final group = Group(
      name: name,
      creatorPeerId: creatorPeerId,
      description: description,
      memberPeerIds: [creatorPeerId],
    );

    // Persist locally.
    await _saveGroupToDb(group);

    // Broadcast creation event.
    await _publishGroupMetaEvent(group.id, {
      'type': 'group_created',
      'groupId': group.id,
      'name': group.name,
      'creatorPeerId': group.creatorPeerId,
      'description': group.description,
      'createdAt': group.createdAt,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Ensure we're subscribed to this group's meta topic.
    await _ensureSubscribed(group.id);

    return group;
  }

  /// Requests group info from the Waku network.
  ///
  /// First checks the local cache. If not found, broadcasts a lookup
  /// request and waits up to [timeout] for a response.
  /// Returns null if the group is not found.
  Future<Group?> lookupGroup(
    String groupId, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    if (_isDisposed) return null;

    // Check local cache first.
    final local = await _groupDao.getGroupById(groupId);
    if (local != null) return _driftToModel(local);

    // Ensure we're subscribed to receive responses.
    await _ensureSubscribed(groupId);

    // Broadcast a lookup request.
    await _publishGroupMetaEvent(groupId, {
      'type': 'group_lookup',
      'groupId': groupId,
      'requesterPeerId': '', // Filled by caller if needed.
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Wait for a response.
    final completer = Completer<Group?>();
    _pendingLookups[groupId] = completer;

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        _pendingLookups.remove(groupId);
        return null;
      },
    );
  }

  /// Dissolves a group (only callable by the creator).
  ///
  /// Publishes a [GroupDissolved] event and removes the group from local storage.
  Future<void> dissolveGroup(String groupId, String creatorPeerId) async {
    if (_isDisposed) return;

    final group = await _groupDao.getGroupById(groupId);
    if (group == null) {
      throw StateError('Group $groupId not found.');
    }
    if (group.creatorPeerId != creatorPeerId) {
      throw StateError(
        'Only the creator can dissolve the group.',
      );
    }

    // Broadcast dissolution event.
    await _publishGroupMetaEvent(groupId, {
      'type': 'group_dissolved',
      'groupId': groupId,
      'creatorPeerId': creatorPeerId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });

    // Remove from local storage.
    await _groupDao.deleteGroup(groupId);

    // Clean up subscription.
    _subscribedTopics.remove(WakuTopics.groupMetaTopic(groupId));
  }

  /// Returns all locally cached groups.
  Future<List<Group>> getLocalGroups() async {
    final rows = await _groupDao.getAllGroups();
    return Future.wait(rows.map(_driftToModel));
  }

  /// Registers a callback for incoming group registry events.
  void onGroupEvent(
    void Function(String groupId, Map<String, dynamic> event) callback,
  ) {
    _eventCallbacks.add(callback);
  }

  /// Releases all resources.
  void dispose() {
    _isDisposed = true;
    _eventCallbacks.clear();
    _pendingLookups.clear();
    _subscribedTopics.clear();
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  /// Ensures we are subscribed to the meta topic for [groupId].
  Future<void> _ensureSubscribed(String groupId) async {
    final topic = WakuTopics.groupMetaTopic(groupId);
    if (_subscribedTopics.contains(topic)) return;

    await _waku.subscribe(topic);
    _waku.onMessage(topic, (message) {
      if (_isDisposed) return;
      try {
        final json = jsonDecode(message.content) as Map<String, dynamic>;
        _onGroupEvent(groupId, json);
      } catch (e) {
        debugPrint('GroupRegistry: failed to decode meta event: $e');
      }
    });

    _subscribedTopics.add(topic);
  }

  /// Handles incoming group registry events.
  void _onGroupEvent(String groupId, Map<String, dynamic> event) {
    final type = event['type'] as String?;

    switch (type) {
      case 'group_info':
        // Response to a lookup request.
        _handleGroupInfo(event);
        break;
      case 'group_dissolved':
        _handleGroupDissolved(event);
        break;
      case 'group_created':
        _handleGroupCreated(event);
        break;
    }

    // Notify registered callbacks.
    for (final cb in _eventCallbacks) {
      cb(groupId, event);
    }
  }

  /// Handles a group_info response by resolving pending lookups and
  /// updating the local cache.
  void _handleGroupInfo(Map<String, dynamic> event) {
    try {
      final group = Group.fromJson(event['group'] as Map<String, dynamic>);
      _saveGroupToDb(group);

      final completer = _pendingLookups.remove(group.id);
      if (completer != null && !completer.isCompleted) {
        completer.complete(group);
      }
    } catch (e) {
      debugPrint('GroupRegistry: failed to handle group_info: $e');
    }
  }

  /// Handles a group_created event by caching the group locally.
  void _handleGroupCreated(Map<String, dynamic> event) {
    try {
      final group = Group(
        id: event['groupId'] as String,
        name: event['name'] as String,
        creatorPeerId: event['creatorPeerId'] as String,
        description: event['description'] as String?,
        createdAt: event['createdAt'] as int,
        memberPeerIds: [event['creatorPeerId'] as String],
      );
      _saveGroupToDb(group);
    } catch (e) {
      debugPrint('GroupRegistry: failed to handle group_created: $e');
    }
  }

  /// Handles a group_dissolved event by removing the group locally.
  void _handleGroupDissolved(Map<String, dynamic> event) {
    try {
      final groupId = event['groupId'] as String;
      _groupDao.deleteGroup(groupId);
    } catch (e) {
      debugPrint('GroupRegistry: failed to handle group_dissolved: $e');
    }
  }

  /// Persists a [Group] to the database.
  Future<void> _saveGroupToDb(Group group) async {
    await _groupDao.insertOrUpdateGroup(
      db.GroupsCompanion.insert(
        id: group.id,
        name: group.name,
        creatorPeerId: group.creatorPeerId,
        createdAt: group.createdAt,
        avatarUrl: Value(group.avatarUrl),
        description: Value(group.description),
      ),
    );

    // Persist members.
    for (final peerId in group.memberPeerIds) {
      await _groupDao.addMember(
        db.GroupMembersCompanion.insert(
          groupId: group.id,
          peerId: peerId,
          joinedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  /// Publishes a JSON-encoded meta event to the group's meta topic.
  Future<void> _publishGroupMetaEvent(
    String groupId,
    Map<String, dynamic> event,
  ) async {
    final topic = WakuTopics.groupMetaTopic(groupId);
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(event)));
    await _waku.publish(topic, bytes);
  }
}
