import 'dart:async';
import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'package:chatext/core/constants/waku_topics.dart';
import 'package:chatext/data/local/daos/group_dao.dart';
import 'package:chatext/data/local/database.dart' as db;
import 'package:chatext/data/models/group.dart';
import 'package:chatext/services/group/group_registry.dart';
import 'package:chatext/services/waku/waku_service.dart';

/// Callback type for group state updates.
typedef StateUpdateCallback = void Function(Group updatedGroup);

/// Synchronizes group state (members, metadata) across the P2P network.
///
/// Periodically broadcasts group state and merges incoming updates.
///
/// Sync protocol:
/// - On join: new member requests full state from existing members
/// - On state change: broadcaster publishes updated state
/// - Conflict resolution: latest timestamp wins
class GroupSyncService {
  GroupSyncService({
    required WakuService waku,
    required GroupDao groupDao,
    required GroupRegistry registry,
  })  : _waku = waku,
        _groupDao = groupDao,
        _registry = registry;

  final WakuService _waku;
  final GroupDao _groupDao;
  final GroupRegistry _registry;

  /// State update callbacks keyed by group ID.
  final Map<String, List<StateUpdateCallback>> _stateCallbacks = {};

  /// Active sync timers keyed by group ID.
  final Map<String, Timer> _syncTimers = {};

  /// Set of group IDs currently being synced.
  final Set<String> _activeSyncs = {};

  /// Timestamps of last broadcast per group, for rate-limiting.
  final Map<String, int> _lastBroadcast = {};

  /// Minimum interval between broadcasts for the same group.
  static const _broadcastCooldown = Duration(seconds: 5);

  /// Default sync broadcast interval.
  static const _syncInterval = Duration(minutes: 2);

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

  /// Starts syncing for a group.
  ///
  /// Subscribes to the group's meta topic, requests full state from the
  /// network, and begins periodic state broadcasts.
  Future<void> startSync(String groupId) async {
    if (_isDisposed || _activeSyncs.contains(groupId)) return;

    _activeSyncs.add(groupId);

    // Subscribe to meta topic for sync events.
    final topic = WakuTopics.groupMetaTopic(groupId);
    await _waku.subscribe(topic);

    _waku.onMessage(topic, (message) {
      if (_isDisposed) return;
      try {
        final json = jsonDecode(message.content) as Map<String, dynamic>;
        _handleMetaEvent(groupId, json);
      } catch (e) {
        debugPrint('GroupSyncService: failed to decode sync event: $e');
      }
    });

    // Request full state from the network.
    await requestState(groupId);

    // Start periodic broadcast timer.
    _syncTimers[groupId] = Timer.periodic(_syncInterval, (_) {
      broadcastState(groupId);
    });
  }

  /// Stops syncing for a group.
  ///
  /// Cancels the periodic broadcast timer and removes callbacks.
  void stopSync(String groupId) {
    _activeSyncs.remove(groupId);
    _syncTimers[groupId]?.cancel();
    _syncTimers.remove(groupId);
    _stateCallbacks.remove(groupId);
    _lastBroadcast.remove(groupId);
  }

  /// Requests full group state from the network.
  ///
  /// Publishes a [state_request] event. Existing members will respond
  /// with a [state_broadcast].
  Future<void> requestState(String groupId) async {
    if (_isDisposed) return;

    await _publishSyncEvent(groupId, {
      'type': 'state_request',
      'groupId': groupId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    });
  }

  /// Broadcasts current group state to the network.
  ///
  /// Rate-limited to avoid flooding the network.
  Future<void> broadcastState(String groupId) async {
    if (_isDisposed) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastBroadcast = _lastBroadcast[groupId];
    if (lastBroadcast != null &&
        now - lastBroadcast < _broadcastCooldown.inMilliseconds) {
      return; // Rate-limited.
    }

    final driftGroup = await _groupDao.getGroupById(groupId);
    if (driftGroup == null) return;

    final group = await _driftToModel(driftGroup);

    await _publishSyncEvent(groupId, {
      'type': 'state_broadcast',
      'groupId': groupId,
      'group': group.toJson(),
      'timestamp': now,
    });

    _lastBroadcast[groupId] = now;
  }

  /// Merges an incoming state update with local state.
  ///
  /// Conflict resolution: latest timestamp wins for each field.
  /// New members are added; members present locally but absent remotely
  /// are kept (union semantics — only explicit removes delete members).
  Future<void> mergeState(
    String groupId,
    Map<String, dynamic> remoteState,
  ) async {
    if (_isDisposed) return;

    final localGroup = await _groupDao.getGroupById(groupId);
    final remoteTimestamp = remoteState['timestamp'] as int? ?? 0;
    final localTimestamp = localGroup?.createdAt ?? 0;

    // If remote state is older than our local creation time, skip metadata
    // merge but still merge members.
    if (remoteTimestamp < localTimestamp && localGroup != null) {
      // Only merge members from the remote state.
      final remoteMembers =
          (remoteState['memberPeerIds'] as List<dynamic>?)
              ?.cast<String>() ??
          [];
      await _mergeMembers(groupId, remoteMembers);
      return;
    }

    // Full merge: update group metadata and members.
    final groupData = remoteState['group'] as Map<String, dynamic>?;
    if (groupData != null) {
      try {
        final remoteGroup = Group.fromJson(groupData);

        // Update group metadata if remote is newer.
        await _groupDao.insertOrUpdateGroup(
          db.GroupsCompanion.insert(
            id: remoteGroup.id,
            name: remoteGroup.name,
            creatorPeerId: remoteGroup.creatorPeerId,
            createdAt: remoteGroup.createdAt,
            avatarUrl: Value(remoteGroup.avatarUrl),
            description: Value(remoteGroup.description),
          ),
        );

        // Merge members.
        final remoteMembers =
            (groupData['memberPeerIds'] as List<dynamic>?)
                ?.cast<String>() ??
            [];
        await _mergeMembers(groupId, remoteMembers);

        // Notify callbacks.
        final updatedDrift = await _groupDao.getGroupById(groupId);
        if (updatedDrift != null) {
          _notifyStateUpdate(groupId, await _driftToModel(updatedDrift));
        }
      } catch (e) {
        debugPrint('GroupSyncService: failed to merge state: $e');
      }
    }
  }

  /// Registers a callback for state updates on [groupId].
  void onStateUpdate(String groupId, StateUpdateCallback callback) {
    _stateCallbacks.putIfAbsent(groupId, () => []).add(callback);
  }

  /// Releases all resources.
  void dispose() {
    _isDisposed = true;

    for (final timer in _syncTimers.values) {
      timer.cancel();
    }
    _syncTimers.clear();
    _stateCallbacks.clear();
    _activeSyncs.clear();
    _lastBroadcast.clear();
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  /// Handles incoming meta events relevant to sync.
  void _handleMetaEvent(String groupId, Map<String, dynamic> event) {
    final type = event['type'] as String?;

    switch (type) {
      case 'state_request':
        // Someone is requesting our state — respond with a broadcast.
        broadcastState(groupId);
        break;

      case 'state_broadcast':
        // Someone is broadcasting their state — merge it.
        mergeState(groupId, event);
        break;

      case 'join':
        // A new member joined — merge their peer ID.
        final peerId = event['peerId'] as String?;
        if (peerId != null) {
          _mergeMembers(groupId, [peerId]);
        }
        break;

      case 'leave':
        // A member left — we don't remove locally (union semantics),
        // but we log it.
        final peerId = event['peerId'] as String?;
        if (peerId != null) {
          debugPrint(
            'GroupSyncService: member $peerId left group $groupId',
          );
        }
        break;
    }
  }

  /// Merges [remoteMembers] into the local member list for [groupId].
  ///
  /// Adds any members present remotely but missing locally.
  Future<void> _mergeMembers(
    String groupId,
    List<String> remoteMembers,
  ) async {
    final localMembers = await _groupDao.getMemberPeerIds(groupId);
    final localSet = localMembers.toSet();

    for (final peerId in remoteMembers) {
      if (!localSet.contains(peerId)) {
        await _groupDao.addMember(
          db.GroupMembersCompanion.insert(
            groupId: groupId,
            peerId: peerId,
            joinedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }
    }
  }

  /// Notifies all registered state update callbacks for [groupId].
  void _notifyStateUpdate(String groupId, Group updatedGroup) {
    final listeners = _stateCallbacks[groupId];
    if (listeners == null) return;
    for (final cb in listeners) {
      cb(updatedGroup);
    }
  }

  /// Publishes a sync event to the group's meta topic.
  Future<void> _publishSyncEvent(
    String groupId,
    Map<String, dynamic> event,
  ) async {
    final topic = WakuTopics.groupMetaTopic(groupId);
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(event)));
    await _waku.publish(topic, bytes);
  }
}
