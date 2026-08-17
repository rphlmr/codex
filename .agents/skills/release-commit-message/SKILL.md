---
name: release-commit-message
description: Generate a Release Please-compatible multi-entry Conventional Commit message from the currently staged Git diff. Use when the user asks for a release commit message, changelog-producing commit, or one commit representing multiple fixes, features, or breaking changes. Do not use for an ordinary single-line commit message.
---

# Release Commit Message

Generate one commit message from staged changes only. Make the message suitable
for Release Please to turn multiple logical changes into accurate release notes.

## Inspect

Confirm repository context and inspect only the staged diff with read-only
commands such as:

```text
git rev-parse --is-inside-work-tree
git diff --cached --no-ext-diff --stat
git diff --cached --no-ext-diff --name-status
git diff --cached --no-ext-diff
```

Do not inspect unstaged or untracked changes, branch names, commit history, or
remote state. Treat the staged diff as the sole source of truth.

## Compose

Identify distinct user-visible release units and group related files by outcome.
Do not create a separate entry for every file.

Write the message in this order:

1. A concise Conventional Commit header for the primary release unit.
2. An optional short body covering important shared context.
3. Additional Conventional Commit messages at the bottom, one for each other
   meaningful release unit.

Use accurate Conventional Commit types:

- `feat` for new behavior;
- `fix` for a bug fix;
- `deps` for a user-relevant dependency update;
- another accurate type for non-releasing work;
- `!` and an indented `BREAKING-CHANGE:` note for incompatible behavior.

At least one `feat`, `fix`, or `deps` entry is required to trigger Release
Please, but never misclassify maintenance solely to force a release.

Keep additional messages at the bottom. Separate each entry with a blank line.
Do not place prose after the first additional message. Use this shape:

```text
feat(scope): add primary capability

Brief context shared by the staged changes.

fix(scope): correct related behavior

refactor(scope)!: remove obsolete behavior
  BREAKING-CHANGE: explain what was removed and what users must do.
```

Use imperative, lowercase descriptions. Keep headers concise, omit emoji, and
describe outcomes rather than filenames. Include only entries supported by the
staged diff.

## Output

Return only the complete plain-text commit message. Do not add Markdown fences,
an introduction, explanations, alternatives, or Git commands.

If no staged diff is available, return exactly:

```text
No staged diff available.
```

Never stage, unstage, commit, or modify files.
