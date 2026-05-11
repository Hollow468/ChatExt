class AppConstants {
  static const String appName = 'ChatExt';
  static const String version = '1.0.0+1';

  // Default Waku node configuration
  static const String defaultWakuHost = '0.0.0.0';
  static const int defaultWakuPort = 60000;

  // Bootstrap nodes for Waku relay network
  static const List<String> bootstrapNodes = [
    '/dns4/node-01.do-ams3.waku.test.statusim.net/tcp/30303/p2p/16Uiu2HAmPLe7Mzm8TsYUubgCAW1aJoeFScxrLj8ppHZ9REq2YDfL',
    '/dns4/node-01.gc-us-central1-a.waku.test.statusim.net/tcp/30303/p2p/16Uiu2HAmJb2e6wuU5PiMXMPGDkPhGvuXBbVNeMXttDyfByJbFGAE',
    '/dns4/node-01.ac-cn-hongkong-c.waku.test.statusim.net/tcp/30303/p2p/16Uiu2HAmPHGZPFHvFsLiRpwVWkqLHhRCRJMRYMKnPMwH8j5VEb3B',
  ];

  // Hive box names
  static const String identityBox = 'identity_box';
  static const String settingsBox = 'settings_box';
  static const String contactsBox = 'contacts_box';
  static const String signalBox = 'signal_keys';
}
