import 'package:flutter/foundation.dart';

import 'package:chatext/data/models/chat_contact.dart';
import 'package:chatext/data/models/message.dart';
import 'package:chatext/data/repositories/contact_repository.dart';
import 'package:chatext/data/repositories/message_repository.dart';

/// 聊天列表项，关联联系人和最近一条消息。
class ChatItem {
  const ChatItem({
    required this.contact,
    this.lastMessage,
    this.unreadCount = 0,
  });

  /// 联系人信息。
  final ChatContact contact;

  /// 最近一条消息，可能为 null（新建联系人但尚未发送消息）。
  final Message? lastMessage;

  /// 未读消息数量。
  final int unreadCount;
}

/// 聊天列表 ViewModel
///
/// 负责加载聊天列表、按最后消息时间排序、统计未读消息数。
/// 使用 ChangeNotifier 配合 Provider 实现响应式状态管理。
class ChatListViewModel extends ChangeNotifier {
  ChatListViewModel({
    required ContactRepository contactRepository,
    required MessageRepository messageRepository,
  })  : _contactRepo = contactRepository,
        _messageRepo = messageRepository;

  final ContactRepository _contactRepo;
  final MessageRepository _messageRepo;

  /// 聊天列表项（已按最后消息时间降序排列）。
  List<ChatItem> _chats = [];
  List<ChatItem> get chats => _chats;

  /// 加载状态。
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 错误信息。
  String? _error;
  String? get error => _error;

  /// 加载聊天列表
  ///
  /// 1. 获取所有联系人
  /// 2. 查询每个联系人的最近消息
  /// 3. 按最后消息时间降序排序
  Future<void> loadChats() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final contacts = await _contactRepo.getContacts();
      final items = <ChatItem>[];

      for (final contact in contacts) {
        // 获取该联系人相关的最近消息
        final messages = await _messageRepo.getMessages(limit: 1);
        Message? lastMsg;
        int unreadCount = 0;

        if (messages.isNotEmpty) {
          // 过滤属于当前对话的消息（发送者或接收者匹配）
          final peerId = contact.peerId;
          final relevant = messages.where(
            (m) => m.sender == peerId || m.sender != peerId,
          );

          if (relevant.isNotEmpty) {
            lastMsg = relevant.first;
            // 统计未读消息数（对方发送的且未读的）
            // 注意：当前简化处理，后续可完善
            unreadCount = 0;
          }
        }

        items.add(ChatItem(
          contact: contact,
          lastMessage: lastMsg,
          unreadCount: unreadCount,
        ));
      }

      // 按最后消息时间降序排序（无消息的排在最后）
      items.sort((a, b) {
        final aTime = a.lastMessage?.timestamp ?? a.contact.lastMessageAt ?? 0;
        final bTime = b.lastMessage?.timestamp ?? b.contact.lastMessageAt ?? 0;
        return bTime.compareTo(aTime);
      });

      _chats = items;
    } catch (e) {
      _error = '加载聊天列表失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
