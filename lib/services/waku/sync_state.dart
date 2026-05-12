import 'package:hive/hive.dart';

/// Synchronization status for a single conversation topic.
enum SyncStatus {
  /// No sync in progress.
  idle,

  /// Currently fetching history from the store.
  syncing,

  /// Last sync attempt failed.
  error,
}

/// Tracks the synchronization state for each conversation.
///
/// Persists per-topic sync timestamps, pagination cursors, and status
/// in a Hive box named `'sync_state'`.
class SyncStateManager {
  static const String _boxName = 'sync_state';

  late Box<dynamic> _box;

  /// Initializes the sync state manager by opening the Hive box.
  Future<void> init() async {
    _box = await Hive.openBox<dynamic>(_boxName);
  }

  // ── Last sync time ──────────────────────────────────────────────────────────

  /// Gets the last sync timestamp (Unix ms) for [contentTopic].
  int? getLastSyncTime(String contentTopic) {
    return _box.get('$_lastSyncPrefix$contentTopic') as int?;
  }

  /// Updates the last sync timestamp for [contentTopic].
  Future<void> setLastSyncTime(String contentTopic, int timestamp) {
    return _box.put('$_lastSyncPrefix$contentTopic', timestamp);
  }

  // ── Pagination cursor ───────────────────────────────────────────────────────

  /// Gets the stored pagination cursor for [contentTopic].
  String? getCursor(String contentTopic) {
    return _box.get('$_cursorPrefix$contentTopic') as String?;
  }

  /// Updates the pagination cursor for [contentTopic].
  Future<void> setCursor(String contentTopic, String? cursor) {
    if (cursor == null) {
      return _box.delete('$_cursorPrefix$contentTopic');
    }
    return _box.put('$_cursorPrefix$contentTopic', cursor);
  }

  // ── Sync status ─────────────────────────────────────────────────────────────

  /// Gets the current sync status for [contentTopic].
  SyncStatus getStatus(String contentTopic) {
    final index = _box.get('$_statusPrefix$contentTopic') as int?;
    if (index == null || index < 0 || index >= SyncStatus.values.length) {
      return SyncStatus.idle;
    }
    return SyncStatus.values[index];
  }

  /// Updates the sync status for [contentTopic].
  Future<void> setStatus(String contentTopic, SyncStatus status) {
    return _box.put('$_statusPrefix$contentTopic', status.index);
  }

  // ── Clear ───────────────────────────────────────────────────────────────────

  /// Clears all persisted sync state.
  Future<void> clear() {
    return _box.clear();
  }

  // ── Hive key prefixes ───────────────────────────────────────────────────────

  static const _lastSyncPrefix = 'last_sync_';
  static const _cursorPrefix = 'cursor_';
  static const _statusPrefix = 'status_';
}
