#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$REPO_DIR/AGENTS.md"
TARGET="$HOME/.codex/AGENTS.md"

if [[ ! -f "$SOURCE" ]]; then
  echo "Missing source file: $SOURCE" >&2
  exit 1
fi

mkdir -p "$(dirname "$TARGET")"

if [[ -f "$TARGET" ]] && cmp -s "$SOURCE" "$TARGET"; then
  echo "Already up to date: $TARGET"
  exit 0
fi

cp "$SOURCE" "$TARGET"

echo "Updated: $TARGET"