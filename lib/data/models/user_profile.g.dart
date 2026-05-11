// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) => UserProfile(
      peerId: json['peerId'] as String,
      displayName: json['displayName'] as String,
      publicKeyBytes:
          const Uint8ListConverter().fromJson(json['publicKeyBytes'] as String),
      createdAt: (json['createdAt'] as num).toInt(),
    );

Map<String, dynamic> _$UserProfileToJson(UserProfile instance) =>
    <String, dynamic>{
      'peerId': instance.peerId,
      'displayName': instance.displayName,
      'publicKeyBytes':
          const Uint8ListConverter().toJson(instance.publicKeyBytes),
      'createdAt': instance.createdAt,
    };
