import 'dart:convert';
import 'dart:typed_data';

import 'package:uuid/uuid.dart';

import 'package:chatext/services/waku/waku_service.dart';

import 'media_cache.dart';
import 'media_compressor.dart';

/// Result of sending media over the network.
class SendResult {
  const SendResult({
    required this.messageId,
    required this.thumbnailBytes,
    required this.fileSize,
    required this.sentViaWaku,
  });

  /// Unique identifier for this media message.
  final String messageId;

  /// Generated thumbnail bytes (for display in the chat before full load).
  final Uint8List thumbnailBytes;

  /// Total file size in bytes of the (possibly compressed) media.
  final int fileSize;

  /// `true` if the full image was embedded in the Waku message,
  /// `false` if only a thumbnail was sent (file too large).
  final bool sentViaWaku;
}

/// Metadata about a received media item.
class ReceivedMedia {
  const ReceivedMedia({
    this.fullImageBytes,
    required this.thumbnailBytes,
    required this.mimeType,
    required this.fileName,
    required this.fileSize,
  });

  /// Full-resolution image bytes, or `null` when only the thumbnail arrived
  /// (file was too large for inline transfer).
  final Uint8List? fullImageBytes;

  /// Thumbnail bytes always present for quick preview.
  final Uint8List thumbnailBytes;

  /// MIME type of the media (e.g. `image/jpeg`).
  final String mimeType;

  /// Original file name.
  final String fileName;

  /// File size in bytes.
  final int fileSize;
}

/// Handles P2P media transfer via Waku.
///
/// Strategy:
/// - Small files (< 1 MB): Send via Waku LightPush as base64 chunks.
/// - Large files: Placeholder for future WebRTC DataChannel transfer.
///
/// Message format for media:
/// ```json
/// {
///   "type": "media",
///   "mimeType": "image/jpeg",
///   "fileName": "photo.jpg",
///   "thumbnail": "<base64>",
///   "data": "<base64>",
///   "fileSize": 123456,
///   "width": 1920,
///   "height": 1080
/// }
/// ```
class MediaTransferService {
  MediaTransferService({
    required WakuService waku,
    MediaCache? cache,
  })  : _waku = waku,
        _cache = cache ?? MediaCache();

  final WakuService _waku;
  final MediaCache _cache;
  final _uuid = const Uuid();

  /// Sends an image via Waku.
  ///
  /// 1. Compress the image
  /// 2. Generate thumbnail
  /// 3. If small enough, embed as base64 in message
  /// 4. Publish via Waku
  ///
  /// Returns a [SendResult] describing what was sent.
  Future<SendResult> sendImage({
    required String topic,
    required Uint8List imageBytes,
    required String fileName,
    required String senderPeerId,
  }) async {
    // Compress for transfer.
    final compressed = await MediaCompressor.compressImage(imageBytes);
    final thumbnail = await MediaCompressor.generateThumbnail(imageBytes);

    final messageId = _uuid.v4();
    final canInline = MediaCompressor.canSendViaWaku(compressed.compressedSize);

    // Build the media payload.
    final payload = <String, dynamic>{
      'type': 'media',
      'messageId': messageId,
      'sender': senderPeerId,
      'mimeType': _guessMimeType(fileName),
      'fileName': fileName,
      'thumbnail': base64Encode(thumbnail),
      'fileSize': compressed.compressedSize,
      'width': compressed.width,
      'height': compressed.height,
    };

    if (canInline) {
      payload['data'] = base64Encode(compressed.bytes);
    }

    // Publish as JSON-encoded bytes.
    final jsonBytes = Uint8List.fromList(utf8.encode(jsonEncode(payload)));
    await _waku.publish(topic, jsonBytes);

    return SendResult(
      messageId: messageId,
      thumbnailBytes: thumbnail,
      fileSize: compressed.compressedSize,
      sentViaWaku: canInline,
    );
  }

  /// Processes an incoming media message.
  ///
  /// Decodes base64 data when present and caches the result locally.
  Future<ReceivedMedia> processIncomingMedia(
    Map<String, dynamic> mediaData,
  ) async {
    final mimeType = mediaData['mimeType'] as String? ?? 'application/octet-stream';
    final fileName = mediaData['fileName'] as String? ?? 'unknown';
    final fileSize = (mediaData['fileSize'] as num?)?.toInt() ?? 0;
    final messageId = mediaData['messageId'] as String? ?? _uuid.v4();

    final thumbBase64 = mediaData['thumbnail'] as String?;
    final thumbnailBytes = thumbBase64 != null
        ? base64Decode(thumbBase64)
        : Uint8List(0);

    Uint8List? fullBytes;
    final dataBase64 = mediaData['data'] as String?;
    if (dataBase64 != null && dataBase64.isNotEmpty) {
      fullBytes = base64Decode(dataBase64);

      // Cache the full image locally.
      final ext = _extensionFromMime(mimeType);
      await _cache.saveFullImage(messageId, fullBytes, ext: ext);
    }

    // Always cache the thumbnail.
    if (thumbnailBytes.isNotEmpty) {
      await _cache.saveThumbnail(messageId, thumbnailBytes);
    }

    return ReceivedMedia(
      fullImageBytes: fullBytes,
      thumbnailBytes: thumbnailBytes,
      mimeType: mimeType,
      fileName: fileName,
      fileSize: fileSize,
    );
  }

  // ── helpers ────────────────────────────────────────────────────────────────

  /// Guesses a MIME type from the file extension.
  static String _guessMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'application/octet-stream';
  }

  /// Returns a short file extension for a MIME type (without the dot).
  static String _extensionFromMime(String mime) {
    switch (mime) {
      case 'image/jpeg':
        return 'jpg';
      case 'image/png':
        return 'png';
      case 'image/gif':
        return 'gif';
      case 'image/webp':
        return 'webp';
      default:
        return 'bin';
    }
  }
}
