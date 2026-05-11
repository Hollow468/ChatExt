// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatContact _$ChatContactFromJson(Map<String, dynamic> json) => ChatContact(
      peerId: json['peerId'] as String,
      displayName: json['displayName'] as String,
      avatarUrl: json['avatarUrl'] as String?,
      lastMessageAt: (json['lastMessageAt'] as num?)?.toInt(),
      isOnline: json['isOnline'] as bool? ?? false,
    );

Map<String, dynamic> _$ChatContactToJson(ChatContact instance) =>
    <String, dynamic>{
      'peerId': instance.peerId,
      'displayName': instance.displayName,
      'avatarUrl': instance.avatarUrl,
      'lastMessageAt': instance.lastMessageAt,
      'isOnline': instance.isOnline,
    };
