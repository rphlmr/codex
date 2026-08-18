---
name: session-handoff
description: Create a self-contained prompt that transfers established work and context from the current conversation into a fresh Codex session, including another repository. Use for handoffs or continuation prompts; do not use for unrelated prompt writing.
---

# Session Handoff

Produce a self-contained handoff for continuing the relevant work in a fresh
Codex session.

The handoff transfers established context and requirements. It does not continue
planning on behalf of the receiving session.

## Determine the handoff scope

Infer the intended target work from the current conversation.

Preserve the requested deliverable and the authorization boundary for the target
work. State whether the receiving session should investigate, diagnose, review,
plan, implement, or perform another explicitly requested action. A request to
create a handoff does not itself authorize the receiving session to modify files
or take external actions.

When the target is another repository, isolate the work that belongs to that
repository and include source-project context only when it helps explain or
constrain the target work.

Do not transfer unrelated parts of the current task.

Prefer the smallest handoff that preserves everything needed for the receiving
session to make correct decisions.

## Transfer the contract

Preserve established information that can materially affect the target work,
including when relevant:

- the objective and desired observable outcome;
- the requested deliverable and permitted operating mode;
- why the work is needed;
- the source or consumer behavior that creates the requirement;
- the current state of the work, including completed changes and remaining work;
- affected repositories, files, modules, and symbols when already established;
- public APIs, types, contracts, integration points, and compatibility
  requirements;
- concrete usage examples, failing cases, errors, or code snippets already
  established;
- decisions and constraints already settled;
- validation already performed, preserving exact commands, results, failures,
  and unverified checks;
- blockers, material risks, unresolved issues, and the next required action;
- non-goals or rejected directions only when they materially constrain the
  target work;
- acceptance criteria;
- dependencies between the target work and remaining source-project work.

Preserve exact names, signatures, values, examples, and other technical details
when they matter.

Do not replace concrete established information with a vague summary.

## Respect the repository boundary

Distinguish requirements imposed on the target repository from assumptions about
how that repository should satisfy them.

Treat established consumer-facing behavior, contracts, and settled requirements
as authoritative context.

Do not present unverified assumptions about the target repository's:

- architecture;
- internal APIs;
- files or symbols;
- implementation strategy;
- conventions;
- scripts or validation commands;

as facts.

Include such information only when it was actually established from the target
repository, and preserve any uncertainty that remains relevant.

The receiving session should inspect the target repository before making local
decisions or changes.

## Prepare the receiving session

Write the handoff for an agent that has no access to the current conversation.

Give it enough context to understand:

- what outcome or deliverable is requested;
- why the work is needed;
- what behavior or contract must result;
- what has already been completed and validated;
- what has already been decided;
- what actions are and are not authorized;
- what must not change;
- what remains for the target repository to determine or do.

When target-repository investigation or planning is still required, state that
work explicitly rather than embedding speculative implementation instructions
in the handoff.

The receiving session must follow the active instructions and `AGENTS.md` of its
own repository. Do not copy source-repository workflow instructions into the
handoff unless they are themselves part of the transferred requirement.

## Keep signal, remove history

Do not produce a chronological conversation summary.

Exclude:

- conversational noise;
- exploratory reasoning that does not constrain the target work;
- superseded plans or decisions;
- alternatives that were rejected but no longer matter;
- source-repository implementation details unrelated to the target contract;
- speculative target-repository implementation;
- repeated rationale;
- instructions that apply only to the current session.

Every transferred detail should help the receiving session understand the
problem, preserve a requirement, avoid a known wrong direction, or determine its
next action.

Do not expand the scope or invent missing requirements.

## Output

Output only one copy-paste-ready prompt addressed directly to the receiving
Codex session.

Make the handoff self-contained.

Use whatever structure best fits the task. For substantial handoffs, prefer this
logical order:

1. objective, requested deliverable, and permitted operating mode;
2. relevant source or consumer context;
3. required behavior and contracts;
4. current work and validation state;
5. constraints, compatibility requirements, and non-goals;
6. concrete examples or evidence;
7. acceptance criteria;
8. target-repository investigation, decisions, or actions still required.

Combine or omit sections when that makes the handoff clearer.

End at the target-repository boundary: transfer what is known, then let the
receiving session perform the authorized local work under its own repository
instructions.

Do not include commentary, explanation, or framing outside the handoff.
