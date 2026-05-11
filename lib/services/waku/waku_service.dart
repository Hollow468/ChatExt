import 'dart:typed_data';

import 'waku_message_codec.dart';
import 'waku_native_bridge.dart';

/// High-level abstraction over the Waku relay network.
///
/// [WakuService] hides the native bridge details and exposes a clean API for
/// subscribing to content topics, publishing messages, and receiving
/// decoded [ChatMessage] instances.
abstract class WakuService {
  /// Initializes the underlying Waku node and connects to [bootnodes].
  Future<void> init(String host, int port, List<String> bootnodes);

  /// Subscribes to [contentTopic].
  Future<void> subscribe(String contentTopic);

  /// Publishes [payload] (raw bytes) to [contentTopic].
  Future<void> publish(String contentTopic, Uint8List payload);

  /// Registers a [callback] that is invoked with a decoded [ChatMessage]
  /// whenever a message arrives on [topic].
  void onMessage(String topic, void Function(ChatMessage message) callback);

  /// Shuts down the Waku node and frees resources.
  Future<void> dispose();
}

/// Default implementation backed by [WakuNativeBridge].
///
/// Uses [WakuNativeBridge.setCallback] to listen for messages arriving on the
/// native [EventChannel] stream.  The callback must be registered *before*
/// [init] so that no messages are lost between node creation and subscription.
class WakuServiceImpl implements WakuService {
  WakuServiceImpl({
    WakuNativeBridge? bridge,
    WakuMessageCodec? codec,
  })  : _bridge = bridge ?? WakuNativeBridge(),
        _codec = codec ?? WakuMessageCodec();

  final WakuNativeBridge _bridge;
  final WakuMessageCodec _codec;

  /// topic → list of registered callbacks.
  final Map<String, List<void Function(ChatMessage)>> _callbacks = {};

  bool _isDisposed = false;

  @override
  Future<void> init(String host, int port, List<String> bootnodes) async {
    // Register the EventChannel listener before creating the node so that
    // no incoming messages are missed.
    _bridge.setCallback(_onRawMessage);
    await _bridge.init(host, port, bootnodes);
  }

  @override
  Future<void> subscribe(String contentTopic) async {
    await _bridge.subscribe(contentTopic);
  }

  @override
  Future<void> publish(String contentTopic, Uint8List payload) async {
    await _bridge.publish(contentTopic, payload);
  }

  @override
  void onMessage(String topic, void Function(ChatMessage message) callback) {
    _callbacks.putIfAbsent(topic, () => []).add(callback);
  }

  @override
  Future<void> dispose() async {
    _isDisposed = true;
    _callbacks.clear();
    await _bridge.dispose();
  }

  // ── internal ───────────────────────────────────────────────────────────────

  /// Handles raw bytes arriving from the native EventChannel.
  /// Guarded by [_isDisposed] to silently drop late-arriving events that
  /// land between [dispose] being called and the EventChannel subscription
  /// being cancelled on the native side.
  void _onRawMessage(String topic, Uint8List data) {
    if (_isDisposed) return;
    final message = _codec.decode(data);
    final listeners = _callbacks[topic];
    if (listeners == null) return;
    for (final cb in listeners) {
      cb(message);
    }
  }
}
