#!/usr/bin/env sh
set -eu

APP_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
SERVER_ROOT="${TUREON_SERVER_ROOT:-$(CDPATH= cd -- "$APP_ROOT/.." && pwd)}"
PROTO_FILE="$SERVER_ROOT/proto/tureon.proto"
if [ ! -f "$PROTO_FILE" ]; then
  echo "Shared protocol not found. Set TUREON_SERVER_ROOT to the server checkout." >&2
  exit 1
fi

OUT="$APP_ROOT/lib/generated"
mkdir -p "$OUT"

protoc \
  --proto_path="$SERVER_ROOT" \
  --proto_path=/usr/include \
  --dart_out=grpc:"$OUT" \
  "$PROTO_FILE" \
  /usr/include/google/protobuf/field_mask.proto
