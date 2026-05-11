import 'dart:async';
import 'package:flutter/services.dart';

/// Bridge between Dart and the native platform layer that runs the Go-Waku
/// node.
///
/// Outgoing commands (init, publish, subscribe, dispose) are sent over a
/// [MethodChannel]. Incoming messages from the native Waku node are delivered
/// through an [EventChannel] stream so the Dart side never needs to handle
/// reverse method calls.
class WakuNativeBridge {
  static const _methodChannel = MethodChannel('chatext/waku');
  static const _eventChannel = EventChannel('chatext/waku/events');

  StreamSubscription<dynamic>? _eventSubscription;
  void Function(String topic, Uint8List data)? _onMessage;

  // ── public API ─────────────────────────────────────────────────────────────

  /// Starts the underlying Waku node.
  ///
  /// [host] / [port] define the local listen address. [bootnodes] is a list
  /// of multi-address strings used for peer discovery.
  Future<void> init(String host, int port, List<String> bootnodes) async {
    await _methodChannel.invokeMethod<void>('createNode', {
      'host': host,
      'port': port,
      'bootnodes': bootnodes,
    });
  }

  /// Publishes [payload] to the Waku relay network under [topic].
  Future<void> publish(String topic, Uint8List payload) async {
    await _methodChannel.invokeMethod<void>('send', {
      'topic': topic,
      'data': payload,
    });
  }

  /// Subscribes to [topic] so that incoming messages are forwarded to the
  /// Dart side via [setCallback].
  Future<void> subscribe(String topic) async {
    await _methodChannel.invokeMethod<void>('subscribe', {
      'topic': topic,
    });
  }

  /// Registers a [callback] that is invoked each time a message arrives on
  /// any subscribed topic.
  ///
  /// Under the hood this subscribes to the [EventChannel] broadcast stream.
  /// Calling this again replaces the previous listener.
  void setCallback(void Function(String topic, Uint8List data) callback) {
    _onMessage = callback;
    _eventSubscription?.cancel();
    _eventSubscription =
        _eventChannel.receiveBroadcastStream().listen(_onEvent);
  }

  /// Tears down the native Waku node and releases resources.
  Future<void> dispose() async {
    await _eventSubscription?.cancel();
    _eventSubscription = null;
    _onMessage = null;
    await _methodChannel.invokeMethod<void>('stop');
  }

  // ── event handling ─────────────────────────────────────────────────────────

  void _onEvent(dynamic event) {
    final map = event as Map;
    final topic = map['topic'] as String;
    final payload = map['payload'] as Uint8List;
    _onMessage?.call(topic, payload);
  }
}
