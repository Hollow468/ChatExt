# ChatExt

A fully decentralized peer-to-peer instant messaging application built with **Flutter** and **Go-Waku**. No servers, no accounts, no phone numbers — just cryptographic keys and the Waku v2 network.

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                   Flutter (Dart)                     │
│  ┌──────────┐ ┌──────────┐ ┌────────┐ ┌──────────┐ │
│  │  Chat UI  │ │ Contacts │ │ Groups │ │ Settings │ │
│  └────┬─────┘ └────┬─────┘ └───┬────┘ └──────────┘ │
│       │             │           │                    │
│  ┌────┴─────────────┴───────────┴────┐              │
│  │         Service Layer             │              │
│  │  Signal Protocol · Waku Store     │              │
│  │  Identity · Media · Notifications │              │
│  └──────────────┬────────────────────┘              │
│                 │ MethodChannel / EventChannel       │
├─────────────────┼───────────────────────────────────┤
│  ┌──────────────┴────────────────────┐              │
│  │      Kotlin Plugin (Android)      │              │
│  │      ObjC Bridge (iOS)            │              │
│  └──────────────┬────────────────────┘              │
│                 │ gomobile                           │
├─────────────────┼───────────────────────────────────┤
│  ┌──────────────┴────────────────────┐              │
│  │          Go-Waku Node             │              │
│  │  libp2p · Relay · Store · WebRTC  │              │
│  └───────────────────────────────────┘              │
└─────────────────────────────────────────────────────┘
                    ↕ Waku v2 Network
         ┌──────────┬──────────┬──────────┐
         │ Amsterdam│ US Central│ Hong Kong│
         │ Bootstrap│ Bootstrap │ Bootstrap│
         └──────────┴──────────┴──────────┘
```

## Features

- **Decentralized Identity** — Ed25519 key pairs, Base58-encoded peer IDs. No registration, no email, no phone number.
- **E2E Encryption** — Signal Protocol (X3DH + Double Ratchet). Key bundles exchanged via Waku topics; all message content encrypted end-to-end.
- **1-on-1 Chat** — Real-time messaging over Waku Relay with deterministic content topics derived from sorted peer IDs.
- **Group Chat** — UUID-identified groups with Ed25519-signed invitations, metadata broadcast on dedicated Waku meta topics, and periodic state synchronization with conflict resolution.
- **Nicknames & Avatars** — Signed nickname claims broadcast on the Waku presence topic with Ed25519 signature verification.
- **Presence Tracking** — Online/offline peer status via Waku presence topic.
- **Media Sharing** — Image compression, thumbnail generation, and base64 inline transfer via Waku (< 1 MB).
- **History Sync** — Waku Store protocol integration with cursor-based pagination and E2E decryption of historical messages.
- **Offline Persistence** — SQLite (Drift ORM) for messages, contacts, and groups; Hive for identity keys, settings, and Signal Protocol state.
- **Cross-Platform** — Android, iOS, Linux, macOS, Windows, Web.
- **Dark Mode** — Material 3 light/dark themes with system mode support.

## Tech Stack

| Layer | Technology |
|---|---|
| Frontend | Flutter 3.x, Dart 3.x, Provider, GoRouter, Material 3 |
| Native Bridge | Go 1.25, go-waku v0.10.1, gomobile |
| Networking | Waku v2 Relay & Store, libp2p, WebRTC (pion) |
| Encryption | Signal Protocol (libsignal_protocol_dart), Ed25519, AES-256 |
| Database | Drift (SQLite ORM), Hive (key-value) |
| Serialization | Protobuf, JSON (json_serializable) |
| DI | GetIt |

## Project Structure

```
lib/
  core/              # Constants, DI, theme, utilities
  data/              # Models, local DB (Drift tables & DAOs), repositories
  features/
    auth/            # Identity creation (Ed25519 key generation)
    chat/            # 1-on-1 chat screens, viewmodels, widgets
    contacts/        # Contact list and management
    group/           # Group creation, chat, member management
    settings/        # App settings, profile, theme switcher
  navigation/        # GoRouter configuration
  services/
    waku/            # Native bridge, message codec, Store, history sync
    crypto/          # Signal Protocol service, key store, session manager
    identity/        # Identity, peer resolver, nickname, avatar, profile broadcast
    group/           # Group registry, invitations, state sync
    media/           # Image transfer, compression, caching
    push/            # Local notifications, presence tracking
    storage/         # Hive wrapper
native/
  waku_bridge/       # Go-Waku node (bridge.go, mobile.go)
proto/               # Protobuf definitions (ChatMessage, KeyBundle, GroupMeta)
```

## Getting Started

### Prerequisites

- Flutter 3.x with Dart 3.x
- Go 1.25+
- Android NDK 28.2.13676358 (for Android builds)
- gomobile (`go install golang.org/x/mobile/cmd/gomobile@latest && gomobile init`)

### Build

```bash
# Install dependencies
make get

# Generate code (Drift, Hive, JSON serialization)
make build_runner

# Build native Waku library for Android
make build_android

# Build the app
make build
```

### Run

```bash
flutter run
```

### Test

```bash
make test           # All tests
make test_unit      # Unit tests only
make test_widget    # Widget tests only
```

## How It Works

1. **Launch** — The app generates an Ed25519 key pair. Your public key, Base58-encoded, becomes your peer ID.
2. **Connect** — A Go-Waku node starts and connects to Waku network bootstrap nodes.
3. **Discover** — Exchange key bundles with peers via Waku topics to establish Signal Protocol sessions.
4. **Chat** — Messages are encrypted with the Double Ratchet algorithm and published to Waku Relay content topics.
5. **Sync** — Historical messages are retrieved from Waku Store nodes, decrypted, and persisted locally.

## Content Topic Scheme

All Waku content topics follow the naming convention:

```
/waku/2/chatext/1/{type}-{id}/proto
```

| Type | ID | Purpose |
|---|---|---|
| `dm` | `{sorted(peerA, peerB)}` | 1-on-1 direct messages |
| `group` | `{groupId}` | Group messages |
| `group-meta` | `{groupId}` | Group metadata |
| `presence` | `{peerId}` | Online/offline status |
| `keybundle` | `{peerId}` | Signal Protocol key bundles |

## Roadmap

- [x] Phase 1 — MVP: P2P text messaging over Waku
- [x] Phase 2 — E2E encryption, group chat, media sharing, notifications
- [x] Phase 3 — Group registration, nicknames/avatars, history sync, UI polish
- [ ] Phase 4 — WalletConnect integration, on-chain group registration, ENS/DID, IPFS storage

## License

Private project.
