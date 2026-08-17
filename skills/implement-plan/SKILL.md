---
name: implement-plan
description: Implement an already-refined engineering plan using a dedicated implementation subagent. Use when planning and decision-making are complete and the user wants the agreed plan implemented. Defaults to Luna Max; use Terra High only when explicitly requested.
---

# Implement Plan

Implement the already-agreed plan through exactly one dedicated implementation
subagent.

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

## Select the implementation agent

By default, spawn exactly one:

`luna_implementer`

If the user explicitly requests Terra for this invocation, spawn exactly one:

`terra_implementer`

If the user explicitly requests Sol for this invocation, spawn exactly one:

`sol_implementer`

Do not automatically escalate from Luna or Terra to Sol.

Do not spawn more than one implementation agent.

Do not spawn additional implementation, exploration, review, or planning agents
unless explicitly requested.

## Handoff

Give the selected implementation agent the prepared implementation brief.

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

If the decision genuinely requires user input because multiple valid outcomes
depend on product intent or user preference:

1. explain the decision concisely to the user;
2. obtain the required decision;
3. send that decision back to the same implementation agent;
4. have it continue.

Do not replace the implementation agent merely because it escalated a decision.

## Completion

When the implementation agent completes:

- inspect its completion report;
- report the implementation outcome to the user;
- include validation results and unresolved issues;
- do not redo its implementation work.
