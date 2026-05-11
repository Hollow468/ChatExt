import 'dart:convert';
import 'dart:typed_data';

import 'package:json_annotation/json_annotation.dart';

part 'user_profile.g.dart';

/// Custom converter for [Uint8List] ↔ Base64 string in JSON.
class Uint8ListConverter implements JsonConverter<Uint8List, String> {
  const Uint8ListConverter();

  @override
  Uint8List fromJson(String json) => base64Decode(json);

  @override
  String toJson(Uint8List object) => base64Encode(object);
}

/// Data model for the local user's identity profile.
@JsonSerializable()
class UserProfile {
  /// Creates a new [UserProfile].
  const UserProfile({
    required this.peerId,
    required this.displayName,
    required this.publicKeyBytes,
    required this.createdAt,
  });

  /// Base58-encoded public key serving as the peer identifier.
  final String peerId;

  /// User-chosen display name.
  final String displayName;

  /// Raw Ed25519 public key bytes.
  @Uint8ListConverter()
  final Uint8List publicKeyBytes;

  /// Account creation time as Unix milliseconds.
  final int createdAt;

  // ── JSON serialization ─────────────────────────────────────────────────────

  factory UserProfile.fromJson(Map<String, dynamic> json) =>
      _$UserProfileFromJson(json);

  Map<String, dynamic> toJson() => _$UserProfileToJson(this);

  // ── copyWith ───────────────────────────────────────────────────────────────

  UserProfile copyWith({
    String? peerId,
    String? displayName,
    Uint8List? publicKeyBytes,
    int? createdAt,
  }) {
    return UserProfile(
      peerId: peerId ?? this.peerId,
      displayName: displayName ?? this.displayName,
      publicKeyBytes: publicKeyBytes ?? this.publicKeyBytes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserProfile &&
          runtimeType == other.runtimeType &&
          peerId == other.peerId;

  @override
  int get hashCode => peerId.hashCode;
}
