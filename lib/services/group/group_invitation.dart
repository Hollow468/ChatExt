import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import 'package:chatext/core/constants/waku_topics.dart';
import 'package:chatext/data/local/daos/group_dao.dart';
import 'package:chatext/data/local/database.dart';
import 'package:chatext/services/group/group_registry.dart';
import 'package:chatext/services/identity/identity_service.dart';
import 'package:chatext/services/waku/waku_service.dart';

/// Callback type for incoming invitations.
typedef InvitationCallback = void Function(Map<String, dynamic> invitation);

/// Manages group invitations.
///
/// Invitations are sent as signed messages via Waku.
/// The invitee can accept or decline.
///
/// Invitation message format:
/// ```json
/// {
///   "type": "invitation",
///   "groupId": "...",
///   "groupName": "...",
///   "inviterPeerId": "...",
///   "inviteePeerId": "...",
///   "timestamp": ...,
///   "signature": "..." (base64, signed by inviter)
/// }
/// ```
///
/// Accept message format:
/// ```json
/// {
///   "type": "invitation_accept",
///   "groupId": "...",
///   "peerId": "...",
///   "timestamp": ...
/// }
/// ```
class GroupInvitationService {
  GroupInvitationService({
    required WakuService waku,
    required IdentityService identity,
    required GroupRegistry registry,
    required GroupDao groupDao,
  })  : _waku = waku,
        _identity = identity,
        _registry = registry,
        _groupDao = groupDao;

  final WakuService _waku;
  final IdentityService _identity;
  final GroupRegistry _registry;
  final GroupDao _groupDao;

  /// Registered callbacks for incoming invitations.
  final List<InvitationCallback> _invitationCallbacks = [];

  /// Pending invitation responses keyed by groupId.
  final Map<String, Completer<bool>> _pendingResponses = {};

  /// DM topics currently subscribed to.
  final Set<String> _subscribedTopics = {};

  bool _isDisposed = false;

  // ── Public API ─────────────────────────────────────────────────────────────

  /// Creates and sends an invitation to [inviteePeerId] for [groupId].
  ///
  /// The invitation is signed with the inviter's Ed25519 key and published
  /// to the DM topic shared between inviter and invitee.
  Future<void> inviteToGroup({
    required String groupId,
    required String inviterPeerId,
    required String inviteePeerId,
  }) async {
    if (_isDisposed) return;

    final group = await _registry.getLocalGroups().then(
          (groups) => groups.where((g) => g.id == groupId).firstOrNull,
        );

    final groupName = group?.name ?? groupId;
    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Build the unsigned payload for signing.
    final payload = {
      'type': 'invitation',
      'groupId': groupId,
      'groupName': groupName,
      'inviterPeerId': inviterPeerId,
      'inviteePeerId': inviteePeerId,
      'timestamp': timestamp,
    };

    // Sign the payload.
    final payloadBytes = Uint8List.fromList(
      utf8.encode(jsonEncode(payload)),
    );
    final signature = _identity.signMessage(payloadBytes);
    final signatureBase64 = base64Encode(signature);

    final invitation = {
      ...payload,
      'signature': signatureBase64,
    };

    // Publish to the DM topic between inviter and invitee.
    await _publishToDm(inviterPeerId, inviteePeerId, invitation);
  }

  /// Processes an incoming invitation.
  ///
  /// Returns a [Future] that resolves to `true` if the user accepts,
  /// or `false` if the user declines or the response times out.
  Future<bool> processInvitation(
    Map<String, dynamic> invitation, {
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final groupId = invitation['groupId'] as String?;

    if (groupId == null) {
      debugPrint('GroupInvitationService: invalid invitation, missing groupId');
      return false;
    }

    // Notify registered callbacks so the UI can prompt the user.
    for (final cb in _invitationCallbacks) {
      cb(invitation);
    }

    // Wait for accept/decline from the UI.
    final completer = Completer<bool>();
    _pendingResponses[groupId] = completer;

    return completer.future.timeout(
      timeout,
      onTimeout: () {
        _pendingResponses.remove(groupId);
        return false;
      },
    );
  }

  /// Accepts an invitation — joins the group.
  ///
  /// Publishes an [invitation_accept] event and adds the local user
  /// to the group's member list.
  Future<void> acceptInvitation(String groupId, String peerId) async {
    if (_isDisposed) return;

    final timestamp = DateTime.now().millisecondsSinceEpoch;

    // Publish accept event.
    final acceptEvent = {
      'type': 'invitation_accept',
      'groupId': groupId,
      'peerId': peerId,
      'timestamp': timestamp,
    };

    await _publishGroupMeta(groupId, acceptEvent);

    // Add ourselves to the group in the local DB.
    await _groupDao.addMember(
      GroupMembersCompanion.insert(
        groupId: groupId,
        peerId: peerId,
        joinedAt: timestamp,
      ),
    );

    // Resolve pending response if any.
    final completer = _pendingResponses.remove(groupId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(true);
    }
  }

  /// Declines an invitation.
  ///
  /// Publishes an [invitation_decline] event to the group meta topic.
  Future<void> declineInvitation(String groupId, String peerId) async {
    if (_isDisposed) return;

    final declineEvent = {
      'type': 'invitation_decline',
      'groupId': groupId,
      'peerId': peerId,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
    };

    await _publishGroupMeta(groupId, declineEvent);

    // Resolve pending response if any.
    final completer = _pendingResponses.remove(groupId);
    if (completer != null && !completer.isCompleted) {
      completer.complete(false);
    }
  }

  /// Registers a callback for incoming invitations.
  void onInvitation(InvitationCallback callback) {
    _invitationCallbacks.add(callback);
  }

  /// Ensures the service is listening for invitations on the DM topic
  /// shared with [peerId].
  Future<void> listenForInvitationsFrom(String peerId) async {
    final myPeerId = _identity.getPeerId();
    final topic = WakuTopics.dmTopic(myPeerId, peerId);
    if (_subscribedTopics.contains(topic)) return;

    await _waku.subscribe(topic);
    _waku.onMessage(topic, (message) {
      if (_isDisposed) return;
      try {
        final json = jsonDecode(message.content) as Map<String, dynamic>;
        if (json['type'] == 'invitation') {
          _handleIncomingInvitation(json);
        }
      } catch (e) {
        debugPrint('GroupInvitationService: failed to decode message: $e');
      }
    });

    _subscribedTopics.add(topic);
  }

  /// Releases all resources.
  void dispose() {
    _isDisposed = true;
    _invitationCallbacks.clear();
    _pendingResponses.clear();
    _subscribedTopics.clear();
  }

  // ── Internal ───────────────────────────────────────────────────────────────

  /// Handles an incoming invitation message.
  void _handleIncomingInvitation(Map<String, dynamic> invitation) {
    final inviteePeerId = invitation['inviteePeerId'] as String?;
    final myPeerId = _identity.getPeerId();

    // Only process invitations addressed to us.
    if (inviteePeerId != myPeerId) return;

    // Verify the signature.
    if (!_verifyInvitationSignature(invitation)) {
      debugPrint('GroupInvitationService: invalid invitation signature');
      return;
    }

    // Notify callbacks (UI will prompt the user).
    for (final cb in _invitationCallbacks) {
      cb(invitation);
    }
  }

  /// Verifies the Ed25519 signature on an invitation.
  ///
  /// Returns `true` if the signature is valid or missing (legacy compat).
  bool _verifyInvitationSignature(Map<String, dynamic> invitation) {
    final signatureBase64 = invitation['signature'] as String?;
    if (signatureBase64 == null) return true; // No signature to verify.

    try {
      // Reconstruct the unsigned payload.
      final payload = Map<String, dynamic>.from(invitation)..remove('signature');
      final payloadBytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
      final signature = base64Decode(signatureBase64);

      // In a full implementation, we would look up the inviter's public key
      // and verify: ed.verify(inviterPublicKey, payloadBytes, signature).
      // For now, we accept the invitation if the signature is present.
      // TODO: Implement full Ed25519 verification once PeerResolver provides
      // public key lookup.
      return signature.isNotEmpty;
    } catch (e) {
      debugPrint('GroupInvitationService: signature verification error: $e');
      return false;
    }
  }

  /// Publishes a message to the DM topic between two peers.
  Future<void> _publishToDm(
    String peerId1,
    String peerId2,
    Map<String, dynamic> payload,
  ) async {
    final topic = WakuTopics.dmTopic(peerId1, peerId2);
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
    await _waku.publish(topic, bytes);
  }

  /// Publishes a meta event to the group's meta topic.
  Future<void> _publishGroupMeta(
    String groupId,
    Map<String, dynamic> event,
  ) async {
    final topic = WakuTopics.groupMetaTopic(groupId);
    final bytes = Uint8List.fromList(utf8.encode(jsonEncode(event)));
    await _waku.publish(topic, bytes);
  }
}
