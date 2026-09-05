#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SKILLS_SOURCE="$REPO_DIR/skills"
AGENTS_SOURCE="$REPO_DIR/agents"

SKILLS_TARGET="$HOME/.codex/skills"
AGENTS_TARGET="$HOME/.codex/agents"

mkdir -p "$SKILLS_TARGET"
mkdir -p "$AGENTS_TARGET"

sync_directory_entries() {
  local source_dir="$1"
  local target_dir="$2"

  [[ -d "$source_dir" ]] || return

  for source in "$source_dir"/*; do
    [[ -e "$source" ]] || continue

    local name
    name="$(basename "$source")"

    local target="$target_dir/$name"

    rm -rf "$target"
    cp -R "$source" "$target"

    echo "Synced: $target"
  done
}

sync_directory_entries "$SKILLS_SOURCE" "$SKILLS_TARGET"

# Remove repository-managed agent names superseded by model-agnostic roles.
rm -f \
  "$AGENTS_TARGET/sol-implementer.toml" \
  "$AGENTS_TARGET/sol-verifier.toml" \
  "$AGENTS_TARGET/luna-implementer.toml"

for source in "$AGENTS_SOURCE"/*.toml; do
  [[ -e "$source" ]] || continue

  name="$(basename "$source")"
  target="$AGENTS_TARGET/$name"

  cp "$source" "$target"

  echo "Synced: $target"
done

echo
echo "Codex skills and agents synced."
