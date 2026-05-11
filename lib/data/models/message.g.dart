// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Message _$MessageFromJson(Map<String, dynamic> json) => Message(
      id: json['id'] as String?,
      sender: json['sender'] as String,
      content: json['content'] as String,
      timestamp: (json['timestamp'] as num).toInt(),
      type: $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
          MessageType.text,
      replyTo: json['replyTo'] as String?,
      mediaUrl: json['mediaUrl'] as String?,
    );

Map<String, dynamic> _$MessageToJson(Message instance) => <String, dynamic>{
      'id': instance.id,
      'sender': instance.sender,
      'content': instance.content,
      'timestamp': instance.timestamp,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'replyTo': instance.replyTo,
      'mediaUrl': instance.mediaUrl,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 0,
  MessageType.image: 1,
  MessageType.file: 2,
  MessageType.system: 3,
};
