import 'package:flutter/foundation.dart';

import 'package:chatext/core/utils/key_utils.dart';
import 'package:chatext/data/models/chat_contact.dart';
import 'package:chatext/data/repositories/contact_repository.dart';
import 'package:chatext/services/identity/peer_resolver.dart';

/// 联系人 ViewModel
///
/// 负责联系人的加载、添加、搜索等操作。
/// 使用 ChangeNotifier 配合 Provider 实现响应式状态管理。
class ContactViewModel extends ChangeNotifier {
  ContactViewModel({
    required ContactRepository contactRepository,
    required PeerResolver peerResolver,
  })  : _contactRepo = contactRepository,
        _peerResolver = peerResolver;

  final ContactRepository _contactRepo;
  final PeerResolver _peerResolver;

  /// 当前显示的联系人列表。
  List<ChatContact> _contacts = [];
  List<ChatContact> get contacts => _contacts;

  /// 加载状态。
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// 错误信息。
  String? _error;
  String? get error => _error;

  /// 当前搜索关键词。
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  /// 加载所有联系人
  Future<void> loadContacts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _contacts = await _contactRepo.getContacts();
    } catch (e) {
      _error = '加载联系人失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 添加新联系人
  ///
  /// [peerId] 对方的 Base58 编码公钥 ID。
  /// [displayName] 对方的显示名称。
  ///
  /// 添加后自动刷新列表。
  Future<bool> addContact(String peerId, String displayName) async {
    _error = null;
    notifyListeners();

    try {
      // 将 peer ID 解码为公钥字节
      final publicKeyBytes = KeyUtils.peerIdToPublicKeyBytes(peerId);

      await _contactRepo.addContact(
        peerId: peerId,
        displayName: displayName,
        publicKeyData: publicKeyBytes,
      );

      // 同时缓存到 PeerResolver 以便后续解析
      await _peerResolver.cachePeerMapping(peerId, displayName);

      // 刷新列表
      await loadContacts();
      return true;
    } catch (e) {
      _error = '添加联系人失败: $e';
      debugPrint(_error);
      notifyListeners();
      return false;
    }
  }

  /// 搜索联系人
  ///
  /// [query] 搜索关键词，匹配显示名称。
  /// 空字符串时显示全部联系人。
  Future<void> searchContacts(String query) async {
    _searchQuery = query;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (query.trim().isEmpty) {
        _contacts = await _contactRepo.getContacts();
      } else {
        _contacts = await _contactRepo.searchContacts(query);
      }
    } catch (e) {
      _error = '搜索联系人失败: $e';
      debugPrint(_error);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 删除联系人
  Future<void> deleteContact(String peerId) async {
    try {
      await _contactRepo.deleteContact(peerId);
      await loadContacts();
    } catch (e) {
      _error = '删除联系人失败: $e';
      debugPrint(_error);
      notifyListeners();
    }
  }
}
