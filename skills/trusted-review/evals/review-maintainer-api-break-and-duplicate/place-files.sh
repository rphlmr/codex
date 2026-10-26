#!/usr/bin/env bash
set -eu
case_dir="$(dirname "$0")"
cp -R "$case_dir/files/." .
git init -q
git add .
git -c user.name=eval -c user.email=eval@example.com commit -q -m "chore: release 2.3.0"
cp "$case_dir/change/receipt.ts" receipt.ts
