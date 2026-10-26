---
name: commit-message
description: Generate one Conventional Commit message from staged changes through a fresh agent. Does not commit.
---

# Commit Message

Spawn exactly one fresh built-in agent with:

- `fork_turns: "none"`;
- `model: "gpt-6-luna"`;
- `reasoning_effort: "low"`.

Always pass the model and effort explicitly; do not inherit the parent
settings. Do not require a custom agent definition. When the available
spawning tool names effort differently, use its equivalent setting. If the
configured model or effort is unavailable, use the unavailable-agent output
below instead of silently substituting another setting.

Give it the [procedure](references/procedure.md), the repository's absolute
path, and the user's relevant request and preferences. The agent owns Git
inspection and the final output. Do not propose wording, choose a commit type
or comparison target, or perform competing Git analysis in the parent chat.

Include these constraints directly in the handoff, so they apply before the
agent's first command:

> Read the full procedure before inspecting Git. Do not run `git status`,
> including as a repository check or in a compound shell command. The only
> permitted Git commands are `git rev-parse --is-inside-work-tree` and
> `git diff --cached --no-ext-diff`, optionally with `--stat` or `--name-status`.
> Determine the type from the staged before/after behavior: a new capability
> is `feat`; correcting an existing operation is `fix`. Do not infer a bug
> merely because the added capability handles errors or failed requests.

The parent must not run `git status` either. The delegate has all the Git
inspection it needs within this allowlist.

Wait for the agent to complete. Return its exact output without rewriting,
framing, alternatives, or commentary. The agent does not modify files or Git
state and must not delegate further.

The procedure preserves the staged-only evidence, type and emoji mapping,
breaking-change marker, 50-character limit, and empty-diff output. If the
agent is unavailable, return exactly:

Commit-message agent unavailable.

Do not fall back to parent-chat analysis if spawning fails.
