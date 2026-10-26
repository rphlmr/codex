---
name: pr-changelog
description: Write PR/MR text or release notes from committed branch changes through a fresh agent. Does not open a PR.
---

# PR Changelog

Spawn exactly one fresh built-in agent with:

- `fork_turns: "none"`;
- `model: "gpt-6-luna"`;
- `reasoning_effort: "medium"`.

Always pass the model and effort explicitly; do not inherit the parent
settings. Do not require a custom agent definition. When the available
spawning tool names effort differently, use its equivalent setting. If the
configured model or effort is unavailable, use the unavailable-agent output
below instead of silently substituting another setting.

Give it the [procedure](references/procedure.md), the repository's absolute
path, and the user's relevant request and preferences. The agent owns Git
inspection and the final output. Do not propose wording, choose a commit type
or comparison target, or perform competing Git analysis in the parent chat.

Wait for the agent to complete. Return its exact output without rewriting,
framing, alternatives, or commentary. The agent does not modify files or Git
state and must not delegate further.

Pass the user's explicit base branch, mode, language, audience, and review
focus when supplied. The procedure preserves the complete committed branch
scope, inferred-base disclosure, compatibility, validation, and dirty-tree
notes. If the agent is unavailable, return exactly:

PR-changelog agent unavailable.

If the user requires uncommitted work, return exactly:

PR-changelog supports committed branch changes only.

A different workflow is required to summarize uncommitted work.

Do not fall back to parent-chat analysis if spawning fails.
