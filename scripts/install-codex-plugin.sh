#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CODEX_HOME="${CODEX_HOME:-$HOME/.codex}"
TARGET_DIR="$CODEX_HOME/plugins/twilio-codex-plugin"

mkdir -p "$(dirname "$TARGET_DIR")"
rm -rf "$TARGET_DIR"
cp -R "$ROOT_DIR/codex" "$TARGET_DIR"
cp -R "$ROOT_DIR/bin" "$TARGET_DIR"
cp "$ROOT_DIR/README.md" "$TARGET_DIR/README.twilio-plugin.md"

cat <<EOF
Installed Twilio Codex plugin files to:
  $TARGET_DIR

Next steps:
  1) Ensure Twilio creds are in your project .env
  2) Run: $TARGET_DIR/bin/preflight
  3) Use wrappers directly or wire commands in your Codex config
EOF
