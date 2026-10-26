# Codex Skills

Personal Codex skills, global instructions, and recommended configuration tracked in Git.

This repository is the source of truth for:

- custom skills and their evaluation fixtures;
- global `AGENTS.md`, scoped coding rules, and reply style;
- recommended Codex configuration.

## Codex Usage for macOS

The self-contained [`codex-usage/`](codex-usage/README.md) Swift package is a
native Liquid Glass menu bar viewer for Codex usage limits. It uses the official
Codex CLI to manage authentication and read account limits. Requires macOS 26+
and Xcode 26+ to build; no third-party package dependencies are needed.

Run `./script/build_and_run.sh` from this repository, or use the Codex **Run**
action. Use `--demo` for a preview with sample data, `--build-only` to package
locally, and `swift test --package-path codex-usage` to run its tests. See the
app README for sign-in, packaging, and distribution requirements.
Run `./script/build_and_run.sh --install` to install it in `~/Applications` and
enable native launch at login, subject to macOS approval.

## Installation

Clone the repository:

```bash
mkdir -p ~/workspace

git clone git@github.com:rphlmr/codex.git ~/workspace/codex
cd ~/workspace/codex
```

Make the management scripts executable:

```bash
chmod +x sync-skills.sh sync-agents-md.sh update-config.sh
```

Preview the recommended Codex configuration, then consent to applying it:

```bash
./update-config.sh
```

The updater uses a pinned TOML patcher through `npx`, preserves existing values and formatting, displays an exact diff, and changes `~/.codex/config.toml` only after an interactive confirmation. If the file already exists, it also creates a timestamped backup. Run `./update-config.sh --dry-run` to preview without being prompted. After applying changes, restart Codex to ensure the new settings are loaded.

Synchronize skills and global instructions, and remove retired custom workflows and agents:

```bash
./sync-skills.sh
./sync-agents-md.sh
```

Synchronization copies skills to `~/.agents/skills/`, and instructions, rules,
and reply style to `~/.codex/`. Both scripts honor `CODEX_HOME` for the Codex
configuration directory; user skills remain in `~/.agents/skills/`. The skill
sync removes older Codex-only copies and retired custom workflows and agents.
Unrelated entries and bundled skills remain.

In this repository, `AGENTS.override.md` supplies repository-specific guidance
instead of loading the repository copy of the synced global `AGENTS.md` again.

> [!IMPORTANT]
>
> ## Codex configuration
>
> The example below provides optional defaults for the primary model, features,
> and workspace permissions. Subagents use Codex's native defaults.
>
> It configures:
>
> - GPT-6 Astra with medium reasoning as the primary model;
> - approval prompts disabled;
> - workspace-scoped permissions;
> - protection for common secret and credential files;
> - network access restricted to explicitly allowed development domains;
>
> ```toml
> #:schema https://developers.openai.com/codex/config-schema.json
>
> model = "gpt-6-astra"
> model_reasoning_effort = "medium"
> personality = "pragmatic"
> approval_policy = "never"
> default_permissions = "workspace-safe"
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
> "**/.env.p*" = "deny"
> "**/.env.s*" = "deny"
> "**/.env.d*" = "deny"
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
> allow_local_binding = true
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
> Restart Codex after changing the configuration to ensure all new settings, including permission profiles, are loaded. With `approval_policy = "never"`, a missing domain or filesystem permission fails immediately instead of presenting an approval prompt.
>
> The complete example is also stored in [`recommended-config.toml`](recommended-config.toml), which is the updater's source configuration.

## Native workflows

Use Codex's native planning, implementation, review, and subagent orchestration.
This repository no longer defines custom agents or a fixed execution pipeline.
Delegate when requested, using the built-in `default`, `worker`, or `explorer`
roles. Custom agents can be reconsidered if a concrete need emerges.

OpenAI documents these built-in roles and optional customizations in its
[subagent guide](https://learn.chatgpt.com/docs/agent-configuration/subagents).
Its [customization guide](https://learn.chatgpt.com/docs/customization/overview)
positions skills as reusable task guidance and subagents as optional delegation.
Using the native workflow is this repository's preference, not a claim that
custom agents are always worse.

## Included skills

These workflows carry over the Claude configuration's behavior, with Codex tool
names and invocation policies. Commit messages and PR changelogs each spawn
one fresh built-in agent with an explicit model and reasoning effort,
independent of the parent chat:

| Workflow | Model | Reasoning effort |
| --- | --- | --- |
| `commit-message` | `gpt-6-luna` | `low` |
| `pr-changelog` | `gpt-6-luna` | `medium` |

Both return the agent’s output unchanged. If the configured model or effort
is unavailable, they report that instead of substituting the parent settings.
No custom agent definitions are needed.

| Skill | Purpose | Invocation |
| --- | --- | --- |
| `apple-hig` | Read current Apple design guidance with the lookup script | Automatic or explicit |
| `brainstorm` | Reach an agreed design before implementation | Explicit `$brainstorm` |
| `commit-message` | Produce one staged-only Conventional Commit message | Automatic or explicit |
| `devrel-voice` | Write articles and tutorials in the user's voice | Automatic or explicit |
| `pr-changelog` | Describe the complete committed branch changeset | Automatic or explicit |
| `session-handoff` | Prepare context for a fresh Codex chat | Explicit `$session-handoff` |
| `security-audit` | Run Cloudflare’s source-first security audit workflow | Automatic or explicit |
| `state-machines` | Model workflows as explicit transitions | Automatic or explicit |
| `trusted-review` | Run bundled `review-agent` with extra checks in a fresh agent | Automatic or explicit |

`trusted-review` uses the installed bundled `review-agent` procedure plus
`references/review.md` for the additional maintainer, evidence, impact, and fix
checks. It uses `fork_turns: "none"` and a neutral scope/requirements brief. The reviewer receives no parent conversation, implementation report,
suspected findings, or proposed fixes. It reads the code and establishes proof
itself. Fixing existing findings stays in the parent unless separately
delegated; fixes do not automatically start another review.

The repository-local `release-commit-message` skill stays in `.agents/skills/`.
Existing evaluation prompts, fixtures, and graders are carried over with the
skills. Run behavioral evaluations only when requested; packaging checks
alone do not establish equivalent model behavior.

### Behavioral evaluations

The bounded suite in `evals/behavioral/cases.json` covers all nine global
repository skills and the local release-commit-message skill. It reuses the
existing disposable Git and source fixtures. It explicitly invokes skills;
it does not measure automatic skill selection or compare against a no-skill
baseline. Each case is one sample, not a reliability estimate.

Run the grader regression tests without model calls:

```bash
python3 -m unittest discover -s scripts -p 'test_skill_evals.py' -v
```

List cases, run the suite, or rerun one case:

```bash
python3 scripts/run_skill_evals.py --list
python3 scripts/run_skill_evals.py
python3 scripts/run_skill_evals.py --case review-real-bug
```

The runner uses the installed `codex` CLI and existing sign-in. It launches
finite non-interactive sessions, with two concurrent cases and a 180-second
timeout per case by default. Model runs consume account usage. It leaves the
user configuration, authentication, and installed skills unchanged. Fixture
repositories are temporary and deleted after each run. Agents use read-only
sandboxing except for the rewrite output and Apple HIG cache cases, which
use workspace-write. The Apple HIG case also enables sandbox network access
to retrieve public Apple documentation; its success checks require both page
reads to exit successfully. No eval installs dependencies or runs a full security
audit. No shared background Codex daemon is started.

Ignored `eval-results/<timestamp>/` directories contain case definitions,
source hashes, CLI version, answers, events, selected parent/child trace
evidence, per-check results, and Markdown/JSON summaries. Normal Codex session
logs remain in the user's Codex home so actual child contexts can be checked.
The runner reads only sessions identified by its own run and child IDs; it
does not copy session metadata, credentials, or global instructions into the
selected `trace.json`. Treat full CLI event files as local diagnostic data.

Delegation checks compare spawn arguments with the child's recorded model and
effort. Fresh-context checks require `fork_turns: "none"` and verify that a
random parent-only marker is absent from child user inputs. Trusted Review
checks the child's executed calls for both the bundled reviewer and the extra
checks. File hashes, staged entries, and HEAD detect unintended changes.
The commit-message grader also rejects forbidden Git inspection, even when
the final message looks correct. Missing traces or runtime failures are
reported as errors, not passes.

Output assertions are deliberately small, deterministic checks. A pass does
not establish all semantic qualities in the original prose rubrics, guarantee
that every output fact is true, or establish resistance to all context leaks.
Inspect the saved answers and traces when diagnosing a failed case. Preserve
the assertions when comparing a later skill change against this baseline.

### Cloudflare security audit

`skills/security-audit/` is based on
[cloudflare/security-audit-skill](https://github.com/cloudflare/security-audit-skill),
revision `c1c8a8c1471069fb0e188eeaff69b8e8db6564a8`
(`skills/security-audit/`). Its MIT license is included. The sync script manages
its single installed copy under `~/.agents/skills/security-audit/`.

Local reporting changes replace the long audit overview with an action-oriented
report: 🛠️ Act first, 🔎 Resolve before deciding, 🕒 Can wait, and 🧪 Checks
and limits. Short explanations cover the trigger, user impact, and recommended
change; full evidence stays behind links. Audit bookkeeping stays in an
appendix. Evidence standards and execution safeguards are unchanged.

A security question uses guidance mode. An explicit full codebase audit or
requested audit report uses Cloudflare's multi-phase workflow, including its
own isolated agents and verification. Trusted Review does not wrap that
workflow in a second generic review or reduce it to one reviewer. Installing
this skill does not run an audit.

### Coding rules and reply style

`AGENTS.md` explicitly routes matching work to the six files in
`~/.codex/rules/`: architecture, code style, file naming, React, React Router,
and TypeScript. Their `paths` frontmatter records the intended scope; these
files are read through the instruction router rather than assumed to be
loaded automatically by Codex.

The reply style is in `~/.codex/output-styles/scannable.md`, also explicitly
referenced by `AGENTS.md`. It favors short Markdown blocks, selective bold,
and meaningful status icons, with explicit evidence, uncertainty, and next-step
status. Findings use a linked table with severity, user impact, fix, location,
and proof. Architecture, flows, and state transitions use the visualize widget
when available, with soft blue and purple fills, subtle matching borders, and
readable text. Other soft colors are allowed except yellow. A plain-text flow
is the fallback instead of Mermaid.
Exact skill output contracts take precedence.

Review output defaults to the same sections, with a short recommendation and
one emoji per section. It uses findings tables with short explanations rather
than checkbox-only summaries or a fixed word cap. Trusted Review preserves the
bundled findings-first report unchanged in a supporting file and derives the
summary from it. Both workflows distinguish priority from launch blockers.
Findings use plain labels such as Issue 1 and Issue 2, consistent between the
summary and linked details. Priority labels remain separate.

The Claude Remote Control launcher, SwiftBar plugin, lifecycle hooks, and
Claude model settings are product-specific and are not installed here. The
Codex Usage app above remains separate.

### Retiring the previous setup

`sync-skills.sh` removes the retired `final-implementation-plan`,
`future-architect-mode`, `implement-plan`, and `verify-implementation` skills
from `~/.codex/skills/`. It removes the old agent-dependent `commit-message`
and `pr-changelog` wrappers there and installs their standalone replacements
under `~/.agents/skills/`.

It also removes the six retired custom agent files and the earlier
`sol-implementer`, `sol-verifier`, and `luna-implementer` filenames from
`~/.codex/agents/`. For each current skill, it removes the older same-name
Codex-only copy so there is one installed definition. Unrelated files remain.

The recommended configuration no longer sets `agents.default_subagent_model`
or `agents.default_subagent_reasoning_effort`. The config updater only adds
missing values, so it will not remove these overrides from an existing config.
To use native defaults, remove those two keys from `~/.codex/config.toml`, keeping
any other `[agents]` settings, then start a new Codex chat to load the cleanup.

## Repository structure

```text
.
├── AGENTS.md
├── AGENTS.override.md
├── rules/
├── output-styles/scannable.md
├── skills/
│   ├── apple-hig/
│   ├── brainstorm/
│   ├── commit-message/
│   ├── devrel-voice/
│   ├── pr-changelog/
│   ├── session-handoff/
│   ├── security-audit/
│   ├── state-machines/
│   └── trusted-review/
├── .agents/skills/release-commit-message/
├── scripts/update-config.mjs
├── recommended-config.toml
├── update-config.sh
├── sync-skills.sh
├── sync-agents-md.sh
├── codex-usage/
└── script/build_and_run.sh
```

## Source of truth

Always edit files in this repository.

Canonical paths:

```text
~/workspace/codex/AGENTS.md
~/workspace/codex/rules/*
~/workspace/codex/output-styles/*
~/workspace/codex/skills/*
```

The managed copies under `~/.codex` and `~/.agents/skills` are generated from this repository and should not be treated as canonical.

## What is synchronized

### Skills

Repository skills live under:

```text
./skills/
```

`sync-skills.sh` copies them into:

```text
~/.agents/skills/
```

Example:

```text
~/workspace/codex/skills/session-handoff
        ↓ copy
~/.agents/skills/session-handoff
```

Only skills present in this repository are replaced; the retired entries listed
above are removed.

Codex-managed content such as:

```text
~/.codex/skills/.system
```

is left untouched.

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

The script removes the explicitly listed retired skills and agent files, then
copies directories containing `SKILL.md` from `skills/` to `~/.agents/skills/`.
It replaces only matching skill names, removes their older `~/.codex/skills/`
copies, and leaves unrelated shared skills and Codex system skills untouched.
It uses copies rather than symlinks.

## `sync-agents-md.sh`

`sync-agents-md.sh` synchronizes:

```text
./AGENTS.md
        ↓
~/.codex/AGENTS.md
```

The script copies only when contents differ. It also copies `rules/*.md` and
`output-styles/*.md` into matching directories under the Codex home, leaving
unrelated files untouched.

## Typical workflow

### Update a skill

Edit the repository version:

```bash
$EDITOR skills/session-handoff/SKILL.md
```

Then synchronize:

```bash
./sync-skills.sh
```

Review and commit:

```bash
git diff
git add skills/session-handoff
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
skills/my-skill/
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
~/.agents/skills/my-skill
```

Commit it:

```bash
git add skills/my-skill
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
chmod +x sync-skills.sh sync-agents-md.sh update-config.sh
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
~/.codex (instructions, rules, reply style)
~/.agents/skills (skills)
```

Changes made directly under:

```text
~/.agents/skills/*
~/.codex/AGENTS.md
~/.codex/rules/*
~/.codex/output-styles/*
```

may be overwritten the next time the corresponding sync script runs.

If you modify managed files under `~/.codex` or `~/.agents/skills` and want to keep them, copy the change back into the repository before synchronizing again.

## Repository scope

This repository manages:

```text
~/.codex/AGENTS.md
~/.codex/rules/*
~/.codex/output-styles/*
~/.agents/skills/*
```

The interactive updater can merge missing recommendations into:

```text
~/.codex/config.toml
```

Existing configuration values remain authoritative, so the optional companion configuration can still be maintained independently per machine. Unlike the one-way synchronization scripts, `update-config.sh` previews its changes and requires consent before writing.
