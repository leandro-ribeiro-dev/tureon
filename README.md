# Tureon

Tureon is a Flutter messaging client for private conversations, groups, and
channels. It combines familiar chat features with local message history and a
separate end-to-end encrypted secret-chat flow.

> Tureon is under active development. Review the security model and deployment
> setup before using it for sensitive conversations.

## Features

- Direct and group conversations, channels, contacts, and user profiles.
- Secret chats using the Signal protocol through `libsignal` (PQXDH and Double
  Ratchet). The server handles secret-chat ciphertext as opaque data.
- A durable local outbox that retries pending messages after the connection is
  restored.
- Local chat history, presence, bots, and file attachments.
- Flutter client that communicates with a separate Go backend through shared
  gRPC contracts.

## Security and data

Normal chat history and decrypted secret-chat history stay on the device. The
server queues deliveries and acknowledgements; it does not own the client's
chat history. Secret-chat protocol records are encrypted locally with
AES-GCM, and their key is held by `flutter_secure_storage`. Android app backup
is disabled to avoid restoring stale Signal state.

Local development uses plaintext only for loopback connections. Remote
connections use TLS, and the production Android manifest blocks cleartext
traffic.

## Run locally

Install Flutter with a Dart SDK that satisfies the constraint in
[`pubspec.yaml`](pubspec.yaml), then fetch dependencies:

```bash
flutter pub get
```

Start the development server from the Axiom Server checkout:

```bash
./run-dev.sh
```

From this directory, run the client on Linux or a connected Android device:

```bash
flutter run -d linux
# or
flutter run -d <device>
```

The development server listens on gRPC port `50051` and media HTTP port `8081`.
On Android, `run-dev.sh` configures ADB reverse forwarding for these ports.

## Project layout

- `lib/features/` contains the app's chat, contact, profile, group, channel,
  bot, settings, and support features.
- `lib/core/` contains shared networking, local storage, cryptography, and UI
  components.
- `lib/generated/proto/` contains generated Dart code. The shared contract is
  maintained in the Axiom Server checkout under `proto/`.

For chat presentation, translation, attachments, and delivery services, see
the [chat module guide](lib/features/chats/README.md).

## Development

Run the client checks from this directory:

```bash
flutter analyze
flutter test
```

When changing the shared gRPC contract, update the server's `proto/` files
first, then regenerate Dart stubs:

```bash
TUREON_SERVER_ROOT=/path/to/axiom-server \
  PATH="$HOME/.pub-cache/bin:$PATH" ./tool/generate_proto.sh
```

Issues and contributions are welcome in this repository. See
[@leandro-ribeiro-dev](https://github.com/leandro-ribeiro-dev) for the
maintainer profile.
