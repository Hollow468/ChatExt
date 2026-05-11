class WakuTopics {
  static String dmTopic(String peerId1, String peerId2) {
    final sorted = [peerId1.toLowerCase(), peerId2.toLowerCase()];
    sorted.sort();
    return '/waku/2/chatext/1/dm-${sorted[0]}-${sorted[1]}/proto';
  }

  static String groupTopic(String groupId) =>
      '/waku/2/chatext/1/group-$groupId/proto';

  static String groupMetaTopic(String groupId) =>
      '/waku/2/chatext/1/group-$groupId-meta/proto';

  static const presence = '/waku/2/chatext/1/presence/proto';
  static const keyBundle = '/waku/2/chatext/1/key-bundle/proto';
}
