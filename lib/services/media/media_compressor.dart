import 'dart:typed_data';

import 'package:image/image.dart' as img;

/// Result of image compression containing the compressed bytes and metadata.
class CompressedImage {
  const CompressedImage({
    required this.bytes,
    required this.width,
    required this.height,
    required this.originalSize,
    required this.compressedSize,
  });

  /// Compressed image bytes (JPEG).
  final Uint8List bytes;

  /// Width of the compressed image in pixels.
  final int width;

  /// Height of the compressed image in pixels.
  final int height;

  /// Original file size in bytes before compression.
  final int originalSize;

  /// Compressed file size in bytes.
  final int compressedSize;

  /// Compression ratio (compressed / original).
  double get compressionRatio =>
      originalSize > 0 ? compressedSize / originalSize : 1.0;
}

/// Compresses and resizes images for efficient P2P transfer.
///
/// Targets:
/// - Max dimension: 1920px (longest edge)
/// - JPEG quality: 80 for photos
/// - Thumbnail: 200x200 max, quality 60
/// - Max file size target: 1MB for Waku LightPush
class MediaCompressor {
  /// Maximum file size for Waku LightPush transmission (1 MB).
  static const int maxWakuFileSize = 1 * 1024 * 1024;

  /// Compresses image bytes for transmission.
  ///
  /// Decodes the image, resizes if either dimension exceeds [maxWidth] or
  /// [maxHeight], then re-encodes as JPEG at the given [quality].
  ///
  /// Returns a [CompressedImage] with the processed bytes and metadata.
  /// Throws [FormatException] if the image cannot be decoded.
  static Future<CompressedImage> compressImage(
    Uint8List imageBytes, {
    int maxWidth = 1920,
    int maxHeight = 1920,
    int quality = 80,
  }) async {
    final originalSize = imageBytes.length;

    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw const FormatException('Failed to decode image');
    }

    img.Image processed = decoded;

    // Resize if the image exceeds the target dimensions.
    if (decoded.width > maxWidth || decoded.height > maxHeight) {
      processed = img.copyResize(
        decoded,
        width: decoded.width >= decoded.height ? maxWidth : null,
        height: decoded.height > decoded.width ? maxHeight : null,
        interpolation: img.Interpolation.linear,
      );
    }

    final encoded = img.encodeJpg(processed, quality: quality);

    return CompressedImage(
      bytes: Uint8List.fromList(encoded),
      width: processed.width,
      height: processed.height,
      originalSize: originalSize,
      compressedSize: encoded.length,
    );
  }

  /// Generates a thumbnail for preview/embedding in messages.
  ///
  /// The longest edge is scaled to [maxDimension] while preserving aspect
  /// ratio, then encoded as JPEG at [quality].
  static Future<Uint8List> generateThumbnail(
    Uint8List imageBytes, {
    int maxDimension = 200,
    int quality = 60,
  }) async {
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      throw const FormatException('Failed to decode image for thumbnail');
    }

    final resized = img.copyResize(
      decoded,
      width: decoded.width >= decoded.height ? maxDimension : null,
      height: decoded.height > decoded.width ? maxDimension : null,
      interpolation: img.Interpolation.linear,
    );

    final encoded = img.encodeJpg(resized, quality: quality);
    return Uint8List.fromList(encoded);
  }

  /// Returns `true` if [fileSizeBytes] is small enough for Waku LightPush
  /// (< 1 MB).
  static bool canSendViaWaku(int fileSizeBytes) =>
      fileSizeBytes <= maxWakuFileSize;
}
