import 'package:hive/hive.dart';

/// Thin wrapper around Hive providing a simplified key-value API
/// identified by box name.
///
/// Boxes are expected to be opened during app startup in
/// [configureDependencies]. This service only accesses already-opened boxes.
class LocalStorage {
  /// Retrieves the value associated with [key] in the box named [box].
  ///
  /// Returns `null` if the key does not exist.
  dynamic get(String box, String key) {
    return _box(box).get(key);
  }

  /// Stores [value] under [key] in the box named [box].
  Future<void> put(String box, String key, dynamic value) {
    return _box(box).put(key, value);
  }

  /// Deletes the entry for [key] in the box named [box].
  Future<void> delete(String box, String key) {
    return _box(box).delete(key);
  }

  /// Removes all entries from the box named [box].
  Future<void> clear(String box) {
    return _box(box).clear();
  }

  /// Returns `true` if a Hive box with the given [name] has been registered.
  bool boxExists(String name) {
    return Hive.isBoxOpen(name);
  }

  // ── internals ──────────────────────────────────────────────────────────────

  Box<dynamic> _box(String name) {
    if (!Hive.isBoxOpen(name)) {
      throw StateError(
        'Hive box "$name" is not open. '
        'Ensure it is opened in configureDependencies().',
      );
    }
    return Hive.box<dynamic>(name);
  }
}
