import 'package:flutter/foundation.dart';

import 'package:chatext/data/local/daos/group_dao.dart';
import 'package:chatext/data/local/database.dart';
import 'package:chatext/data/models/message.dart';
import 'package:chatext/features/group/models/group_message.dart';
import 'package:chatext/services/identity/identity_service.dart';
import 'package:chatext/services/waku/group_topic_manager.dart';

/// ViewModel for group chat operations.
///
/// Manages the group message list, sending/receiving messages,
/// and member management (join/leave/add/remove).
class GroupChatViewModel extends ChangeNotifier {
  GroupChatViewModel({
    required this.groupId,
    required IdentityService identityService,
    required GroupTopicManager topicManager,
    required GroupDao groupDao,
  })  : _identity = identityService,
        _topicManager = topicManager,
        _groupDao = groupDao;

  /// The group ID this ViewModel is managing.
  final String groupId;

  final IdentityService _identity;
  final GroupTopicManager _topicManager;
  final GroupDao _groupDao;

  // ── State ──────────────────────────────────────────────────────────────────

  /// Group data (loaded from local DB).
  Group? _group;
  Group? get group => _group;

  /// Messages in this group (chronological order).
  List<GroupMessage> _messages = [];
  List<GroupMessage> get messages => _messages;

  /// Current member peer IDs.
  List<String> _memberPeerIds = [];
  List<String> get memberPeerIds => _memberPeerIds;

  /// Loading state.
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Whether a message is being sent.
  bool _isSending = false;
  bool get isSending => _isSending;

  /// Error message.
  String? _error;
  String? get error => _error;

  /// Current user's peer ID.
  String get myPeerId => _identity.getPeerId();

  /// Whether the current user is the group creator.
  bool get isCreator => _group?.creatorPeerId == myPeerId;

  // ── Initialization ─────────────────────────────────────────────────────────

  /// Initializes the ViewModel: loads group data, subscribes to topics,
  /// and registers message/meta listeners.
  Future<void> init() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Load group from DB.
      _group = await _groupDao.getGroupById(groupId);
      if (_group == null) {
        _error = '群组不存在';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Load members.
      _memberPeerIds = await _groupDao.getMemberPeerIds(groupId);

      // Subscribe to Waku topics.
      await _topicManager.subscribeToGroup(groupId);

      // Listen for incoming group messages.
      _topicManager.onGroupMessage(groupId, _handleIncomingMessage);

      // Listen for meta events.
      _topicManager.onGroupMetaEvent(groupId, _handleMetaEvent);
    } catch (e) {
      _error = '加载群组失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Messaging ──────────────────────────────────────────────────────────────

  /// Sends a text message to the group.
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isSending) return;

    _isSending = true;
    notifyListeners();

    try {
      final message = GroupMessage(
        groupId: groupId,
        sender: myPeerId,
        content: content.trim(),
        timestamp: DateTime.now().millisecondsSinceEpoch,
      );

      // Publish to Waku.
      await _topicManager.publishMessage(groupId, message.toJson());

      // Add to local list.
      _messages = [..._messages, message];
      _error = null;
    } catch (e) {
      _error = '发送消息失败: $e';
      debugPrint(_error);
    } finally {
      _isSending = false;
      notifyListeners();
    }
  }

  // ── Member management ──────────────────────────────────────────────────────

  /// Adds a member to the group and broadcasts a join event.
  Future<void> addMember(String peerId) async {
    if (_memberPeerIds.contains(peerId)) return;

    try {
      await _groupDao.addMember(
        GroupMembersCompanion.insert(
          groupId: groupId,
          peerId: peerId,
          joinedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      _memberPeerIds = [..._memberPeerIds, peerId];
      notifyListeners();

      // Broadcast join event.
      await _topicManager.publishMetaEvent(groupId, {
        'type': 'join',
        'peerId': peerId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      _error = '添加成员失败: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  /// Removes a member from the group and broadcasts a leave event.
  Future<void> removeMember(String peerId) async {
    try {
      await _groupDao.removeMember(groupId, peerId);

      _memberPeerIds = _memberPeerIds.where((id) => id != peerId).toList();
      notifyListeners();

      // Broadcast leave event.
      await _topicManager.publishMetaEvent(groupId, {
        'type': 'leave',
        'peerId': peerId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });
    } catch (e) {
      _error = '移除成员失败: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }

  /// Current user leaves the group.
  Future<void> leaveGroup() async {
    await removeMember(myPeerId);
  }

  // ── Cleanup ────────────────────────────────────────────────────────────────

  @override
  void dispose() {
    _topicManager.unsubscribeFromGroup(groupId);
    super.dispose();
  }

  // ── Internal handlers ──────────────────────────────────────────────────────

  /// Handles an incoming group message from the Waku topic.
  void _handleIncomingMessage(Map<String, dynamic> payload) {
    try {
      final message = GroupMessage.fromJson(payload);

      // Ignore messages not for this group (shouldn't happen, but guard).
      if (message.groupId != groupId) return;

      // Deduplicate.
      final isDuplicate = _messages.any((m) => m.id == message.id);
      if (isDuplicate) return;

      _messages = [..._messages, message];
      notifyListeners();
    } catch (e) {
      debugPrint('GroupChatViewModel: failed to parse incoming message: $e');
    }
  }

  /// Handles an incoming meta event (join, leave, name_change).
  void _handleMetaEvent(Map<String, dynamic> event) {
    final type = event['type'] as String?;
    if (type == null) return;

    switch (type) {
      case 'join':
        final peerId = event['peerId'] as String?;
        if (peerId != null && !_memberPeerIds.contains(peerId)) {
          _memberPeerIds = [..._memberPeerIds, peerId];
          _addSystemMessage('$peerId 加入了群组');
          notifyListeners();
        }
        break;

      case 'leave':
        final peerId = event['peerId'] as String?;
        if (peerId != null) {
          _memberPeerIds =
              _memberPeerIds.where((id) => id != peerId).toList();
          _addSystemMessage('$peerId 离开了群组');
          notifyListeners();
        }
        break;

      case 'name_change':
        final name = event['name'] as String?;
        if (name != null && _group != null) {
          _group = _group!.copyWith(name: name);
          _addSystemMessage('群名称已更改为 $name');
          notifyListeners();
        }
        break;
    }
  }

  /// Adds a system message to the local list (not persisted).
  void _addSystemMessage(String text) {
    final systemMsg = GroupMessage(
      groupId: groupId,
      sender: 'system',
      content: text,
      timestamp: DateTime.now().millisecondsSinceEpoch,
      type: MessageType.system,
    );
    _messages = [..._messages, systemMsg];
  }
}
