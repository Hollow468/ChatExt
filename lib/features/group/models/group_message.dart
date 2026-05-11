import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

import 'package:chatext/data/models/message.dart';

part 'group_message.g.dart';

/// A message within a group chat.
///
/// Similar to [Message] but includes a [groupId] field to identify
/// which group the message belongs to.
@JsonSerializable()
class GroupMessage {
  /// Creates a new [GroupMessage].
  ///
  /// If [id] is omitted a UUID v4 is generated automatically.
  GroupMessage({
    String? id,
    required this.groupId,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.replyTo,
    this.mediaUrl,
  }) : id = id ?? const Uuid().v4();

  /// Unique message identifier (UUID v4).
  final String id;

  /// ID of the group this message belongs to.
  final String groupId;

  /// Base58-encoded public key of the sender.
  final String sender;

  /// Plain-text content of the message.
  final String content;

  /// Unix timestamp in milliseconds.
  final int timestamp;

  /// Type of message content.
  final MessageType type;

  /// Optional ID of the message being replied to.
  final String? replyTo;

  /// Optional URL for media attachments (images, files).
  final String? mediaUrl;

  // ── JSON serialization ─────────────────────────────────────────────────────

  factory GroupMessage.fromJson(Map<String, dynamic> json) =>
      _$GroupMessageFromJson(json);

  Map<String, dynamic> toJson() => _$GroupMessageToJson(this);

  // ── copyWith ───────────────────────────────────────────────────────────────

  GroupMessage copyWith({
    String? id,
    String? groupId,
    String? sender,
    String? content,
    int? timestamp,
    MessageType? type,
    String? replyTo,
    String? mediaUrl,
  }) {
    return GroupMessage(
      id: id ?? this.id,
      groupId: groupId ?? this.groupId,
      sender: sender ?? this.sender,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      type: type ?? this.type,
      replyTo: replyTo ?? this.replyTo,
      mediaUrl: mediaUrl ?? this.mediaUrl,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupMessage &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
