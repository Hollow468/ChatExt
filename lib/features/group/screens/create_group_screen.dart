import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:chatext/core/di/injection.dart';
import 'package:chatext/data/local/database.dart' hide Group;
import 'package:chatext/data/models/chat_contact.dart';
import 'package:chatext/data/repositories/contact_repository.dart';
import 'package:chatext/services/identity/identity_service.dart';
import 'package:chatext/services/waku/group_topic_manager.dart';
import 'package:chatext/services/waku/waku_service.dart';

/// Screen for creating a new group chat.
///
/// User enters a group name, optionally selects members from their
/// contacts list, then taps create to form the group.
class CreateGroupScreen extends StatefulWidget {
  const CreateGroupScreen({super.key});

  @override
  State<CreateGroupScreen> createState() => _CreateGroupScreenState();
}

class _CreateGroupScreenState extends State<CreateGroupScreen> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  /// Peer IDs selected as group members.
  final Set<String> _selectedPeerIds = {};

  /// Loaded contacts for member selection.
  List<ChatContact> _contacts = [];

  bool _isLoadingContacts = true;
  bool _isCreating = false;

  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _loadContacts() async {
    try {
      final repo = getIt<ContactRepository>();
      _contacts = await repo.getContacts();
    } catch (e) {
      debugPrint('CreateGroupScreen: failed to load contacts: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoadingContacts = false);
      }
    }
  }

  Future<void> _createGroup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isCreating = true);

    try {
      final identity = getIt<IdentityService>();
      final groupDao = getIt<AppDatabase>().groupDao;
      final waku = getIt<WakuService>();
      final topicManager = GroupTopicManager(waku: waku);
      final myPeerId = identity.getPeerId();

      // Generate a group ID from timestamp + peer ID fragment.
      final groupId = DateTime.now().millisecondsSinceEpoch.toString() +
          myPeerId.substring(0, 8);

      // Insert group into DB.
      await groupDao.insertOrUpdateGroup(
        GroupsCompanion.insert(
          id: groupId,
          name: _nameController.text.trim(),
          creatorPeerId: myPeerId,
          createdAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // Add creator as first member.
      await groupDao.addMember(
        GroupMembersCompanion.insert(
          groupId: groupId,
          peerId: myPeerId,
          joinedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );

      // Add selected members.
      for (final peerId in _selectedPeerIds) {
        await groupDao.addMember(
          GroupMembersCompanion.insert(
            groupId: groupId,
            peerId: peerId,
            joinedAt: DateTime.now().millisecondsSinceEpoch,
          ),
        );
      }

      // Subscribe to the group topic and broadcast join events.
      await topicManager.subscribeToGroup(groupId);

      await topicManager.publishMetaEvent(groupId, {
        'type': 'join',
        'peerId': myPeerId,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
      });

      for (final peerId in _selectedPeerIds) {
        await topicManager.publishMetaEvent(groupId, {
          'type': 'join',
          'peerId': peerId,
          'timestamp': DateTime.now().millisecondsSinceEpoch,
        });
      }

      if (mounted) {
        context.push('/group/$groupId');
      }
    } catch (e) {
      debugPrint('CreateGroupScreen: failed to create group: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('创建群组失败: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('创建群组'),
        actions: [
          TextButton(
            onPressed: _isCreating ? null : _createGroup,
            child: _isCreating
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('创建'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Group name field ───────────────────────────────────────────
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '群组名称',
                hintText: '输入群组名称',
                prefixIcon: Icon(Icons.group),
              ),
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return '请输入群组名称';
                }
                return null;
              },
            ),
            const SizedBox(height: 24),

            // ── Member selection ───────────────────────────────────────────
            Text(
              '选择成员',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            if (_isLoadingContacts)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(24),
                  child: CircularProgressIndicator(),
                ),
              )
            else if (_contacts.isEmpty)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    children: [
                      Icon(
                        Icons.person_outline,
                        size: 48,
                        color: colorScheme.onSurfaceVariant
                            .withValues(alpha: 0.4),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '暂无联系人',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '请先添加联系人后再创建群组',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.7),
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else
              ...List.generate(_contacts.length, (index) {
                final contact = _contacts[index];
                final isSelected = _selectedPeerIds.contains(contact.peerId);

                return CheckboxListTile(
                  value: isSelected,
                  onChanged: (checked) {
                    setState(() {
                      if (checked == true) {
                        _selectedPeerIds.add(contact.peerId);
                      } else {
                        _selectedPeerIds.remove(contact.peerId);
                      }
                    });
                  },
                  secondary: CircleAvatar(
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      contact.displayName.isNotEmpty
                          ? contact.displayName[0].toUpperCase()
                          : '?',
                      style:
                          TextStyle(color: colorScheme.onPrimaryContainer),
                    ),
                  ),
                  title: Text(
                    contact.displayName,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    _abbreviatePeerId(contact.peerId),
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: 'monospace',
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                );
              }),
          ],
        ),
      ),
    );
  }

  static String _abbreviatePeerId(String peerId) {
    if (peerId.length <= 12) return peerId;
    return '${peerId.substring(0, 6)}...${peerId.substring(peerId.length - 4)}';
  }
}
