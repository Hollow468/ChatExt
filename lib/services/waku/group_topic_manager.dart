import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';

import 'package:chatext/core/constants/waku_topics.dart';
import 'package:chatext/services/waku/waku_service.dart';

/// Callback type for group message events.
typedef GroupMessageCallback = void Function(Map<String, dynamic> payload);

/// Callback type for group meta events (join, leave, name change).
typedef GroupMetaCallback = void Function(Map<String, dynamic> event);

/// Manages Waku topic subscriptions for group chats.
///
/// Handles subscribing to group content topics and meta topics,
/// publishing messages, and dispatching incoming messages to
/// registered listeners.
class GroupTopicManager {
  GroupTopicManager({required WakuService waku}) : _waku = waku;

  final WakuService _waku;

  /// Registered message callbacks keyed by group ID.
  final Map<String, List<GroupMessageCallback>> _messageCallbacks = {};

  /// Registered meta event callbacks keyed by group ID.
  final Map<String, List<GroupMetaCallback>> _metaCallbacks = {};

  /// Set of group IDs currently subscribed to.
  final Set<String> _subscribedGroups = {};

  bool _isDisposed = false;

  // ── Subscription management ────────────────────────────────────────────────

  /// Subscribes to the content topic and meta topic for [groupId].
  ///
  /// Safe to call multiple times — duplicate subscriptions are ignored.
  Future<void> subscribeToGroup(String groupId) async {
    if (_isDisposed) return;
    if (_subscribedGroups.contains(groupId)) return;

    final contentTopic = WakuTopics.groupTopic(groupId);
    final metaTopic = WakuTopics.groupMetaTopic(groupId);

    await _waku.subscribe(contentTopic);
    await _waku.subscribe(metaTopic);

    // Register Waku message listeners for both topics.
    _waku.onMessage(contentTopic, (message) {
      if (_isDisposed) return;
      try {
        final json = jsonDecode(message.content) as Map<String, dynamic>;
        _dispatchGroupMessage(groupId, json);
      } catch (e) {
        debugPrint('GroupTopicManager: failed to decode group message: $e');
      }
    });

    _waku.onMessage(metaTopic, (message) {
      if (_isDisposed) return;
      try {
        final json = jsonDecode(message.content) as Map<String, dynamic>;
        _dispatchMetaEvent(groupId, json);
      } catch (e) {
        debugPrint('GroupTopicManager: failed to decode meta event: $e');
      }
    });

    _subscribedGroups.add(groupId);
  }

  /// Unsubscribes from the content topic and meta topic for [groupId].
  ///
  /// Removes all registered callbacks for this group.
  void unsubscribeFromGroup(String groupId) {
    _messageCallbacks.remove(groupId);
    _metaCallbacks.remove(groupId);
    _subscribedGroups.remove(groupId);
  }

  // ── Publishing ─────────────────────────────────────────────────────────────

  /// Publishes a JSON-encoded [payload] to the group content topic.
  Future<void> publishMessage(
    String groupId,
    Map<String, dynamic> payload,
  ) async {
    if (_isDisposed) return;

    final topic = WakuTopics.groupTopic(groupId);
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
    await _waku.publish(topic, bytes);
  }

  /// Publishes a meta event (join, leave, name_change) to the group meta topic.
  Future<void> publishMetaEvent(
    String groupId,
    Map<String, dynamic> event,
  ) async {
    if (_isDisposed) return;

    final topic = WakuTopics.groupMetaTopic(groupId);
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(event)));
    await _waku.publish(topic, bytes);
  }

  // ── Listener registration ──────────────────────────────────────────────────

  /// Registers a [callback] that is invoked when a message arrives
  /// on the group content topic for [groupId].
  void onGroupMessage(String groupId, GroupMessageCallback callback) {
    _messageCallbacks.putIfAbsent(groupId, () => []).add(callback);
  }

  /// Registers a [callback] that is invoked when a meta event arrives
  /// on the group meta topic for [groupId].
  void onGroupMetaEvent(String groupId, GroupMetaCallback callback) {
    _metaCallbacks.putIfAbsent(groupId, () => []).add(callback);
  }

  // ── Cleanup ────────────────────────────────────────────────────────────────

  /// Releases all resources and clears callbacks.
  void dispose() {
    _isDisposed = true;
    _messageCallbacks.clear();
    _metaCallbacks.clear();
    _subscribedGroups.clear();
  }

  // ── Internal dispatch ──────────────────────────────────────────────────────

  void _dispatchGroupMessage(String groupId, Map<String, dynamic> payload) {
    final listeners = _messageCallbacks[groupId];
    if (listeners == null) return;
    for (final cb in listeners) {
      cb(payload);
    }
  }

  void _dispatchMetaEvent(String groupId, Map<String, dynamic> event) {
    final listeners = _metaCallbacks[groupId];
    if (listeners == null) return;
    for (final cb in listeners) {
      cb(event);
    }
  }
}
