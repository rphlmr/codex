# Staged commit messages

Use only `git diff --cached --no-ext-diff`, optionally with `--stat` or
`--name-status`, as evidence for the message. Confirm repository context with
`git rev-parse --is-inside-work-tree` when needed. Do not inspect unstaged or
untracked content, history, branches, or remotes for this task.

Choose the dominant before/after outcome:
- `feat` introduces a capability, including optional error-handling behavior.
- `fix` corrects an existing operation that violated its contract.
- Supporting tests and documentation do not override the main change.

Use one matching type and emoji:

| Type | Emoji |
| --- | --- |
| feat | ✨ |
| fix | 🐛 |
| docs | 📝 |
| style | 💄 |
| refactor | ♻️ |
| perf | ⚡️ |
| test | ✅ |
| build | 📦️ |
| ci | 🎡 |
| chore | 🔨 |
| revert | ⏪️ |

Return exactly one line: `<type>: <emoji> <description>`.
Add `!` after the type only when the staged diff demonstrates a breaking
public contract. Use an imperative, lowercase description, no scope, body,
footer, trailing period, quotation marks, or Markdown fence.
Keep the entire displayed message at most 50 characters.

When the index is empty or cannot be inspected, return exactly:
No staged diff available.

Do not modify files, the index, or Git state. Do not commit or contact remotes.
