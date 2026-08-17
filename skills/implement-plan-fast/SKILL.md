---
name: implement-plan-fast
description: Implement an already-refined engineering plan using Luna Max in Fast mode. Use when planning and decision-making are complete and the user explicitly wants faster implementation.
---

# Implement Plan Fast

Implement the already-agreed plan through exactly one dedicated fast
implementation subagent.

This is an execution handoff, not another planning phase.

## Parent role

The parent agent owns:

- requirements;
- architecture;
- product and behavioral decisions;
- resolving material ambiguity;
- decisions reported by the implementation agent.

The implementation subagent owns execution only.

## Prepare the implementation brief

Extract the final agreed state from the current conversation.

Pass the implementation agent a concise brief containing only information
required for execution:

- objective;
- finalized implementation plan;
- explicit decisions already made;
- relevant constraints;
- acceptance criteria;
- known affected areas when established;
- validation requirements;
- explicit non-goals when relevant.

Do not pass the entire conversation or exploratory discussion.

Discard superseded alternatives, rejected approaches, and planning noise.

## Implementation agent

Spawn exactly one:

`luna_implementer_fast`

Do not substitute another model.

Do not spawn additional implementation, exploration, review, or planning agents
unless the user explicitly requests them.

## Handoff

Give the implementation agent the prepared implementation brief.

Explicitly tell it to:

- implement the brief directly;
- inspect the current repository state before editing;
- complete the implementation and validation;
- stop and report any unresolved material decision according to its agent
  instructions.

Wait for the implementation agent to return.

Do not independently implement the same changes in the parent thread.

## Material decision escalation

If the implementation agent returns `BLOCKED_DECISION`, the parent agent owns
the decision.

Analyze the reported facts yourself.

Do not ask the implementation agent to choose an architecture, evaluate
high-level trade-offs, or recommend a product/design decision.

If the existing conversation, agreed goals, repository evidence, and active
instructions are sufficient to resolve the decision confidently:

1. make the decision in the parent thread;
2. send the resolved decision back to the same implementation agent;
3. instruct it to continue implementing the approved plan.

If the decision genuinely requires user input:

1. explain the decision concisely;
2. obtain the user's decision;
3. send it back to the same implementation agent;
4. have it continue.

## Completion

When the implementation agent completes:

- report the implementation outcome;
- include validation results and unresolved issues;
- do not redo its implementation work.
