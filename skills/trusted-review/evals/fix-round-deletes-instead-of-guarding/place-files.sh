#!/usr/bin/env bash
set -eu
cp -R "$(dirname "$0")/files/." .
git init -q
git add .
git -c user.name=eval -c user.email=eval@example.com commit -q -m "feat: add drafts"
