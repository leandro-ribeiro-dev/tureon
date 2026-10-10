# tureon

Flutter client for Tureon's normal and secret chat pipelines.

## Architecture

- `core/network`: gRPC channel, auth metadata, and per-device delivery sync.
  Realtime reconnects are coalesced, but a route change during an active
  reconnect schedules a follow-up so streams are reopened on the latest route.
- `features/chats/domain`: UI-independent chat entities, repository contracts
  and send policies.
- `features/chats/data`: the shared message-delivery gRPC adapter and services.
- `core/crypto`: the client-only libsignal PQXDH/Double Ratchet implementation
  and encrypted protocol-record storage. Widgets never manipulate keys.

Normal chat history and decrypted secret-chat history are local to the device.
Secret ciphertext is persisted only until decryption or failure handling is
complete. Private Signal records are AES-GCM encrypted with a key held by
`flutter_secure_storage`; Android app backup is disabled to avoid restoring a
stale Double Ratchet state. A secret chat is bound to the recipient device
selected before starting it. All message sends, streams, and ACKs flow through
`ChatRepository`; widgets do not call generated messaging RPCs directly.
Pending messages, including bot interactions, remain in the local outbox until
the authenticated chat stream reports readiness. If stream readiness is lost
during a send, in-flight outbox entries return to `PENDING` and are retried
after stream readiness is restored, preserving their original message IDs.
Incoming delivery workers wait for local persistence, never for network ACKs
on the same paused stream. Viewed-message receipts use the durable command
outbox and retry after reconnect. Bounded slices of receipts and mutations
alternate with send batches, preserving per-message command order. The stream
coordinator, delivery router, read-receipt queue, pending-command processor,
message/attachment senders and local-history service have separate files under
`features/chats/data/services`.
See [the chat module guide](lib/features/chats/README.md) for presentation,
translation, attachment acquisition and service responsibilities.
Bot interaction retries reuse the same client message ID; the server reserves
that ID per account in Redis and replays the encrypted original response for
48 hours, exceeding the local outbox's 24-hour retry window.

The local SQLite database is authoritative for the signed-in user's own profile,
conversations, and message history. Profile edits and privacy choices are saved
locally first; a durable sync marker retries publishing a server replica after
the app reconnects. Every authenticated session refresh replaces the local
profile with the complete server profile. Other users' visible profiles are fetched from the server, which
applies the owner's published privacy settings before returning them.
Profile UI observes the local store's profile-change signal as an invalidation
only, then rereads the current account's row from SQLite; the signal does not
carry or cache profile values.

Presence follows foreground app activity: the client stops sending heartbeats
when the app enters the background. The server's short per-device Redis TTL
then expires, and the account is considered offline when no other device has a
live presence key. This prevents suspended or terminated mobile apps from
remaining online indefinitely.

## Generate protobuf stubs

From this directory:

```bash
PATH="$HOME/.pub-cache/bin:$PATH" ./tool/generate_proto.sh
```

The shared source contract lives in `proto/tureon.proto` in the Tureon server
checkout. Generated Dart stubs are included under `lib/generated/proto`.
When this app is checked out separately, set `TUREON_SERVER_ROOT` to the server
checkout before regenerating them.

For separate app and server checkouts:

```bash
TUREON_SERVER_ROOT=/path/to/axiom-server \
  PATH="$HOME/.pub-cache/bin:$PATH" ./tool/generate_proto.sh
```

## Running on Linux

To build and run Tureon on Linux:

```bash
# Run in debug mode
flutter run -d linux

# Build release bundle
flutter build linux
```

## Connecting to the gRPC server

Start the development server from the server repository root in one terminal:

```bash
./run-dev.sh
```

It serves plaintext gRPC on port `50051` and media HTTP on port `8081` for
local development. The app's standard `lib/main.dart` uses `127.0.0.1` by
default on Linux and Android. `run-dev.sh` configures ADB reverse forwarding
for ports `50051` and `8081` and keeps checking for Android devices, so a phone
connected or reconnected after the server starts can reach the same local
endpoint without special Android Studio profiles or `dart-define` arguments.

The script keeps its local JWT signing and delivery-encryption keys in the
Git-ignored `.local-dev-secrets/` directory so server restarts do not invalidate
sessions or strand pending encrypted deliveries. Keep this directory while the
development database contains pending messages. A legacy delivery encrypted
with a lost development key is skipped by the stream and remains queued only
until its normal TTL expires.

Run the normal app configuration after starting the server:

```bash
flutter run -d linux       # Linux debug app
flutter run -d <device>    # Android emulator or USB-connected phone
```

Local loopback connections use plaintext because the development server has no
TLS certificate. Remote hosts always use TLS. The production Android manifest
continues to deny cleartext traffic.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Learn Flutter](https://docs.flutter.dev/get-started/learn-flutter)
- [Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Flutter learning resources](https://docs.flutter.dev/reference/learning-resources)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
