#!/usr/bin/env bash
set -euo pipefail

MODE="${1:-run}"
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_ROOT="$ROOT_DIR/codex-usage"
APP_NAME="CodexUsage"
BUNDLE_ID="dev.rphlmr.codex-usage"
APP_BUNDLE="$APP_ROOT/dist/$APP_NAME.app"
CONFIGURATION="debug"

case "$MODE" in
  run|--demo|--verify|--build-only|--debug|--logs|--telemetry) ;;
  --release|--install) CONFIGURATION="release" ;;
  *)
    echo "Usage: $0 [--demo|--verify|--build-only|--release|--install|--debug|--logs|--telemetry]" >&2
    exit 2
    ;;
esac

# Only stop an earlier instance of this project's bundle before replacing it.
pkill -f "^$APP_BUNDLE/Contents/MacOS/$APP_NAME([[:space:]]|$)" >/dev/null 2>&1 || true

export CLANG_MODULE_CACHE_PATH="$APP_ROOT/.build/ModuleCache"
swift build --package-path "$APP_ROOT" --configuration "$CONFIGURATION"
BUILD_DIR="$(swift build --package-path "$APP_ROOT" --configuration "$CONFIGURATION" --show-bin-path)"

mkdir -p "$APP_BUNDLE/Contents/MacOS" "$APP_BUNDLE/Contents/Resources"
cp "$BUILD_DIR/$APP_NAME" "$APP_BUNDLE/Contents/MacOS/$APP_NAME"
cp "$APP_ROOT/Resources/CodexMark.png" "$APP_BUNDLE/Contents/Resources/"

cat > "$APP_BUNDLE/Contents/Info.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key><string>$APP_NAME</string>
  <key>CFBundleIdentifier</key><string>$BUNDLE_ID</string>
  <key>CFBundleName</key><string>Codex Usage</string>
  <key>CFBundleDisplayName</key><string>Codex Usage</string>
  <key>CFBundlePackageType</key><string>APPL</string>
  <key>CFBundleShortVersionString</key><string>1.0.0</string>
  <key>CFBundleVersion</key><string>1</string>
  <key>LSMinimumSystemVersion</key><string>26.0</string>
  <key>LSUIElement</key><true/>
  <key>NSPrincipalClass</key><string>NSApplication</string>
</dict>
</plist>
PLIST

codesign --force --options runtime --sign "${CODE_SIGN_IDENTITY:--}" "$APP_BUNDLE"

if [[ "$MODE" == "--build-only" || "$MODE" == "--release" ]]; then
  echo "Built $APP_BUNDLE"
  exit 0
fi

open_app() {
  local launch_environment=(-n)

  if [[ -n "${CODEX_USAGE_CLI:-}" ]]; then
    launch_environment+=(--env "CODEX_USAGE_CLI=$CODEX_USAGE_CLI")
  fi

  if [[ -n "${CODEX_HOME:-}" ]]; then
    launch_environment+=(--env "CODEX_HOME=$CODEX_HOME")
  fi

  /usr/bin/open "${launch_environment[@]}" "$APP_BUNDLE" "$@"
}

case "$MODE" in
  --install)
    INSTALLED_APP="$HOME/Applications/$APP_NAME.app"

    if [[ -L "$INSTALLED_APP" ]]; then
      echo "Refusing to replace a symlink at $INSTALLED_APP" >&2
      exit 1
    fi

    if [[ -e "$INSTALLED_APP" ]]; then
      EXISTING_ID="$(/usr/libexec/PlistBuddy -c 'Print :CFBundleIdentifier' "$INSTALLED_APP/Contents/Info.plist" 2>/dev/null || true)"

      if [[ "$EXISTING_ID" != "$BUNDLE_ID" ]]; then
        echo "A different app already exists at $INSTALLED_APP; leaving it unchanged." >&2
        exit 1
      fi
    fi

    mkdir -p "$HOME/Applications"
    pkill -f "^$INSTALLED_APP/Contents/MacOS/$APP_NAME([[:space:]]|$)" >/dev/null 2>&1 || true
    /usr/bin/ditto "$APP_BUNDLE" "$INSTALLED_APP"
    codesign --verify --strict "$INSTALLED_APP"

    LOGIN_RESULT=0
    "$INSTALLED_APP/Contents/MacOS/$APP_NAME" --enable-login-item || LOGIN_RESULT=$?
    APP_BUNDLE="$INSTALLED_APP"
    open_app --args --show-usage
    echo "Installed and opened $INSTALLED_APP"

    if [[ "$LOGIN_RESULT" == 2 ]]; then
      echo "macOS needs you to approve Codex Usage in Login Items before it can start automatically."
    fi

    exit "$LOGIN_RESULT"
    ;;
  --demo) open_app --args --demo "${@:2}" ;;
  --debug) lldb -- "$APP_BUNDLE/Contents/MacOS/$APP_NAME" ;;
  --logs|--telemetry)
    open_app
    /usr/bin/log stream --info --style compact --predicate "process == \"$APP_NAME\""
    ;;
  --verify)
    open_app
    sleep 5
    pgrep -f "^$APP_BUNDLE/Contents/MacOS/$APP_NAME([[:space:]]|$)" >/dev/null
    ;;
  run) open_app --args --show-usage ;;
esac
