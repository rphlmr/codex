#!/usr/bin/env bash
set -eu
case_dir="$(dirname "$0")"
cp -R "$case_dir/files/." .
git init -q
git add .
git -c user.name=eval -c user.email=eval@example.com commit -q -m "feat: add drafts"
cp "$case_dir/change/drafts.ts" drafts.ts
