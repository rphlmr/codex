#!/usr/bin/env bash

set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SKILLS_SOURCE="$REPO_DIR/skills"
CODEX_DIR="${CODEX_HOME:-$HOME/.codex}"
SKILLS_TARGET="$HOME/.agents/skills"
LEGACY_SKILLS_TARGET="$CODEX_DIR/skills"
AGENTS_TARGET="$CODEX_DIR/agents"

mkdir -p "$SKILLS_TARGET"

# Retire only entries previously managed by this repository.
for name in \
  commit-message \
  final-implementation-plan \
  future-architect-mode \
  implement-plan \
  pr-changelog \
  verify-implementation; do
  target="$LEGACY_SKILLS_TARGET/$name"

  if [[ -e "$target" || -L "$target" ]]; then
    rm -rf "$target"
    echo "Removed retired skill: $target"
  fi
done

for name in \
  commit-message \
  future-architect \
  implementer \
  light-implementer \
  pr-changelog \
  verifier \
  sol-implementer \
  sol-verifier \
  luna-implementer; do
  target="$AGENTS_TARGET/$name.toml"

  if [[ -e "$target" || -L "$target" ]]; then
    rm -f "$target"
    echo "Removed retired agent: $target"
  fi
done

for source in "$SKILLS_SOURCE"/*; do
  [[ -f "$source/SKILL.md" ]] || continue

  name="$(basename "$source")"
  target="$SKILLS_TARGET/$name"

  # Remove the older Codex-only copy so each skill has one installed definition.
  legacy_target="$LEGACY_SKILLS_TARGET/$name"

  if [[ -e "$legacy_target" || -L "$legacy_target" ]]; then
    rm -rf "$legacy_target"
    echo "Removed legacy skill: $legacy_target"
  fi

  rm -rf "$target"
  cp -R "$source" "$target"

  echo "Synced: $target"
done

echo
echo "Codex skills synced to ~/.agents/skills; retired workflows and agents removed."
