# Codex Skills

Personal Codex skills, global instructions, and recommended configuration tracked in Git.

This repository is the source of truth for:

- custom skills and their evaluation fixtures;
- global `AGENTS.md`, the coding-preferences skill, and reply style;
- recommended Codex configuration;
- bilingual Raycast snippets for AI collaboration.

## Raycast snippets

Import [`raycast/ai-collaboration-snippets.json`](raycast/ai-collaboration-snippets.json)
with Raycast's **Import Snippets** command. It contains five prompts in French
and English. French variants request discussion in French; English variants
request discussion in English. Both keep code, code comments, and deliverables
in English.

| Purpose | French keyword | English keyword |
| --- | --- | --- |
| Start a task | `;aistart-fr` | `;aistart-en` |
| Check the result | `;aicheck-fr` | `;aicheck-en` |
| Reset when lost | `;aireset-fr` | `;aireset-en` |
| Explain a proposal | `;aiexplain-fr` | `;aiexplain-en` |
| Run a pilot before scaling | `;aipilot-fr` | `;aipilot-en` |

Use **Search Snippets** and search for `AI [FR]` or `AI [EN]` if you forget a
keyword. Optional tags are `AI` and `FR` or `EN`; add them in Raycast after
importing, since the [documented JSON import format](https://manual.raycast.com/snippets)
does not specify a tags field.

Importing is manual; the repository sync scripts do not install these snippets.
The earlier unsuffixed keywords, such as `;aistart`, are separate entries and
can be removed manually after importing the bilingual versions.

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

The recommended runtime configuration is optional; skip it to retain Codex's
runtime defaults. To preview and consent to these settings:

```bash
./update-config.sh
```

The updater uses a pinned TOML patcher through `npx`, preserves existing values and formatting, displays an exact diff, and changes `~/.codex/config.toml` only after an interactive confirmation. If the file already exists, it also creates a timestamped backup. Run `./update-config.sh --dry-run` to preview without being prompted. After applying changes, restart Codex to ensure the new settings are loaded.

Synchronize skills and global instructions, and remove retired custom workflows and agents:

```bash
./sync-skills.sh
./sync-agents-md.sh
```

Synchronization copies skills, including coding preferences, to `~/.agents/skills/`,
and global instructions and reply style to `~/.codex/`. Both scripts honor `CODEX_HOME` for the Codex
configuration directory; user skills remain in `~/.agents/skills/`. The skill
sync removes older Codex-only copies and retired custom workflows and agents.
Unrelated entries and bundled skills remain.

In this repository, `AGENTS.override.md` supplies repository-specific guidance
instead of loading the repository copy of the synced global `AGENTS.md` again.

> [!IMPORTANT]
>
> ## Codex configuration
>
> The optional configuration enables **Approve for me** with Codex's built-in
> workspace permission profile. It also keeps the pragmatic personality setting,
> a limit of six concurrent subagents, and prevents idle sleep while Codex runs.
> Models, reasoning effort, and other features use Codex's native defaults unless
> configured elsewhere.
>
> ```toml
> #:schema https://developers.openai.com/codex/config-schema.json
>
> personality = "pragmatic"
> approval_policy = "on-request"
> approvals_reviewer = "auto_review"
> default_permissions = ":workspace"
>
> [agents]
> max_concurrent_threads_per_session = 6
>
> [features]
> prevent_idle_sleep = true
> ```
>
> Eligible approval requests go through automatic review. The built-in sandbox
> remains active. See OpenAI's [configuration reference](https://learn.chatgpt.com/docs/config-file/config-reference).
>
> The complete example is stored in [`recommended-config.toml`](recommended-config.toml).
> Restart Codex after changing the configuration.
>
> **Existing installations:** the updater only adds missing values and preserves
> existing overrides. It does not migrate the old configuration automatically.
> To adopt this setup, set the values above and remove the old recommendation's
> `model`, `model_reasoning_effort`,
> `features.network_proxy`, and `features.js_repl` overrides, plus the
> `[permissions.workspace-safe]` profile and its nested tables if no other config
> references it. Preserve unrelated settings and any overrides you still want.

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

All personal skills are explicit-only: invoke them with `$skill-name` when
you want their guidance. They do not activate automatically based on the task.
The global `AGENTS.md` always applies the ADHD-aware scannable reply style
and language preferences: English code and comments, with familiar English
developer terminology retained in French discussions.
Personal coding preferences, writing skills, and workflows remain opt-in.
Bundled skills and plugin configuration are left unchanged.
Commit messages and PR descriptions run in the current chat. An independent
review delegates only when the user asks for independence or delegation.

| Skill | Purpose | Invocation |
| --- | --- | --- |
| `apple-hig` | Look up current Apple design guidance when the decision needs it | Explicit `$apple-hig` |
| `brainstorm` | Reach an agreed design before implementation | Explicit `$brainstorm` |
| `commit-message` | Produce one staged-only Conventional Commit message | Explicit `$commit-message` |
| `coding-preferences` | Apply personal code style and scoped language/framework preferences | Explicit `$coding-preferences` |
| `devrel-voice` | Write developer content using the approved voice reference | Explicit `$devrel-voice` |
| `openai-reference` | Answer factual OpenAI questions from relevant official sources | Explicit `$openai-reference` |
| `pr-changelog` | Describe the complete committed branch changeset | Explicit `$pr-changelog` |
| `session-handoff` | Prepare context for a fresh chat | Explicit `$session-handoff` |
| `security-audit` | Use the source-first security guidance or full audit workflow | Explicit `$security-audit` |
| `state-machines` | Design or assess transitions for a requested workflow | Explicit `$state-machines` |
| `trusted-review` | Review code or fix existing findings with scoped validation | Explicit `$trusted-review` |

The state-machine skill accepts authoritative switches or reducers and existing
repository patterns. It does not pre-approve a library dependency. Trusted
Review keeps its evidence standards without requiring an agent, saved report,
or fixed report template for every review. Its independent mode uses a fresh
reviewer and the bundled review procedure when available.

The local `release-commit-message` skill stays in `.agents/skills/` and is also
explicit-only. Invoking one personal skill does not automatically opt into
another personal skill.

### Behavioral evaluations

The bounded suite in `evals/behavioral/cases.json` exercises the original nine
custom skills and the local release-commit-message skill. It explicitly invokes
skills and does not measure automatic selection, the new openai-reference or
coding-preferences triggers, or a no-skill baseline. Each case is one sample, not a reliability
estimate. Run model-based evaluations only when explicitly requested.

Commit and PR cases check direct execution without delegation. Ordinary review
cases do the same; cases explicitly requesting independence require a fresh
reviewer. Transition, cancellation, settled-decision, and handoff scenarios
retain their behavior assertions. Text assertions are smoke checks and still
require reading the answers to assess semantics.

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

Select a model and reasoning effort explicitly when comparing profiles:

```bash
python3 scripts/run_skill_evals.py --case review-repeated-reassurance --model gpt-6-astra --effort high
```

The manifest records the requested profile. Checks compare it with the actual
parent and inherited reviewer contexts; an unrecorded or different value fails
the profile check. Only explicitly independent cases require a delegated reviewer.

Recalculate report-delivery checks from a saved run without calling models:

```bash
python3 scripts/run_skill_evals.py --regrade /absolute/path/to/saved-run --output /absolute/path/to/new-results
```

This uses the saved answers and original session traces. Other recorded checks,
including fixture side effects and runtime errors, are retained, not rerun.
The original run remains unchanged. The new report records its source and
grading provenance. Without `--output`, results go in a new timestamped
subdirectory of the original run. The original session logs must still exist.

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

For independent-review cases, delegation checks compare spawn arguments with
recorded child context and verify the fresh-context boundary. Reviewer traces
must reference the bundled review procedure and the extra maintainer checks.
Reading the report remains necessary to assess fidelity and scope.
Direct execution cases reject delegation. File hashes, staged entries, and
HEAD detect unintended fixture changes. The commit-message grader also rejects
unstaged Git inspection. Missing traces and runtime failures are errors.

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

Manual text-file edits use the dedicated `apply_patch` tool for native
file-change reporting. Formatters, generators, package managers, and binary or
rich-document tools keep their own workflows.

The global `AGENTS.md` preserves the default Codex behavior except for the
always-on scannable reply style and language preferences. Code and code
comments are written in English regardless of the conversation language.
French discussions retain familiar English developer terms and borrowed
words rather than forcing French translations, including "lazy lookups",
"tests red", "buzz", and "spoiler". Familiar English technical expressions
stay intact instead of having individual words translated.
The `coding-preferences` skill groups all six original rule files under
`skills/coding-preferences/references/`, with their contents and paths metadata
preserved. Its entrypoint loads only the references relevant to the task.
Invoke `$coding-preferences` when you want these preferences applied. It does
not automatically activate during coding or review.
When invoked, these preferences also supply defaults for new projects.
Repository formatter, lint rules, and explicit project requirements take precedence.
The separate `$state-machines` skill is on demand too: it covers machine-first
design and identifying implicit transitions, without changing ordinary coding tasks.
`output-styles/scannable.md` is always applied through the global instructions,
with its path resolved under `CODEX_HOME` when set. Explicit user-requested
formats and exact output contracts still take precedence.
Replies and findings scale to the task instead of requiring a particular
table, section list, or separate report artifact.

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
├── output-styles/scannable.md
├── raycast/ai-collaboration-snippets.json
├── skills/
│   ├── apple-hig/
│   ├── brainstorm/
│   ├── commit-message/
│   ├── coding-preferences/
│   ├── devrel-voice/
│   ├── openai-reference/
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
~/workspace/codex/skills/coding-preferences/references/*
~/workspace/codex/output-styles/*
~/workspace/codex/raycast/ai-collaboration-snippets.json
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

The script copies global instructions and `output-styles/*.md` only when
contents differ. Coding preferences are installed by `sync-skills.sh`.
For migration, it removes only the six old `~/.codex/rules/*.md` files whose
contents exactly match their new skill references. Modified legacy copies
and unrelated files are preserved, with a message for each modified copy.
Run `sync-skills.sh` before `sync-agents-md.sh` when installing this migration.

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
~/.codex (instructions and reply style)
~/.agents/skills (skills)
```

Changes made directly under:

```text
~/.agents/skills/*
~/.codex/AGENTS.md
~/.codex/output-styles/*
```

may be overwritten the next time the corresponding sync script runs.

If you modify managed files under `~/.codex` or `~/.agents/skills` and want to keep them, copy the change back into the repository before synchronizing again.

## Repository scope

This repository manages:

```text
~/.codex/AGENTS.md
~/.codex/output-styles/*
~/.agents/skills/*
```

The interactive updater can merge missing recommendations into:

```text
~/.codex/config.toml
```

Existing configuration values remain authoritative, so the optional companion configuration can still be maintained independently per machine. Unlike the one-way synchronization scripts, `update-config.sh` previews its changes and requires consent before writing.
