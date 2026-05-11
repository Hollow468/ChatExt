import 'dart:io';
import 'dart:typed_data';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Local cache for media files (images, thumbnails).
///
/// Stores files in the app's cache directory under `media_cache/`.
/// Thumbnails are stored separately for quick access.
///
/// Cache structure:
///   {appCacheDir}/media_cache/
///     full/{messageId}.{ext}
///     thumb/{messageId}.{ext}
class MediaCache {
  static const String _cacheDir = 'media_cache';
  static const String _fullDir = 'full';
  static const String _thumbDir = 'thumb';

  late final Directory _root;
  late final Directory _fullRoot;
  late final Directory _thumbRoot;

  bool _initialized = false;

  /// Initializes the cache directories.
  ///
  /// Must be called before any other method. Safe to call multiple times.
  Future<void> init() async {
    if (_initialized) return;

    final appCache = await getApplicationCacheDirectory();
    _root = Directory(p.join(appCache.path, _cacheDir));
    _fullRoot = Directory(p.join(_root.path, _fullDir));
    _thumbRoot = Directory(p.join(_root.path, _thumbDir));

    await _fullRoot.create(recursive: true);
    await _thumbRoot.create(recursive: true);

    _initialized = true;
  }

  /// Saves a full-resolution media file and returns the [File] handle.
  Future<File> saveFullImage(
    String messageId,
    Uint8List bytes, {
    String ext = 'jpg',
  }) async {
    _ensureInitialized();
    final file = File(p.join(_fullRoot.path, '$messageId.$ext'));
    return file.writeAsBytes(bytes, flush: true);
  }

  /// Saves a thumbnail and returns the [File] handle.
  Future<File> saveThumbnail(
    String messageId,
    Uint8List bytes, {
    String ext = 'jpg',
  }) async {
    _ensureInitialized();
    final file = File(p.join(_thumbRoot.path, '$messageId.$ext'));
    return file.writeAsBytes(bytes, flush: true);
  }

  /// Loads a full-resolution image from cache, or `null` if not present.
  Future<Uint8List?> loadFullImage(String messageId) async {
    _ensureInitialized();
    return _loadFrom(_fullRoot, messageId);
  }

  /// Loads a thumbnail from cache, or `null` if not present.
  Future<Uint8List?> loadThumbnail(String messageId) async {
    _ensureInitialized();
    return _loadFrom(_thumbRoot, messageId);
  }

  /// Checks if a full image is cached for [messageId].
  bool hasFullImage(String messageId) {
    _ensureInitialized();
    return _existsIn(_fullRoot, messageId);
  }

  /// Checks if a thumbnail is cached for [messageId].
  bool hasThumbnail(String messageId) {
    _ensureInitialized();
    return _existsIn(_thumbRoot, messageId);
  }

  /// Clears the entire media cache.
  Future<void> clearCache() async {
    _ensureInitialized();
    if (await _root.exists()) {
      await _root.delete(recursive: true);
    }
    await _fullRoot.create(recursive: true);
    await _thumbRoot.create(recursive: true);
  }

  /// Returns total cache size in bytes.
  Future<int> getCacheSize() async {
    _ensureInitialized();
    int total = 0;
    if (await _root.exists()) {
      await for (final entity in _root.list(recursive: true)) {
        if (entity is File) {
          total += await entity.length();
        }
      }
    }
    return total;
  }

  // ── internal ───────────────────────────────────────────────────────────────

  void _ensureInitialized() {
    if (!_initialized) {
      throw StateError('MediaCache.init() must be called before use');
    }
  }

  /// Loads the first matching file for [messageId] in [dir], regardless of
  /// extension. Returns `null` if no match is found.
  Future<Uint8List?> _loadFrom(Directory dir, String messageId) async {
    if (!await dir.exists()) return null;

    await for (final entity in dir.list()) {
      if (entity is File && p.basenameWithoutExtension(entity.path) == messageId) {
        return entity.readAsBytes();
      }
    }
    return null;
  }

  /// Returns `true` if any file named `messageId.*` exists in [dir].
  bool _existsIn(Directory dir, String messageId) {
    if (!dir.existsSync()) return false;

    for (final entity in dir.listSync()) {
      if (entity is File &&
          p.basenameWithoutExtension(entity.path) == messageId) {
        return true;
      }
    }
    return false;
  }
}
