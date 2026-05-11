import 'dart:async';

import 'package:flutter/foundation.dart';

import 'package:chatext/core/constants/waku_topics.dart';
import 'package:chatext/data/models/message.dart';
import 'package:chatext/data/repositories/message_repository.dart';
import 'package:chatext/services/identity/identity_service.dart';
import 'package:chatext/services/identity/peer_resolver.dart';

/// 聊天详情 ViewModel
///
/// 负责加载消息历史、发送消息、监听新消息。
/// 使用 ChangeNotifier 配合 Provider 实现响应式状态管理。
class ChatDetailViewModel extends ChangeNotifier {
  ChatDetailViewModel({
    required this.remotePeerId,
    required IdentityService identityService,
    required MessageRepository messageRepository,
    required PeerResolver peerResolver,
  })  : _identity = identityService,
        _messageRepo = messageRepository,
        _peerResolver = peerResolver;

  /// 对方的 peer ID。
  final String remotePeerId;

  final IdentityService _identity;
  final MessageRepository _messageRepo;
  final PeerResolver _peerResolver;

  /// 消息列表（按时间升序排列）。
  List<Message> _messages = [];
  List<Message> get messages => _messages;

  /// 加载状态。
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 是否正在发送消息。
  bool _isSending = false;
  bool get isSending => _isSending;

  /// 错误信息。
  String? _error;
  String? get error => _error;

  /// 对方的显示名称（缓存）。
  String _displayName = '';
  String get displayName => _displayName;

  /// 当前用户的 peer ID（缓存）。
  String get myPeerId => _identity.getPeerId();

  /// 新消息监听订阅。
  StreamSubscription<Message>? _messageSubscription;

  /// 初始化：加载消息并订阅新消息
  ///
  /// 应在屏幕 initState 中调用。
  Future<void> init() async {
    // 解析对方显示名称
    _displayName = _peerResolver.getDisplayName(remotePeerId);

    // 订阅 Waku 网络上的新消息
    _subscribeToMessages();

    // 加载本地历史消息
    await loadMessages();
  }

  /// 加载本地历史消息
  Future<void> loadMessages() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 获取所有消息并过滤出与当前对话相关的消息
      // 注意：当前 MessageDao 的 topic 过滤不够精确，
      // 此处获取全部消息后在内存中过滤。
      final allMessages = await _messageRepo.getMessages(limit: 200);

      final relevant = allMessages.where((m) {
        // 发送者是我 或 发送者是对方
        return m.sender == myPeerId || m.sender == remotePeerId;
      }).toList();

      // 按时间升序排列（旧的在前，新的在后）
      relevant.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      _messages = relevant;
    } catch (e) {
      _error = '加载消息失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 发送文本消息
  ///
  /// 将消息通过 MessageRepository 发送并更新列表。
  Future<void> sendMessage(String content) async {
    if (content.trim().isEmpty || _isSending) return;

    _isSending = true;
    notifyListeners();

    try {
      final message = await _messageRepo.sendMessage(
        senderPeerId: myPeerId,
        recipientPeerId: remotePeerId,
        content: content.trim(),
      );

      // 将新消息添加到列表末尾
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

  /// 订阅 Waku 网络上的新消息
  void _subscribeToMessages() {
    // 通过 MessageRepository 的 incomingMessages 流监听新消息
    _messageSubscription = _messageRepo.incomingMessages.listen((message) {
      // 仅处理与当前对话相关的消息
      if (message.sender == remotePeerId || message.sender == myPeerId) {
        // 避免重复（发送消息时已在 sendMessage 中添加）
        final isDuplicate = _messages.any((m) => m.id == message.id);
        if (!isDuplicate) {
          _messages = [..._messages, message];
          notifyListeners();
        }
      }
    });

    // 订阅 Waku topic 以接收网络消息
    try {
      final topic = WakuTopics.dmTopic(myPeerId, remotePeerId);
      _messageRepo.subscribeToConversation(
        localPeerId: myPeerId,
        remotePeerId: remotePeerId,
      ).catchError((e) {
        debugPrint('订阅消息 topic 失败 ($topic): $e');
      });
    } catch (e) {
      debugPrint('设置消息订阅失败: $e');
    }
  }

  /// 释放资源
  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }
}
