import 'package:json_annotation/json_annotation.dart';

part 'chat_contact.g.dart';

/// Data model representing a chat contact / peer.
@JsonSerializable()
class ChatContact {
  /// Creates a new [ChatContact].
  const ChatContact({
    required this.peerId,
    required this.displayName,
    this.avatarUrl,
    this.lastMessageAt,
    this.isOnline = false,
  });

  /// Base58-encoded public key that uniquely identifies this peer.
  final String peerId;

  /// Human-readable display name.
  final String displayName;

  /// Optional URL for the contact's avatar image.
  final String? avatarUrl;

  /// Unix milliseconds of the last message exchanged with this contact.
  final int? lastMessageAt;

  /// Whether the contact is currently online / reachable.
  final bool isOnline;

  // ── JSON serialization ─────────────────────────────────────────────────────

  factory ChatContact.fromJson(Map<String, dynamic> json) =>
      _$ChatContactFromJson(json);

  Map<String, dynamic> toJson() => _$ChatContactToJson(this);

  // ── copyWith ───────────────────────────────────────────────────────────────

  ChatContact copyWith({
    String? peerId,
    String? displayName,
    String? avatarUrl,
    int? lastMessageAt,
    bool? isOnline,
  }) {
    return ChatContact(
      peerId: peerId ?? this.peerId,
      displayName: displayName ?? this.displayName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isOnline: isOnline ?? this.isOnline,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatContact &&
          runtimeType == other.runtimeType &&
          peerId == other.peerId;

  @override
  int get hashCode => peerId.hashCode;
}
