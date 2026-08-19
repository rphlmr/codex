---
name: implement-plan
description: Execute a current, approved engineering plan through exactly one implementation subagent. Use after planning and material decisions are complete. Routes contract-heavy work to Sol and narrower mechanical work to Luna.
---

# Implement Plan

Execute the current approved plan through exactly one implementation subagent.

This is an execution handoff. Do not perform another planning, investigation,
review, or implementation phase in the parent thread.

## Establish the implementation brief

Treat the approved plan as current.

### Pasted plan

When the current invocation contains a complete implementation plan:

- use that plan verbatim;
- do not summarize, restructure, normalize, or reinterpret it;
- include only explicit amendments stated after the plan.

### Plan from the current conversation

Otherwise:

- use the latest explicitly approved final plan from the current conversation;
- preserve its wording and structure;
- append only later explicit decisions or corrections;
- exclude exploratory discussion, rejected alternatives, superseded plans, and
  unrelated conversation.

Do not inspect the repository to verify plan freshness.

Do not recreate an already complete plan as a shorter brief. Rewriting can omit
important compatibility, validation, or acceptance details.

If no complete approved plan can be identified, stop. Do not create a new plan
under this skill.

Treat a plan as complete only when it contains, at the level required by the
task:

- a clear outcome;
- executable implementation boundaries or steps;
- settled material decisions and constraints;
- objectively checkable acceptance criteria;
- required validation commands or validation expectations.

For a simple change, these elements may be concise or combined. Do not require
ceremonial sections when the required information is already explicit.

If a material element is missing, stop and identify the missing element. Do not
infer, reconstruct, or repair the plan under this skill.

## Validation contract

Treat the validation specified by the approved plan as the complete required
validation set.

- Preserve exact validation commands when they are present in the approved plan
  or were explicitly added as a later approved amendment.
- Do not add broader test suites or validation categories.
- Do not remove or weaken required validation.
- Do not convert descriptive validation requirements into guessed commands in
  the parent thread.

The implementation agent may resolve exact repository commands when they were
not established during planning.

## Select the implementation agent

Select the implementation agent from the approved plan before spawning it.

Use `sol_implementer` when the plan changes any of:

- exported or public TypeScript APIs;
- conditional, recursive, nominal, or inference-heavy types;
- emitted declarations;
- shared monorepo contracts;
- compatibility or migration surfaces;
- authentication, security, persistence, or build infrastructure.

Use `luna_implementer` for:

- localized runtime behavior;
- mechanical refactors with exact instructions;
- narrow UI changes;
- documentation;
- repetitive test additions;
- corrections where a verifier has already identified the exact symbols and
  expected types.

The Sol criteria take precedence when categories overlap. Honor an explicit
user request for either implementation agent.

Spawn exactly one selected implementation agent with `fork_turns: "none"`:

- `sol_implementer` for the contract-heavy and high-risk categories above;
- `luna_implementer` for the narrow and mechanical categories above.

Do not spawn additional implementation, exploration, planning, review, or
verification agents unless the user explicitly requests a separate review.

## Handoff

Send the selected agent this short execution contract:

> The following implementation plan is current, approved, and authoritative.
> Implement it directly under your standing agent instructions.
>
> Treat its validation section as the complete required validation set.

Append the approved implementation plan verbatim.

Do not duplicate the implementation agent's standing instructions in the
handoff.

Wait for the selected agent to return.

Do not inspect, implement, validate, or review the same changes independently in
the parent thread.

## Material decision escalation

When the implementation agent returns `BLOCKED_DECISION`, the parent owns the
decision.

Use the reported repository evidence together with:

- the approved plan;
- explicit decisions already made;
- active instructions;
- the requested outcome.

When those establish one unambiguous answer:

1. make the decision in the parent thread;
2. send only the resolved decision to the same implementation agent;
3. instruct that agent to continue.

Ask the user only when multiple valid outcomes still depend on product intent or
preference.

Do not:

- ask the implementation agent to choose an architecture;
- ask it to recommend between product or API alternatives;
- replace it because it escalated;
- spawn a second implementation agent;
- send the complete plan again unless the agent requests missing context.

## Completion

When the implementation agent completes:

- inspect its completion report and require:
  - one line for every acceptance criterion;
  - the concrete test, declaration, or behavior proving each criterion;
  - every exact required validation command and its result;
  - every declaration-inspection requirement and its result;
  - explicit `Unresolved` and `Unverified` sections, using `None` when empty;
- if any required report element is absent, send the same implementation agent
  a targeted follow-up identifying the missing report elements and wait for its
  corrected completion report before proceeding;
- report the implementation outcome;
- include acceptance-criterion results;
- include validation commands and results;
- include deviations, unverified items, and unresolved issues;
- clearly state any failed required validation.

Do not redo the implementation or validation in the parent thread.

Do not claim successful completion when a required acceptance criterion remains
unsatisfied or required validation failed.
