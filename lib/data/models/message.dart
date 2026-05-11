import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'message.g.dart';

/// Supported message content types.
enum MessageType {
  @JsonValue(0)
  text,
  @JsonValue(1)
  image,
  @JsonValue(2)
  file,
  @JsonValue(3)
  system,
}

/// Data model representing a single chat message.
@JsonSerializable()
class Message {
  /// Creates a new [Message].
  ///
  /// If [id] is omitted a UUID v4 is generated automatically.
  Message({
    String? id,
    required this.sender,
    required this.content,
    required this.timestamp,
    this.type = MessageType.text,
    this.replyTo,
    this.mediaUrl,
  }) : id = id ?? const Uuid().v4();

  /// Unique message identifier (UUID v4).
  final String id;

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

  factory Message.fromJson(Map<String, dynamic> json) =>
      _$MessageFromJson(json);

  Map<String, dynamic> toJson() => _$MessageToJson(this);

  // ── copyWith ───────────────────────────────────────────────────────────────

  Message copyWith({
    String? id,
    String? sender,
    String? content,
    int? timestamp,
    MessageType? type,
    String? replyTo,
    String? mediaUrl,
  }) {
    return Message(
      id: id ?? this.id,
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
      other is Message &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
