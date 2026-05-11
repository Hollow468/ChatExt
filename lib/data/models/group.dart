import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';

part 'group.g.dart';

/// Data model representing a chat group.
@JsonSerializable()
class Group {
  Group({
    String? id,
    required this.name,
    required this.creatorPeerId,
    this.avatarUrl,
    this.description,
    int? createdAt,
    List<String>? memberPeerIds,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now().millisecondsSinceEpoch,
        memberPeerIds = memberPeerIds ?? [];

  /// Unique group identifier (UUID v4).
  final String id;

  /// Display name of the group.
  final String name;

  /// Peer ID of the group creator / admin.
  final String creatorPeerId;

  /// Optional avatar URL.
  final String? avatarUrl;

  /// Optional group description.
  final String? description;

  /// Unix timestamp in milliseconds when the group was created.
  final int createdAt;

  /// List of member peer IDs.
  final List<String> memberPeerIds;

  factory Group.fromJson(Map<String, dynamic> json) => _$GroupFromJson(json);

  Map<String, dynamic> toJson() => _$GroupToJson(this);

  Group copyWith({
    String? id,
    String? name,
    String? creatorPeerId,
    String? avatarUrl,
    String? description,
    int? createdAt,
    List<String>? memberPeerIds,
  }) {
    return Group(
      id: id ?? this.id,
      name: name ?? this.name,
      creatorPeerId: creatorPeerId ?? this.creatorPeerId,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      memberPeerIds: memberPeerIds ?? this.memberPeerIds,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Group && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
