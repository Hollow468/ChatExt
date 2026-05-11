// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'group.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Group _$GroupFromJson(Map<String, dynamic> json) => Group(
      id: json['id'] as String?,
      name: json['name'] as String,
      creatorPeerId: json['creatorPeerId'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      description: json['description'] as String?,
      createdAt: (json['createdAt'] as num?)?.toInt(),
      memberPeerIds: (json['memberPeerIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$GroupToJson(Group instance) => <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'creatorPeerId': instance.creatorPeerId,
      'avatarUrl': instance.avatarUrl,
      'description': instance.description,
      'createdAt': instance.createdAt,
      'memberPeerIds': instance.memberPeerIds,
    };
