---
name: commit-message
description: Generate exactly one concise Conventional Commit message from the currently staged Git diff without committing or modifying the repository. Use when the user asks for a commit message, commit title, or Conventional Commit based on staged changes.
---

# Commit Message

Generate one commit message from staged changes only.

## Execution

Delegate the complete task to exactly one `commit_message` custom agent.

The `commit_message` agent owns the entire workflow, including:

- validating that the current directory is inside a checked-out Git repository;
- inspecting the staged Git diff;
- determining the primary intent of the staged changes;
- selecting the Conventional Commit type and emoji;
- writing the commit message;
- enforcing the 50-character limit;
- handling the absence of staged changes.

The parent agent must not perform any part of that workflow.

Specifically, the parent agent must not:

- inspect the Git diff;
- run Git commands;
- analyze staged changes;
- determine the commit type;
- generate the commit message;
- revise the subagent's result;
- spawn additional agents.

Wait for the `commit_message` agent to complete.

## Output

Return the `commit_message` agent's result unchanged.

Do not add:

- Markdown;
- code fences;
- quotation marks;
- explanations;
- alternatives;
- commentary;
- prefixes or suffixes.

If the `commit_message` custom agent is unavailable or cannot be spawned, output exactly:

Commit-message agent unavailable.

Do not fall back to performing the task in the parent agent.