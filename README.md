# Codex Skills

Personal Codex skills, custom agents, and global instructions tracked in Git.

This repository is the source of truth for:

- custom skills;
- custom agents;
- global `AGENTS.md`.

## Installation

Clone the repository:

```bash
mkdir -p ~/workspace

git clone git@github.com:rphlmr/codex.git ~/workspace/codex
cd ~/workspace/codex
```

Make the synchronization scripts executable:

```bash
chmod +x sync-skills.sh sync-agents-md.sh
```

Synchronize skills, custom agents, and global instructions:

```bash
./sync-skills.sh
./sync-agents-md.sh
```

The resulting layout is:

```text
                   Git repository
                         │
                  ~/workspace/codex
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

> [!IMPORTANT]
>
> ## Codex configuration
>
> The `sol_verifier` custom agent requires a permission profile named `workspace-safe`. Define `[permissions.workspace-safe]` in `~/.codex/config.toml` before using `$verify-implementation`; custom permission profile names must have a matching table. This repository does not manage that file.
>
> The example below provides the required profile plus optional companion defaults for models, agents, features, and top-level permissions.
>
> It configures:
>
> - GPT-5.6 Sol with medium reasoning as the primary model;
> - GPT-5.6 Luna with xhigh reasoning as the default subagent;
> - automatic approvals disabled;
> - workspace-scoped permissions;
> - protection for common secret and credential files;
> - network access restricted to explicitly allowed development domains;
> - a sandbox-writable temporary directory for Bun.
>
> ```toml
> #:schema https://developers.openai.com/codex/config-schema.json
>
> model = "gpt-5.6-sol"
> model_reasoning_effort = "medium"
> personality = "pragmatic"
> approval_policy = "never"
> default_permissions = "workspace-safe"
>
> [shell_environment_policy.set]
> TMPDIR = "/tmp"
>
> [agents]
> default_subagent_model = "gpt-5.6-luna"
> default_subagent_reasoning_effort = "xhigh"
>
> [features]
> network_proxy = true
> js_repl = false
> prevent_idle_sleep = true
>
> [permissions.workspace-safe]
> extends = ":workspace"
>
> [permissions.workspace-safe.filesystem.":workspace_roots"]
> "**/*.env" = "deny"
> "**/.env.*" = "deny"
>
> # Private keys / certificates
> "**/*.key" = "deny"
> "**/*.pem" = "deny"
> "**/*.p12" = "deny"
> "**/*.pfx" = "deny"
> "**/*.jks" = "deny"
> "**/*.keystore" = "deny"
>
> # SSH material accidentally stored in a repo
> "**/id_rsa" = "deny"
> "**/id_ed25519" = "deny"
> "**/id_ecdsa" = "deny"
> "**/id_dsa" = "deny"
>
> # Common secret directories
> "**/.ssh/**" = "deny"
> "**/certs/**" = "deny"
> "**/certificates/**" = "deny"
> "**/secrets/**" = "deny"
>
> [permissions.workspace-safe.network]
> enabled = true
>
> [permissions.workspace-safe.network.domains]
> "localhost" = "allow"
> "127.0.0.1" = "allow"
>
> # npm / Yarn / pnpm / Bun / Deno npm: imports
> "**.npmjs.org" = "allow"
>
> # Pull-request package previews
> "pkg.pr.new" = "allow"
> "**.pkg.pr.new" = "allow"
>
> # Deno / JSR packages
> "**.jsr.io" = "allow"
>
> # Node distributions / tooling that downloads Node
> "**.nodejs.org" = "allow"
>
> # Bun installer / Bun binaries
> "**.bun.sh" = "allow"
>
> # Playwright browser downloads
> "**.playwright.dev" = "allow"
>
> # Chromium / browser artifacts used by some tooling
> "**.googleapis.com" = "allow"
>
> "github.com" = "allow"
> "**.github.com" = "allow"
> "**.githubusercontent.com" = "allow"
>
> "gitlab.com" = "allow"
> "**.gitlab.com" = "allow"
> "**.gitlab.io" = "allow"
>
> "pypi.org" = "allow"
> "**.pypi.org" = "allow"
> "files.pythonhosted.org" = "allow"
> ```
>
> If `[shell_environment_policy.set]` already exists in `~/.codex/config.toml`, add `TMPDIR = "/tmp"` to that existing table. Do not create a second table with the same name.
>
> Permission profiles are resolved when a task starts. Restart the task after changing the profile. With `approval_policy = "never"`, a missing domain or filesystem permission fails immediately instead of presenting an approval prompt.

## Repository structure

```text
.
├── AGENTS.md
├── agents/
│   ├── commit-message.toml
│   ├── future-architect.toml
│   ├── luna-implementer.toml
│   ├── pr-changelog.toml
│   ├── sol-implementer.toml
│   └── sol-verifier.toml
├── skills/
│   ├── commit-message/
│   │   ├── SKILL.md
│   │   └── agents/
│   │       └── openai.yaml
│   ├── final-implementation-plan/
│   ├── future-architect-mode/
│   ├── implement-plan/
│   ├── pr-changelog/
│   └── verify-implementation/
├── sync-skills.sh
├── sync-agents-md.sh
└── README.md
```

## Included workflows

| Skill                        | Purpose                                                                                        | Custom agent                                                                    |
| ---------------------------- | ---------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| `commit-message`             | Generate one Conventional Commit message from the staged diff.                                 | `commit_message`                                                                |
| `final-implementation-plan`  | Finalize a completed Plan mode result into a self-contained implementation handoff.            | None                                                                            |
| `future-architect-mode`      | Independently review an idea, design, architecture, or implementation plan.                    | `future_architect`                                                              |
| `implement-plan`             | Execute a complete approved plan with one implementation agent.                                | `luna_implementer` by default; `sol_implementer` only when explicitly requested |
| `pr-changelog`               | Generate PR/MR text, review prep, release notes, or a changelog from committed branch changes. | `pr_changelog`                                                                  |
| `verify-implementation`      | Independently verify completed work against the approved plan and acceptance criteria.         | `sol_verifier`                                                                  |

The repository provides these custom agents:

| Definition                     | Agent name         | Model and reasoning  | Permissions                                 |
| ------------------------------ | ------------------ | -------------------- | ------------------------------------------- |
| `agents/commit-message.toml`   | `commit_message`   | GPT-5.6 Luna, low    | Read-only                                   |
| `agents/future-architect.toml` | `future_architect` | GPT-5.6 Sol, medium  | Read-only                                   |
| `agents/luna-implementer.toml` | `luna_implementer` | GPT-5.6 Luna, xhigh  | Inherits the invoking workspace permissions |
| `agents/pr-changelog.toml`     | `pr_changelog`     | GPT-5.6 Luna, medium | Read-only                                   |
| `agents/sol-implementer.toml`  | `sol_implementer`  | GPT-5.6 Sol, low     | Inherits the invoking workspace permissions |
| `agents/sol-verifier.toml`     | `sol_verifier`     | GPT-5.6 Sol, medium  | `workspace-safe`                            |

## Source of truth

Always edit files in this repository.

Canonical paths:

```text
~/workspace/codex/AGENTS.md
~/workspace/codex/agents/*
~/workspace/codex/skills/*
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
~/workspace/codex/skills/commit-message
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
~/workspace/codex/agents/sol-verifier.toml
        ↓ copy
~/.codex/agents/sol-verifier.toml
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

## `sync-skills.sh`

`sync-skills.sh` synchronizes both:

```text
skills/* → ~/.codex/skills/*
agents/* → ~/.codex/agents/*
```

It copies files and directories rather than using symlinks.

This means Codex always works with normal local files under `~/.codex`.

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
$EDITOR agents/sol-verifier.toml
```

Synchronize:

```bash
./sync-skills.sh
```

Then commit:

```bash
git diff
git add agents/sol-verifier.toml
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
agents/new-agent.toml
```

Then run:

```bash
./sync-skills.sh
```

The agent is copied to:

```text
~/.codex/agents/new-agent.toml
```

Commit it:

```bash
git add agents/new-agent.toml
git commit
```

## Updating another machine

Record the current revision and pull the latest changes:

```bash
cd ~/workspace/codex
previous_revision="$(git rev-parse HEAD)"
git pull --ff-only
```

Review the release notes and the commits received by the pull:

```bash
cat CHANGELOG.md
git log --oneline "$previous_revision..HEAD"
git diff --stat "$previous_revision..HEAD"
```

Then synchronize:

```bash
./sync-skills.sh
./sync-agents-md.sh
```

Run the review commands before performing another Git operation that changes
`HEAD`. If the pull reports that the repository is already up to date, the log
and diff are empty.

## Versioning and releases

Releases are automated by
[Release Please](https://github.com/googleapis/release-please-action). It uses
Conventional Commits merged into `main` to maintain `CHANGELOG.md`, update
`version.txt`, propose the next Semantic Version, create the Git tag, and publish
the GitHub Release.

Use these commit types for user-visible changes:

- `fix:` proposes a patch release;
- `feat:` proposes a minor release;
- `feat!:` or a `BREAKING CHANGE:` footer proposes a breaking release.

Before `v1.0.0`, breaking changes increment the minor version. Other commit types,
such as `docs:`, `test:`, and `chore:`, do not trigger a release by themselves.

Do not edit release entries in `CHANGELOG.md` or versions in `version.txt`
manually. Release Please owns both files.

### Automated release flow

1. Merge one or more Conventional Commits into `main`.
2. The `Release Please` GitHub Actions workflow opens or updates a release PR.
3. Review the proposed version and generated changelog in that PR.
4. Merge the release PR when the changes should be published.
5. The workflow creates the `vX.Y.Z` tag and corresponding GitHub Release.

The repository is bootstrapped at `0.0.0`, so the first merged `feat:` change
proposes `v0.1.0`.

### One-time GitHub configuration

In the repository, open **Settings → Actions → General**. Under **Workflow
permissions**, enable **Read and write permissions** and allow GitHub Actions to
create pull requests. The workflow uses the repository-provided `GITHUB_TOKEN`;
no custom secret is required.

If branch or tag protection rules are enabled, they must also allow the GitHub
Actions bot to create the release PR and version tag.

## New machine

The installation procedure is the same as the initial setup.

Clone the repository:

```bash
mkdir -p ~/workspace

git clone git@github.com:rphlmr/codex.git ~/workspace/codex
cd ~/workspace/codex
```

Make the scripts executable:

```bash
chmod +x sync-skills.sh sync-agents-md.sh
```

Then synchronize:

```bash
./sync-skills.sh
./sync-agents-md.sh
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

It intentionally does not manage:

```text
~/.codex/config.toml
```

The Codex configuration shown above is an optional companion configuration and can be maintained independently per machine.
