---
name: commit-message
description: Generate exactly one concise Conventional Commit message from the currently staged Git diff without committing or modifying the repository. Use when the user asks for a commit message, commit title, or Conventional Commit based on staged changes.
---

# Commit Message

Generate exactly one commit message from the currently staged Git changes using
exactly one `commit_message` custom agent.

This skill generates text only.

It does not stage files, create a commit, or modify the repository.

## Workflow scope

The delegation and output rules below are defaults for the message-generation
step. Explicit user instructions take precedence over these skill guidelines.
When another arrangement is requested, perform that step outside this skill
rather than silently dropping the user's requirement.

Text-only restrictions apply to this step and its custom agent. For a broader
request to commit or open a PR, the parent may perform authorized preparation
before delegation and delivery afterward. A generated message alone does not
complete a request to create a commit or PR.

## Delegate

Spawn exactly one fresh custom-agent thread using:

`commit_message`

Ask it to inspect the currently staged Git diff and return the result according
to its own output contract.

The custom agent owns the complete workflow, including:

- confirming repository context;
- inspecting staged changes;
- determining the dominant intent;
- selecting the Conventional Commit type and emoji;
- writing the description;
- enforcing the complete 50-character limit;
- handling the absence of staged changes.

Do not pass proposed wording, a proposed commit type, or assumptions about the
staged changes as evidence.

The staged diff is the sole source of truth.

## Parent Boundaries

The parent agent must not:

- run Git commands;
- inspect staged changes;
- inspect unstaged changes;
- inspect untracked files;
- inspect branch or commit history;
- determine the commit type;
- draft a competing message;
- revise the custom agent's result;
- provide alternatives;
- spawn another agent;
- commit the changes.

Do not duplicate the delegated analysis in the parent while this step is running.

## Output

Return the `commit_message` custom agent's result unchanged.

Do not add:

- Markdown;
- a code fence;
- quotation marks;
- an introduction;
- an explanation;
- an alternative;
- commentary;
- a prefix;
- a suffix.

The final response must contain only the custom agent's exact output.

## Agent Unavailable

If the `commit_message` custom agent is unavailable or cannot be spawned, report:

Commit-message agent unavailable.

When the user did not require that specific agent, the parent may complete the
requested text-generation step directly using the same evidence boundaries.
Do not claim that the custom agent produced the result. When the user did
require that agent, report the blocked step and continue only other authorized
work that does not depend on its result.
