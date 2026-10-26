#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SOURCE="$REPO_DIR/AGENTS.md"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
TARGET="$CODEX_DIR/AGENTS.md"

if [[ ! -f "$SOURCE" ]]; then
  echo "Missing source file: $SOURCE" >&2
  exit 1
fi

copy_if_changed() {
  local source="$1"
  local target="$2"

  if [[ -f "$target" ]] && cmp -s "$source" "$target"; then
    echo "Already up to date: $target"
    return
  fi

  cp "$source" "$target"

  echo "Updated: $target"
}

mkdir -p "$CODEX_DIR"

copy_if_changed "$SOURCE" "$TARGET"

for directory in rules output-styles; do
  source_dir="$REPO_DIR/$directory"
  target_dir="$CODEX_DIR/$directory"

  if [[ ! -d "$source_dir" ]]; then
    continue
  fi

  mkdir -p "$target_dir"

  for source in "$source_dir"/*.md; do
    [[ -f "$source" ]] || continue

    copy_if_changed "$source" "$target_dir/$(basename "$source")"
  done
done
