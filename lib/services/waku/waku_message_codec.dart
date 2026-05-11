import 'dart:convert';
import 'dart:typed_data';

/// Placeholder message model used until protobuf code generation is wired up.
///
/// Once `.proto` files are compiled, this class will be replaced by the
/// generated [ChatMessage] and the codec will switch to binary protobuf
/// encoding.
class ChatMessage {
  ChatMessage({
    required this.id,
    required this.senderPeerId,
    required this.content,
    required this.timestamp,
    this.signature,
  });

  final String id;
  final String senderPeerId;
  final String content;
  final int timestamp;
  final Uint8List? signature;

  Map<String, dynamic> toJson() => {
        'id': id,
        'senderPeerId': senderPeerId,
        'content': content,
        'timestamp': timestamp,
        if (signature != null) 'signature': base64Encode(signature!),
      };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
        id: json['id'] as String,
        senderPeerId: json['senderPeerId'] as String,
        content: json['content'] as String,
        timestamp: json['timestamp'] as int,
        signature: json['signature'] != null
            ? base64Decode(json['signature'] as String)
            : null,
      );
}

/// Encodes / decodes [ChatMessage] instances.
///
/// Currently uses JSON as a placeholder. Will be migrated to protobuf once
/// the generated Dart sources are available.
class WakuMessageCodec {
  /// Encodes [message] into bytes (JSON UTF-8).
  Uint8List encode(ChatMessage message) {
    final jsonStr = jsonEncode(message.toJson());
    return Uint8List.fromList(utf8.encode(jsonStr));
  }

  /// Decodes bytes (JSON UTF-8) into a [ChatMessage].
  ChatMessage decode(Uint8List data) {
    final jsonStr = utf8.decode(data);
    final json = jsonDecode(jsonStr) as Map<String, dynamic>;
    return ChatMessage.fromJson(json);
  }
}
