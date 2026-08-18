---
name: final-implementation-plan
description: Convert the latest completed Plan mode result into the final self-contained implementation plan required by the active AGENTS.md instructions. Use after planning and material decisions are complete and before implementation.
---

# Final Implementation Plan

Produce the final implementation plan for the current task.

Planning, repository investigation, and material decision-making are already
complete. This is a finalization pass, not another planning phase.

## Source

Use the latest completed Plan mode plan from the current conversation as the
authoritative planning result.

Incorporate only:

- decisions explicitly settled after that plan;
- corrections explicitly made after that plan;
- information already established during planning that is required by the
  active `AGENTS.md` final-plan rules but omitted from the completed plan.

Exclude:

- exploratory discussion;
- rejected alternatives;
- superseded decisions;
- unresolved suggestions;
- planning rationale unnecessary for implementation;
- unrelated conversation.

Do not repeat repository investigation already completed during planning.

## Finalize

Treat the active `AGENTS.md` final-plan rules as authoritative.

Transform the completed planning result into the final implementation plan
required by those instructions. Do not duplicate or reinterpret the
`AGENTS.md` planning contract beyond what is necessary to perform that
transformation.

When the source plan already satisfies the active requirements, preserve its
wording, structure, and level of detail except for explicit later amendments.

Otherwise, make only the changes required to produce a complete,
self-contained implementation handoff from information already established
during planning.

Making established information explicit as an implementation step, constraint,
acceptance criterion, validation requirement, non-goal, or implementation
boundary is finalization, not new planning.

Preserve important implementation details from the source plan. Do not replace
a detailed plan with a shorter summary that loses information needed for direct
implementation.

Preserve exact validation commands when they were established during planning.
Otherwise state the required validation without inventing repository commands.

If satisfying the active final-plan requirements would require new exploratory
repository investigation or a new material decision, stop instead of inventing
it.

## Restrictions

Do not restart or extend planning.

Do not reopen settled decisions.

Do not introduce new architecture, requirements, behavior, scope, assumptions,
or optional work.

Do not implement anything.

Do not spawn another agent.

Do not invoke an implementation workflow automatically.

## Output

When finalization succeeds, output only the final implementation plan.

When finalization cannot proceed, output only a concise blocker statement that
identifies the missing material element and the smallest next action required to
resolve it.
