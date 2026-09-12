---
name: commit-message
description: Generate one Conventional Commit message from staged changes using the commit-message agent. Does not commit.
---

# Commit Message

Generate text from the staged Git diff through exactly one fresh `commit_message`
custom agent. The agent owns repository inspection, message selection, the
50-character limit, and handling an empty staged diff.

Ask it to inspect the staged changes and follow its standing output contract.
Do not supply proposed wording, a commit type, or assumptions about the changes.

The parent does not run Git commands, inspect the repository or history, draft a
competing message, revise the result, or spawn another agent. This workflow does
not stage, commit, or modify files.

Return the agent's exact output with no Markdown, framing, alternatives, or
commentary. If the agent is unavailable, return exactly:

Commit-message agent unavailable.

Do not fall back to parent-thread analysis.
