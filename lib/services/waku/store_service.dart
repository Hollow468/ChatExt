import 'package:flutter/services.dart';

/// Result of a Waku Store query, containing messages and pagination info.
class StoreQueryResult {
  const StoreQueryResult({
    required this.messages,
    this.nextCursor,
    required this.hasMore,
  });

  /// Messages returned by the store node.
  final List<StoreMessage> messages;

  /// Cursor for fetching the next page. `null` when there are no more pages.
  final String? nextCursor;

  /// Whether more messages are available beyond this page.
  final bool hasMore;
}

/// A single message retrieved from the Waku Store.
class StoreMessage {
  const StoreMessage({
    required this.contentTopic,
    required this.payload,
    required this.timestamp,
    this.pubsubTopic,
  });

  /// The content topic the message was published on.
  final String contentTopic;

  /// Raw payload bytes (may be encrypted).
  final Uint8List payload;

  /// Unix timestamp in milliseconds.
  final int timestamp;

  /// The pubsub topic (e.g. `/waku/2/default-waku/proto`).
  final String? pubsubTopic;
}

/// Wraps the Waku Store protocol for querying historical messages.
///
/// Waku Store allows querying messages from dedicated store nodes
/// that keep a record of all relay messages. Queries are paginated
/// with cursors for efficient traversal.
class StoreService {
  static const _channel = MethodChannel('chatext/waku');

  /// Queries the Waku Store for messages matching the given parameters.
  ///
  /// [contentTopics] — list of content topics to query.
  /// [startTime] — start of time range (Unix ms, inclusive).
  /// [endTime] — end of time range (Unix ms, inclusive).
  /// [pageSize] — max messages per page (default 20).
  /// [cursor] — pagination cursor from a previous query.
  /// [direction] — `'forward'` or `'backward'` (default `'backward'` = newest first).
  ///
  /// Returns a [StoreQueryResult] with messages and a cursor for the next page.
  /// Returns an empty result if the native side does not support store queries yet.
  Future<StoreQueryResult> query({
    required List<String> contentTopics,
    int? startTime,
    int? endTime,
    int pageSize = 20,
    String? cursor,
    String direction = 'backward',
  }) async {
    try {
      final result = await _channel.invokeMethod<Map<dynamic, dynamic>>(
        'storeQuery',
        {
          'contentTopics': contentTopics,
          if (startTime != null) 'startTime': startTime,
          if (endTime != null) 'endTime': endTime,
          'pageSize': pageSize,
          if (cursor != null) 'cursor': cursor,
          'direction': direction,
        },
      );

      if (result == null) {
        return const StoreQueryResult(messages: [], hasMore: false);
      }

      final rawMessages = result['messages'] as List<dynamic>? ?? [];
      final messages = rawMessages.map((raw) {
        final map = raw as Map<dynamic, dynamic>;
        return StoreMessage(
          contentTopic: map['contentTopic'] as String,
          payload: Uint8List.fromList((map['payload'] as List).cast<int>()),
          timestamp: map['timestamp'] as int,
          pubsubTopic: map['pubsubTopic'] as String?,
        );
      }).toList();

      return StoreQueryResult(
        messages: messages,
        nextCursor: result['nextCursor'] as String?,
        hasMore: result['hasMore'] as bool? ?? false,
      );
    } on MissingPluginException {
      // Native side does not support store queries yet — degrade gracefully.
      return const StoreQueryResult(messages: [], hasMore: false);
    } on PlatformException {
      return const StoreQueryResult(messages: [], hasMore: false);
    }
  }
}
