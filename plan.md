# ChatExt - P2P + Blockchain IM 实施计划

## 概述

基于 **Go-Waku** (去中心化消息协议) + **Flutter** (跨平台移动端) 构建的 P2P 即时通讯应用。
用户可通过 **Ed25519 密钥对**（纯 P2P 模式）或 **以太坊钱包**（区块链模式）生成去中心化身份，消息经 Waku Relay 网络点对点传输，支持端到端加密。
区块链模式额外支持：链上群组注册、ENS/DID 身份解析、IPFS 去中心化媒体存储。

---

## 技术栈选型

| 层 | 技术 | 说明 |
|---|---|---|
| 移动端 UI | Flutter 3.x + Dart 3.x | 跨平台 iOS/Android |
| 消息传输 | Go-Waku (gomobile bindings) | Waku v2 Relay/Store/LightPush |
| 身份系统 | ed25519 密钥对 + hive | 本地生成密钥对作为去中心化身份（纯 P2P 模式） |
| 钱包连接 | reown_appkit + web3dart | WalletConnect v2 协议 + 链上交互（区块链模式） |
| E2E 加密 | libsignal_protocol_dart | Signal Protocol Dart 移植 |
| 媒体传输 | P2P 直传 + Waku LightPush | 小文件通过 Waku 传输，大文件走 WebRTC |
| 去中心化存储 | IPFS (Pinata/Web3.Storage) | 区块链模式下的文件存储（可选） |
| 本地持久化 | drift (SQLite) + hive | 消息缓存 + 轻量KV |
| 推送通知 | Firebase Cloud Messaging | 离线推送 |

---

## 开发实施计划

### 阶段一: MVP (第 1-4 周)

**目标**: 能通过 Waku 网络发送和接收文本消息的最小可用产品。

#### 1.1 项目结构

```
ChatExt/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── core/
│   │   ├── constants/
│   │   │   ├── waku_topics.dart        # Content topic 定义
│   │   │   └── app_constants.dart
│   │   ├── di/
│   │   │   └── injection.dart           # GetIt 依赖注入
│   │   ├── theme/
│   │   │   └── app_theme.dart
│   │   └── utils/
│   │       ├── timestamp.dart
│   │       └── key_utils.dart           # 密钥对生成/管理
│   ├── data/
│   │   ├── models/
│   │   │   ├── message.dart             # 消息数据模型
│   │   │   ├── chat_contact.dart        # 联系人模型
│   │   │   └── user_profile.dart        # 用户 profile (含公钥 ID)
│   │   ├── local/
│   │   │   ├── database.dart            # drift 数据库定义
│   │   │   ├── tables/
│   │   │   │   ├── messages.dart
│   │   │   │   └── contacts.dart
│   │   │   └── daos/
│   │   │       ├── message_dao.dart
│   │   │       └── contact_dao.dart
│   │   └── repositories/
│   │       ├── message_repository.dart
│   │       └── contact_repository.dart
│   ├── services/
│   │   ├── waku/
│   │   │   ├── waku_service.dart        # Go-Waku 绑定封装
│   │   │   ├── waku_native_bridge.dart  # FFI / MethodChannel 桥接
│   │   │   └── waku_message_codec.dart  # Protobuf 编解码
│   │   ├── identity/
│   │   │   ├── identity_service.dart    # 密钥对身份管理
│   │   │   └── peer_resolver.dart       # 公钥 ID → 节点地址解析
│   │   └── storage/
│   │       └── local_storage.dart       # Hive KV 存储
│   ├── features/
│   │   ├── auth/
│   │   │   ├── screens/
│   │   │   │   └── create_identity_screen.dart
│   │   │   └── widgets/
│   │   │       └── identity_button.dart
│   │   ├── chat/
│   │   │   ├── screens/
│   │   │   │   ├── chat_list_screen.dart
│   │   │   │   └── chat_detail_screen.dart
│   │   │   ├── viewmodels/
│   │   │   │   ├── chat_list_viewmodel.dart
│   │   │   │   └── chat_detail_viewmodel.dart
│   │   │   └── widgets/
│   │   │       ├── message_bubble.dart
│   │   │       └── message_input.dart
│   │   └── contacts/
│   │       ├── screens/
│   │       │   └── contact_list_screen.dart
│   │       └── viewmodels/
│   │           └── contact_viewmodel.dart
│   └── navigation/
│       └── app_router.dart
├── native/                              # Go-Waku 原生代码
│   ├── waku_bridge/
│   │   ├── bridge.go                    # Go-Waku 与 Flutter 的桥接层
│   │   ├── mobile.go                    # gomobile 导出定义
│   │   └── go.mod
│   ├── build_android.sh                 # gomobile 编译脚本
│   └── build_ios.sh
├── test/
│   ├── unit/
│   │   ├── waku_message_codec_test.dart
│   │   ├── message_repository_test.dart
│   │   └── identity_service_test.dart
│   ├── integration/
│   │   ├── waku_relay_test.dart
│   │   └── chat_flow_test.dart
│   └── widget/
│       ├── chat_list_test.dart
│       └── message_bubble_test.dart
├── pubspec.yaml
└── Makefile                             # 构建自动化
```

#### 1.2 关键依赖 (pubspec.yaml)

```yaml
dependencies:
  flutter:
    sdk: flutter

  # 状态管理
  provider: ^6.1.0

  # 身份系统
  ed25519_edwards: ^0.3.1            # Ed25519 密钥对生成
  pointycastle: ^3.7.3               # 加密原语

  # 本地存储
  drift: ^2.14.0                     # SQLite ORM
  hive: ^2.2.3                       # 轻量 KV 存储
  hive_flutter: ^1.1.0

  # 序列化
  json_annotation: ^4.8.1
  protobuf: ^3.1.0                   # Waku 消息 protobuf 编解码

  # 路由
  go_router: ^13.0.0

  # DI
  get_it: ^7.6.0

  # UI
  google_fonts: ^6.1.0
  cached_network_image: ^3.3.0

dev_dependencies:
  build_runner: ^2.4.0
  drift_dev: ^2.14.0
  hive_generator: ^2.0.1
  json_serializable: ^6.7.1
  protoc_plugin: ^21.1.0
  mockito: ^5.4.4
  flutter_test:
    sdk: flutter
```

#### 1.3 Go-Waku 桥接层 (native/waku_bridge/)

**bridge.go** - 封装核心 Waku 操作:

```go
package waku_bridge

import (
    "github.com/waku-org/go-waku/waku/v2/node"
    "github.com/waku-org/go-waku/waku/v2/protocol/relay"
)

// WakuManager 管理 Waku 节点生命周期
type WakuManager struct {
    node *node.WakuNode
}

// NewWakuManager 创建并启动 Waku 节点
// host: 监听地址, port: 端口, bootstrapNodes: 引导节点列表
func NewWakuManager(host string, port int, bootstrapNodes []string) (*WakuManager, error)

// Subscribe 订阅 content topic, 返回消息通道
func (w *WakuManager) Subscribe(contentTopic string) (<-chan *WakuMessage, error)

// Publish 发布消息到 content topic
func (w *WakuManager) Publish(contentTopic string, payload []byte, timestamp int64) error

// Stop 停止节点
func (w *WakuManager) Stop()
```

**mobile.go** - gomobile 导出:

```go
// +build android ios

package waku_bridge

// MobileWakuManager 供 gomobile 导出的简化接口
type MobileWakuManager struct {
    mgr *WakuManager
}

func CreateNode(host string, port int, bootnodes string) (*MobileWakuManager, error)
func (m *MobileWakuManager) Send(topic string, data []byte) error
func (m *MobileWakuManager) SetCallback(cb MessageCallback)
func (m *MobileWakuManager) Stop()
```

**编译脚本** (build_android.sh):

```bash
#!/bin/bash
export ANDROID_HOME=$HOME/Android/Sdk
export ANDROID_NDK_HOME=$ANDROID_HOME/ndk/26.1.10909125
export PATH=$PATH:$(go env GOPATH)/bin

gomobile bind -target=android -o android/app/libs/waku.aar \
    -javapkg=org.chatext.waku \
    ./native/waku_bridge/
```

#### 1.4 Dart 侧 Waku 桥接 (waku_native_bridge.dart)

```dart
// 使用 MethodChannel 调用原生 Go-Waku 绑定
class WakuNativeBridge {
  static const _channel = MethodChannel('chatext/waku');

  Future<void> init(String host, int port, List<String> bootnodes) async {
    await _channel.invokeMethod('createNode', {
      'host': host, 'port': port, 'bootnodes': bootnodes
    });
  }

  Future<void> publish(String topic, Uint8List payload) async {
    await _channel.invokeMethod('send', {
      'topic': topic, 'data': payload
    });
  }

  void onMessage(void Function(String topic, Uint8List data) callback) {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onMessage') {
        callback(call.arguments['topic'], call.arguments['data']);
      }
    });
  }
}
```

#### 1.5 Waku Content Topic 设计

```dart
class WakuTopics {
  // 1v1 私聊: 用双方公钥 ID 派生 topic 保证唯一性
  static String dmTopic(String peerId1, String peerId2) {
    final sorted = [peerId1.toLowerCase(), peerId2.toLowerCase()];
    sorted.sort();
    return '/waku/2/chatext/1/dm-${sorted[0]}-${sorted[1]}/proto';
  }

  // 在线状态
  static const presence = '/waku/2/chatext/1/presence/proto';
}
```

#### 1.6 消息数据模型 (Protobuf)

```protobuf
syntax = "proto3";
package chatext;

message ChatMessage {
  string id = 1;              // UUID v4
  string sender = 2;          // 发送者公钥 ID (Base58)
  string content = 3;         // 文本内容
  int64 timestamp = 4;        // Unix 毫秒时间戳
  MessageType type = 5;       // 消息类型
  string reply_to = 6;        // 回复消息ID (可选)
  string media_url = 7;       // 媒体文件 URL (阶段二使用)
}

enum MessageType {
  TEXT = 0;
  IMAGE = 1;
  FILE = 2;
  SYSTEM = 3;
}
```

#### 1.7 身份创建流程

```
用户打开 App
    ↓
CreateIdentityScreen → 本地生成 Ed25519 密钥对
    ↓
公钥哈希(Base58) → 作为用户唯一身份 ID
    ↓
初始化 Waku 节点 → 订阅与自己的 DM topic
    ↓
进入 ChatListScreen
```

#### 1.8 阶段一测试策略

| 测试类型 | 覆盖内容 | 工具 |
|---|---|---|
| 单元测试 | Protobuf 编解码、Topic 派生、密钥格式化 | flutter_test |
| 集成测试 | Go-Waku 桥接层消息收发 | 本地 2 节点测试 |
| Widget 测试 | 消息气泡渲染、输入框交互 | flutter_test |
| 手动测试 | 双机 Relay 消息收发全流程 | Android/iOS 真机 |

---

### 阶段二: 核心功能 (第 5-8 周)

**目标**: 加密通讯、群聊、媒体传输、离线推送。

#### 2.1 E2E 加密实现

**新增文件**:
```
lib/services/crypto/
├── signal_service.dart         # Signal Protocol 封装
├── key_store.dart              # 密钥持久化 (Hive)
├── session_manager.dart        # 会话管理 (X3DH + Double Ratchet)
└── crypto_utils.dart           # 公钥 ID ↔ SignalAddress 映射
```

**依赖新增**:
```yaml
dependencies:
  libsignal_protocol_dart: ^0.6.6   # Signal Protocol Dart 移植
```

**流程**:
```
首次与某用户聊天:
  1. 从 Waku 获取对方 IdentityKey (预发布到 Waku presence topic)
  2. X3DH 密钥协商 → 建立 Signal Session
  3. Double Ratchet 加密每条消息
  4. 加密后的密文作为 ChatMessage.content 通过 Waku 发送

消息解密:
  1. 收到 Waku 消息 → 查找本地 Session
  2. Double Ratchet 解密 → 明文显示
```

**密钥交换策略**: 用户注册时将 IdentityKey + SignedPreKey + OneTimePreKeys 打包发布到 Waku 的专用 key-bundle topic。

#### 2.2 群聊实现

**新增文件**:
```
lib/features/group/
├── models/
│   └── group.dart                    # 群组模型
├── screens/
│   ├── create_group_screen.dart
│   └── group_chat_screen.dart
├── viewmodels/
│   └── group_chat_viewmodel.dart
└── widgets/
    └── group_member_list.dart

lib/services/waku/
└── group_topic_manager.dart          # 群聊 topic 管理
```

**Content Topic 设计**:
```
群聊 topic: /waku/2/chatext/1/group-{groupId}/proto

群组管理 topic: /waku/2/chatext/1/group-{groupId}-meta/proto
  - 加入/退出通知
  - 群名称/头像变更
  - 成员列表同步
```

**加密方案**: 群聊使用 Sender Key 模式 (Signal Protocol 的群聊扩展)。创建者生成 Group Session Key，通过 1v1 加密通道分发给每个成员。

#### 2.3 媒体分享

**新增文件**:
```
lib/services/media/
├── media_transfer.dart               # P2P 媒体传输
├── media_compressor.dart             # 图片/视频压缩
└── media_cache.dart                  # 本地缓存管理
```

**依赖新增**:
```yaml
dependencies:
  image: ^4.1.3                      # 图片处理/压缩
  path_provider: ^2.1.0              # 本地文件路径
```

**流程**:
```
发送图片:
  1. 选择/拍摄图片 → 压缩至合适尺寸
  2. 通过 Waku LightPush 分块传输 (小文件 < 1MB)
     或通过 WebRTC DataChannel 直传 (大文件)
  3. 缩略图 base64 嵌入消息体
  4. 通过 Waku 发送消息

接收图片:
  1. 收到消息 → 显示缩略图 (base64)
  2. 点击查看 → 通过 P2P 通道接收原图
  3. 缓存到本地
```

#### 2.4 推送通知

**新增文件**:
```
lib/services/push/
├── fcm_service.dart                  # Firebase Cloud Messaging
├── push_registry.dart                # 注册推送 token
└── notification_handler.dart         # 通知展示/点击处理
```

**依赖新增**:
```yaml
dependencies:
  firebase_core: ^2.24.0
  firebase_messaging: ^14.7.0
  flutter_local_notifications: ^17.0.0
```

**策略**: Waku LightPush + FCM 联合方案:
- 在线消息: 直接通过 Waku Relay 接收
- 离线消息: 发送方同时通过 LightPush 推送到通知服务节点，节点触发 FCM 推送
- FCM token 注册到专用 Waku topic

#### 2.5 阶段二测试策略

| 测试类型 | 覆盖内容 |
|---|---|
| 单元测试 | Signal 加密/解密、Sender Key 分发、媒体分块编码 |
| 集成测试 | 完整加密会话建立、群聊创建+消息、图片上传下载 |
| 安全测试 | 密钥泄露检测、重放攻击防护、消息篡改检测 |
| 端到端测试 | 3 设备群聊、离线推送到达率 |

---

### 阶段三: P2P 增强 (第 9-11 周)

**目标**: P2P 群组管理、用户昵称系统、消息历史同步、App 打磨。

#### 3.1 P2P 群组注册

**新增文件**:
```
lib/services/group/
├── group_registry.dart               # 群组元数据管理 (Waku DHT)
├── group_invitation.dart             # 群组邀请机制
└── group_sync.dart                   # 群组状态同步
```

**群组管理方案** (基于 Waku):
```
群组创建:
  1. 创建者生成 GroupId (随机 UUID)
  2. 创建 GroupMetaMessage (名称、头像、成员列表)
  3. 通过 Waku Relay 广播到群组 topic
  4. 成员通过邀请链接/二维码加入

群组加入:
  1. 收到邀请 → 确认加入
  2. 向群组 topic 发布 MemberJoin 消息
  3. 其他成员同步更新成员列表

群组解散:
  1. 创建者发布 GroupDissolve 消息
  2. 所有成员清除本地群组数据
```

#### 3.2 用户昵称系统

**新增文件**:
```
lib/services/identity/
├── nickname_service.dart             # 昵称注册/解析
├── avatar_service.dart               # 头像管理
└── profile_broadcast.dart            # 个人信息广播
```

**昵称方案**:
```
注册昵称:
  1. 用户设置昵称 → 生成 NicknameClaim 消息
  2. 签名后发布到 Waku presence topic
  3. 其他用户验证签名后缓存昵称映射

显示优先级: 用户自设昵称 > 公钥缩写 (PubK1234...5678)
```

#### 3.3 消息历史同步 (Waku Store)

**新增文件**:
```
lib/services/waku/
├── store_service.dart                # Waku Store 协议封装
├── history_sync.dart                 # 历史消息同步逻辑
└── sync_state.dart                   # 同步状态管理
```

**流程**:
```
打开聊天:
  1. 查询本地最后一条消息的时间戳
  2. 通过 Waku Store 协议查询该时间之后的历史消息
  3. 解密并写入本地数据库
  4. 更新 UI

首次与某人聊天:
  1. 查询 Store 获取该 content topic 的所有历史消息
  2. 分页加载 (每页 20 条)
```

**Waku Store 查询参数**:
```dart
class StoreQuery {
  final List<String> contentTopics;
  final int startTime;    // Unix ms
  final int endTime;      // Unix ms
  final int pageSize;     // 默认 20
  final String? cursor;   // 分页游标
  final Direction direction; // FORWARD / BACKWARD
}
```

#### 3.4 App 打磨

**新增文件**:
```
lib/core/
├── error_handling/
│   ├── app_error.dart
│   └── error_handler.dart
├── logging/
│   └── logger.dart
└── analytics/
    └── privacy_friendly_analytics.dart  # 本地统计, 不上传

lib/features/settings/
├── screens/
│   ├── settings_screen.dart
│   └── profile_screen.dart
└── widgets/
    └── theme_switcher.dart

lib/features/chat/widgets/
├── message_status_indicator.dart     # 已发送/已读状态
├── typing_indicator.dart             # 正在输入
└── reply_preview.dart                # 回复预览
```

#### 3.5 阶段三测试策略

| 测试类型 | 覆盖内容 |
|---|---|
| 单元测试 | 群组邀请、昵称签名验证、头像压缩 |
| 集成测试 | 群组创建+加入+解散全流程、昵称注册解析 |
| 性能测试 | 大消息量 Store 查询、100人群聊消息延迟 |
| 安全测试 | 邀请伪造防护、昵称冒充检测 |
| UI/UX 测试 | 暗色模式、无障碍、多语言 |

---

### 阶段四: 区块链增强 (第 12-15 周)

**目标**: 钱包连接身份、链上群组注册、ENS/DID 集成、IPFS 媒体存储。

#### 4.1 钱包连接与身份绑定

**新增文件**:
```
lib/services/wallet/
├── wallet_service.dart               # 钱包连接管理
├── wallet_provider.dart              # WalletConnect provider
└── wallet_identity_bridge.dart       # 钱包地址 ↔ P2P 身份绑定
```

**依赖新增**:
```yaml
dependencies:
  reown_appkit: ^1.0.0               # WalletConnect dApp SDK
  web3dart: ^2.7.0                    # Ethereum RPC 交互
```

**身份绑定流程**:
```
用户选择钱包登录:
  1. 调用 reown_appkit 发起 WalletConnect 会话
  2. 用户在 MetaMask/Trust Wallet 等签名
  3. 获取钱包地址 → 绑定到现有 P2P 身份
  4. 链上签名验证 → 确认身份所有权

双模式身份:
  - 纯 P2P 模式: Ed25519 密钥对 (默认)
  - 区块链模式: 以太坊钱包地址 + ENS 域名
  - 两种模式可共存，钱包地址绑定到已有 P2P peer ID
```

#### 4.2 链上群组注册

**新增文件**:
```
lib/services/contracts/
├── group_registry.dart               # 群组合约交互
├── contract_abi.dart                 # ABI 定义
└── contract_service.dart             # 合约部署/调用封装

contracts/
├── GroupRegistry.sol                 # Solidity 源码
├── hardhat.config.js
└── deploy/
    └── deploy_registry.js
```

**智能合约** (GroupRegistry.sol):
```solidity
pragma solidity ^0.8.20;

contract GroupRegistry {
    struct Group {
        address creator;
        string name;
        string avatarCid;        // IPFS CID
        bytes32 topicHash;       // Waku topic 的 keccak256
        uint256 createdAt;
        bool exists;
    }

    mapping(bytes32 => Group) public groups;
    mapping(bytes32 => mapping(address => bool)) public members;

    event GroupCreated(bytes32 indexed groupId, address creator, string name);
    event MemberAdded(bytes32 indexed groupId, address member);
    event MemberRemoved(bytes32 indexed groupId, address member);

    function createGroup(bytes32 groupId, string name, string avatarCid) external;
    function joinGroup(bytes32 groupId) external;
    function leaveGroup(bytes32 groupId) external;
    function isMember(bytes32 groupId, address account) external view returns (bool);
    function getGroup(bytes32 groupId) external view returns (Group memory);
}
```

**链上 + P2P 混合方案**:
```
群组创建 (区块链模式):
  1. 创建者生成 GroupId
  2. 调用 GroupRegistry.createGroup() 链上注册
  3. 同时通过 Waku Relay 广播 GroupMetaMessage
  4. 链上记录作为群组所有权的唯一真相源

群组加入 (区块链模式):
  1. 调用 GroupRegistry.joinGroup() 链上加入
  2. 向 Waku 群组 topic 发布 MemberJoin 消息
  3. 其他成员通过链上验证确认加入合法性
```

#### 4.3 ENS / DID 集成

**新增文件**:
```
lib/services/identity/
├── ens_service.dart                  # ENS 域名解析
├── did_service.dart                  # DID:ethr 解析
└── display_name_resolver.dart        # 统一显示名称解析
```

**依赖新增**:
```yaml
dependencies:
  ens_dart: ^0.1.0                    # ENS 解析 (或自行用 web3dart 实现)
```

**显示优先级**: ENS 域名 > DID > 用户自设昵称 > 钱包地址缩写 (0x1234...5678) > 公钥缩写 (PubK1234...5678)

#### 4.4 IPFS 去中心化媒体存储

**新增文件**:
```
lib/services/media/
├── ipfs_service.dart                 # IPFS 上传/下载
└── ipfs_cache.dart                   # IPFS 内容本地缓存
```

**依赖新增**:
```yaml
dependencies:
  ipfs_http_client: ^3.0.0           # IPFS HTTP API 客户端
```

**流程** (区块链模式):
```
发送图片:
  1. 选择/拍摄图片 → 压缩至合适尺寸
  2. 上传至 IPFS (Pinata / Web3.Storage)
  3. 获取 CID → 填入 ChatMessage.media_url
  4. 通过 Waku 发送消息 (内容为 CID + 缩略图 base64)

接收图片:
  1. 收到消息 → 显示缩略图 (base64)
  2. 点击查看 → 从 IPFS 网关下载原图
  3. 缓存到本地
```

#### 4.5 阶段四测试策略

| 测试类型 | 覆盖内容 |
|---|---|
| 合约测试 | Hardhat 单元测试: 创建群、加入/退出、权限检查 |
| 集成测试 | 钱包连接、ENS 解析、链上群组 CRUD、IPFS 上传下载 |
| 安全审计 | 智能合约审计 (Slither/Mythril)、签名验证 |
| 性能测试 | IPFS 上传延迟、链上交易确认时间 |
| 兼容测试 | 纯 P2P 模式与区块链模式的互操作性 |

---

## 跨阶段集成点

### Flutter ↔ Go-Waku 通信架构

```
Flutter (Dart)                    Native (Go)
┌─────────────┐                  ┌─────────────────┐
│ WakuService │ ←─ MethodChannel ─→│ bridge.go       │
│             │    or dart:ffi    │                 │
│  subscribe()│ ──────────────→  │ Subscribe()     │
│  publish()  │ ──────────────→  │ Publish()       │
│  onMessage()│ ←──────────────  │ callback(msg)   │
└─────────────┘                  └─────────────────┘
```

### 数据流

```
[发送消息]
用户输入 → ViewModel → MessageRepository
  → SignalService.encrypt() → WakuService.publish()
  → WakuNativeBridge → Go-Waku Relay → P2P 网络

[接收消息]
Go-Waku Relay → callback → WakuNativeBridge
  → WakuService → MessageRepository
  → SignalService.decrypt() → ViewModel → UI 更新
  → 本地 SQLite 持久化
```

---

## 依赖总览

### Go Modules (native/waku_bridge/go.mod)

```
module chatext/waku-bridge

go 1.22

require (
    github.com/waku-org/go-waku v0.8.0
    google.golang.org/protobuf v1.33.0
)

// + indirect dependencies...
```

### Flutter (pubspec.yaml) - 完整依赖汇总

| 阶段 | 包 | 用途 |
|---|---|---|
| 一 | ed25519_edwards, pointycastle | 身份系统 |
| 一 | drift, hive | 本地存储 |
| 一 | protobuf, go_router, provider, get_it | 基础设施 |
| 二 | libsignal_protocol_dart | E2E 加密 |
| 二 | image, path_provider | 媒体分享 |
| 二 | firebase_messaging, flutter_local_notifications | 推送通知 |
| 三 | (无新增) | 群组/昵称基于 Waku 实现 |
| 四 | reown_appkit, web3dart | 钱包连接 + 链上交互 |
| 四 | ens_dart | ENS 域名解析 |
| 四 | ipfs_http_client | IPFS 去中心化存储 |

---

## 风险与缓解

| 风险 | 影响 | 缓解 |
|---|---|---|
| go-waku gomobile 编译问题 | 阻塞移动端集成 | 备选方案: 使用 nwaku C 库 + dart:ffi |
| Waku 网络节点不足 | 消息延迟高 | 自建 BootNode + 使用 Waku fleets |
| libsignal_protocol_dart 不够成熟 | 加密有 bug | 自行用 dart:ffi 绑定 Rust libsignal |
| 无官方 Flutter Waku SDK | 集成工作量大 | 优先验证 gomobile → MethodChannel 链路 |
| 大文件 P2P 传输不可靠 | 媒体分享体验差 | 分块传输 + 断点续传 + 备用中继服务器 |
| WalletConnect 兼容性 | 部分钱包连接失败 | 多 provider 支持 + 降级到纯 P2P 模式 |
| IPFS 网关不稳定 | 媒体加载慢/失败 | 多网关备选 + 本地缓存 + P2P 直传降级 |
| 智能合约 gas 费用 | 用户体验差 | 部署到 L2 (Polygon/Arbitrum) + 批量交易 |
| 链上交易确认延迟 | 群组操作卡顿 | 乐观更新 UI + Waku 消息即时生效 |

---

## 立即可执行的第一步

1. 初始化 Flutter 项目: `flutter create --org org.chatext ChatExt`
2. 验证 go-waku 编译: clone go-waku, 运行 `gomobile bind` 确认 Android/iOS 构建可行
3. 搭建最小 Waku relay 测试: 两个 Go 进程互发消息验证协议可用
4. Flutter 中实现 MethodChannel 桥接, 从 Go 侧收发一条消息
5. (阶段四准备) 注册 WalletConnect Cloud 项目: https://cloud.walletconnect.com/
6. (阶段四准备) 配置 IPFS Pinata/Web3.Storage API key
