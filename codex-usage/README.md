# Codex Usage

A small native macOS menu bar viewer for your Codex limits. A native Liquid
Glass panel hosts SwiftUI system typography, progress bars, and controls. The menu
shows usage **consumed**, the reset countdown, and the last successful refresh.
The menu bar icon shows the **remaining** percentage in the most constrained
available Codex window. Hover to see which window it represents. It follows
system appearance and accessibility preferences.

## Requirements

- macOS 26 or later, with Xcode 26 or later (Swift 6.2+) to build.
- The official Codex CLI, signed in with ChatGPT using `codex login`.
- A CLI version supporting `app-server` and `account/rateLimits/read`.

There are no third-party package dependencies. API-key-only accounts may not
have ChatGPT usage limits. This app does not estimate missing limits as zero.

## Run

From the repository root:

```bash
./script/build_and_run.sh
```

The repository's Codex **Run** action uses the same script. Left-click or right-click
the Codex icon in the macOS menu bar to toggle the viewer. Refresh manually using the refresh
row, or wait for the five-minute poll. The badge beside Refresh shows the last
successful refresh time. Quit is available at the bottom of the viewer.

The script creates `codex-usage/dist/CodexUsage.app`, signs it locally, and opens
the bundle. It stops only an existing instance launched from that bundle path.
Normal development launches do not register a login item. No global keyboard
shortcut or Accessibility permission is used.

## Install and launch at login

```bash
./script/build_and_run.sh --install
```

This builds a release bundle, installs it in `~/Applications/CodexUsage.app`,
registers the installed app with macOS Service Management to launch at login,
and opens it. Terminal can close afterward. No daemon or separate LaunchAgent
is installed. An existing Codex Usage installation is updated; a different app
at the same path is left untouched.

macOS may require approval in Login Items. The installer reports this with exit
code 2; it does not bypass approval. Future launches use the installed app
without needing this checkout. To check or disable launch at login:

```bash
~/Applications/CodexUsage.app/Contents/MacOS/CodexUsage --login-status
~/Applications/CodexUsage.app/Contents/MacOS/CodexUsage --disable-login-item
```

These are one-shot management commands; they exit without starting the UI or
reading usage. Disabling launch at login leaves the app installed.

## Appearance and preview

The menu bar uses a monochrome Codex mark, with the remaining percentage beside
it. macOS adapts the template image to light, dark, and selected menu bars.
An app-owned native status item keeps the viewer running when no window is
open. Its image loads directly from the bundle rather than an asset catalog.
The Run and install commands reveal the usage panel; login launches stay quiet.
The compact 280-point panel uses a single adaptive Liquid Glass background over a
transparent window. Escape, clicking outside, or switching apps dismisses it.
Native transparency and contrast accessibility preferences remain respected.
Regular glass and stronger secondary text preserve readability over bright and
dark desktops. Presentation IDs prevent delayed outside-click events from
dismissing a newly opened panel, and the status item itself is excluded from
outside-click dismissal.
`Resources/CodexMark.svg` preserves the mark from the installed official ChatGPT
app's `codex_new` asset; `CodexMark.png` is its 72-pixel rasterization for the
18-point status item. The run script includes the PNG in the app bundle.

For a standalone preview using sample data and no Codex requests:

```bash
./script/build_and_run.sh --demo
```

Add `--light` or `--dark` after `--demo` to inspect either appearance without
changing macOS settings.

`--build-only` packages without opening; `--verify` checks launch; `--debug`
opens LLDB; `--logs` and `--telemetry` stream app logs until interrupted.

## Authentication and privacy

The viewer starts a short-lived local `codex app-server` over stdin/stdout,
completes its initialization handshake, and calls `account/rateLimits/read`.
Codex owns authentication, credential storage, refresh, and upstream requests.
The viewer does not read, copy, log, or modify `auth.json` or Keychain tokens.
It does not start threads, run prompts, redeem credits, or initiate sign-in.
The child inherits the user's CLI environment (including `CODEX_HOME`, if set),
with analytics disabled for that process. No update checks or analytics are
implemented by the viewer.

The CLI is discovered in `PATH`, `~/.local/bin`, common Homebrew/npm locations,
or the installed Codex app. A custom install can be selected with an absolute
`CODEX_USAGE_CLI` path in the app's launch environment. No shell is used to
launch the CLI. For example:

```bash
CODEX_USAGE_CLI=/absolute/path/to/codex ./script/build_and_run.sh
```

The run script forwards `CODEX_USAGE_CLI` and `CODEX_HOME` to the launched bundle.
The CLI must also exist on any Mac
where the viewer is installed; it is not bundled into the app.

Each read has a 20-second deadline and a 1 MiB output limit. The child is stopped
and reaped after success, failure, cancellation, or timeout. Backend errors and
CLI stderr are not logged or persisted by the viewer. Failed refreshes retain
the last successful snapshot and show its timestamp. Reset countdowns reaching
zero never erase the reported usage or imply that a new fetch succeeded.

Metered buckets take precedence over the legacy single-bucket response. Extra
model-specific buckets appear only when supplied by Codex. Window labels use
the reported duration; a missing secondary window is omitted. This is a quota
viewer, not a token-activity or credit-balance viewer.

Protocol reference: [official Codex app-server documentation](https://developers.openai.com/codex/app-server).
The app-server interface can change; update the CLI if its response is no
longer understood.

## Validate

```bash
swift test --package-path codex-usage
./script/build_and_run.sh --build-only
```

Tests cover multi-bucket and legacy decoding, absent data, reset countdowns,
refresh overlap and recovery, the initialization handshake, fragmented output,
notifications, authentication failures, cancellation, and timeout cleanup. The
remaining-percentage tests cover the limiting window, missing data, exhausted
limits, and the separation between Codex and model-specific quotas. The
transport tests use a fake CLI with dummy data and `/usr/bin/python3`; they do
not access your account or the network.

## Package for distribution

```bash
CODE_SIGN_IDENTITY='Developer ID Application: Your Name (TEAMID)' \
  ./script/build_and_run.sh --release
```

This builds an optimized bundle for the current Mac's architecture. Without a
signing identity the script uses an ad-hoc signature for local development.
Public distribution additionally needs your Developer ID certificate and Apple
notarization. This repository does not publish, notarize, or upload anything
automatically. The existing repository release workflow still releases the
skills/configuration project; it does not build this app.
