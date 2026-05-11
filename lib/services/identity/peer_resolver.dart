import '../../core/constants/app_constants.dart';
import '../storage/local_storage.dart';

/// Maps peer IDs (Base58-encoded Ed25519 public keys) to human-readable
/// display names.
///
/// A simple Hive-backed cache is used so that mappings survive app restarts.
class PeerResolver {
  PeerResolver({LocalStorage? storage}) : _storage = storage ?? LocalStorage();

  final LocalStorage _storage;

  static const _box = AppConstants.contactsBox;

  // ── public API ─────────────────────────────────────────────────────────────

  /// Returns the display name for [peerId].
  ///
  /// If a cached mapping exists it is returned; otherwise a shortened form of
  /// the peer ID is shown (first 6 + last 4 characters separated by "…").
  String getDisplayName(String peerId) {
    final cached = _storage.get(_box, peerId) as String?;
    if (cached != null && cached.isNotEmpty) {
      return cached;
    }
    return _abbreviatedId(peerId);
  }

  /// Attempts to resolve the peer ID to a display name.
  ///
  /// Currently this simply returns the cached name or the abbreviated ID.
  /// A future implementation may query a Waku-based name registry.
  String resolvePeerId(String peerId) {
    return getDisplayName(peerId);
  }

  /// Persists a human-readable [displayName] for the given [peerId].
  Future<void> cachePeerMapping(String peerId, String displayName) {
    return _storage.put(_box, peerId, displayName);
  }

  // ── internals ──────────────────────────────────────────────────────────────

  /// Produces a short, recognizable abbreviation of a Base58 peer ID.
  static String _abbreviatedId(String id) {
    if (id.length <= 12) return id;
    return '${id.substring(0, 6)}...${id.substring(id.length - 4)}';
  }
}
