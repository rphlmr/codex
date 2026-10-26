#!/usr/bin/env bash
set -eu
case_dir="$(dirname "$0")"
config_root="$case_dir/../../../.."
cp -R "$case_dir/files/." .
cp "$config_root/CLAUDE.md" CLAUDE.md
mkdir -p .claude/rules
cp "$config_root"/rules/*.md .claude/rules/
git init -q
git add .
git -c user.name=eval -c user.email=eval@example.com commit -q -m "feat: add orders page"
