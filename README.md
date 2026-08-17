# Codex Skills

Personal Codex skills, custom agents, and global instructions tracked in Git.

This repository is the source of truth for:

- custom skills;
- custom agents;
- global `AGENTS.md`.

## Repository structure

```text
.
├── AGENTS.md
├── agents/
│   ├── sol_verifier.toml
│   ├── luna_commit_message.toml
│   └── ...
├── skills/
│   ├── commit-message/
│   │   ├── SKILL.md
│   │   └── agents/
│   │       └── openai.yaml
│   ├── pr-changelog/
│   │   ├── SKILL.md
│   │   └── agents/
│   │       └── openai.yaml
│   └── ...
├── sync-skills.sh
├── sync-agents-md.sh
└── README.md
```

## Source of truth

Always edit files in this repository.

Canonical paths:

```text
~/workspace/codex-skills/AGENTS.md
~/workspace/codex-skills/agents/*
~/workspace/codex-skills/skills/*
```

The copies under `~/.codex` are generated from this repository and should not be treated as canonical.

## What is synchronized

### Skills

Repository skills live under:

```text
./skills/
```

`sync-skills.sh` copies them into:

```text
~/.codex/skills/
```

Example:

```text
~/workspace/codex-skills/skills/commit-message
        ↓ copy
~/.codex/skills/commit-message
```

Only skills present in this repository are replaced.

Codex-managed content such as:

```text
~/.codex/skills/.system
```

is left untouched.

### Custom agents

Custom agent definitions live under:

```text
./agents/
```

`sync-skills.sh` also copies them into:

```text
~/.codex/agents/
```

Example:

```text
~/workspace/codex-skills/agents/sol_verifier.toml
        ↓ copy
~/.codex/agents/sol_verifier.toml
```

### Global `AGENTS.md`

The canonical global instructions live at:

```text
./AGENTS.md
```

`sync-agents-md.sh` copies them into:

```text
~/.codex/AGENTS.md
```

## Initial setup

Clone the repository:

```bash
mkdir -p ~/workspace

git clone <repository-url> ~/workspace/codex-skills
cd ~/workspace/codex-skills
```

Make the scripts executable:

```bash
chmod +x sync-skills.sh sync-agents-md.sh
```

Then synchronize everything:

```bash
./sync-skills.sh
./sync-agents-md.sh
```

## `sync-skills.sh`

`sync-skills.sh` synchronizes both:

```text
skills/* → ~/.codex/skills/*
agents/* → ~/.codex/agents/*
```

It copies files and directories rather than using symlinks.

This means Codex always works with normal local files under `~/.codex`.

### Script

```bash
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

if [[ -d "$AGENTS_SOURCE" ]]; then
  for source in "$AGENTS_SOURCE"/*.toml; do
    [[ -e "$source" ]] || continue

    name="$(basename "$source")"
    target="$AGENTS_TARGET/$name"

    cp "$source" "$target"

    echo "Synced: $target"
  done
fi

echo
echo "Codex skills and agents synced."
```

### Behavior

The script:

1. resolves the repository directory;
2. creates `~/.codex/skills` if necessary;
3. creates `~/.codex/agents` if necessary;
4. copies every repository skill into `~/.codex/skills`;
5. copies every repository custom agent into `~/.codex/agents`;
6. replaces only entries whose names exist in this repository;
7. leaves unrelated Codex files untouched.

For example, if the repository contains:

```text
skills/commit-message
skills/pr-changelog
```

the script may replace:

```text
~/.codex/skills/commit-message
~/.codex/skills/pr-changelog
```

but it does not remove:

```text
~/.codex/skills/.system
```

or other unrelated entries.

## `sync-agents-md.sh`

`sync-agents-md.sh` synchronizes:

```text
./AGENTS.md
        ↓
~/.codex/AGENTS.md
```

### Script

```bash
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
```

The script copies only when the contents differ.

## Typical workflow

### Update a skill

Edit the repository version:

```bash
$EDITOR skills/commit-message/SKILL.md
```

Then synchronize:

```bash
./sync-skills.sh
```

Review and commit:

```bash
git diff
git add skills/commit-message
git commit
```

### Update a custom agent

Edit:

```bash
$EDITOR agents/sol_verifier.toml
```

Synchronize:

```bash
./sync-skills.sh
```

Then commit:

```bash
git diff
git add agents/sol_verifier.toml
git commit
```

### Update global instructions

Edit:

```bash
$EDITOR AGENTS.md
```

Synchronize:

```bash
./sync-agents-md.sh
```

Then commit:

```bash
git diff
git add AGENTS.md
git commit
```

## Adding a new skill

Create a new directory under:

```text
skills/
```

For example:

```text
skills/future-architect-mode/
├── SKILL.md
└── agents/
    └── openai.yaml
```

Then run:

```bash
./sync-skills.sh
```

The skill is copied to:

```text
~/.codex/skills/future-architect-mode
```

Commit it:

```bash
git add skills/future-architect-mode
git commit
```

## Adding a new custom agent

Create:

```text
agents/new_agent.toml
```

Then run:

```bash
./sync-skills.sh
```

The agent is copied to:

```text
~/.codex/agents/new_agent.toml
```

Commit it:

```bash
git add agents/new_agent.toml
git commit
```

## Updating another machine

Pull the latest changes:

```bash
cd ~/workspace/codex-skills
git pull
```

Then synchronize:

```bash
./sync-skills.sh
./sync-agents-md.sh
```

## New machine

Clone the repository:

```bash
mkdir -p ~/workspace

git clone <repository-url> ~/workspace/codex-skills
cd ~/workspace/codex-skills
```

Synchronize skills and custom agents:

```bash
./sync-skills.sh
```

Synchronize global instructions:

```bash
./sync-agents-md.sh
```

The resulting layout is:

```text
                   Git repository
                         │
             ~/workspace/codex-skills
                         │
          ┌──────────────┼──────────────┐
          │              │              │
       skills/         agents/       AGENTS.md
          │              │              │
         copy           copy            copy
          │              │              │
          ▼              ▼              ▼
~/.codex/skills/* ~/.codex/agents/* ~/.codex/AGENTS.md
```

## Copy semantics

Synchronization is intentionally one-way:

```text
repository
    ↓
~/.codex
```

Changes made directly under:

```text
~/.codex/skills
~/.codex/agents
~/.codex/AGENTS.md
```

may be overwritten the next time the corresponding sync script runs.

If you modify something directly under `~/.codex` and want to keep it, copy the change back into the repository before synchronizing again.

## Repository scope

This repository manages:

```text
~/.codex/AGENTS.md
~/.codex/agents/*
~/.codex/skills/*
```
