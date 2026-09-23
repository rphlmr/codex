---
name: final-implementation-plan
description: Finalize the latest completed Plan mode result into a self-contained implementation handoff, without reopening planning.
---

# Final Implementation Plan

Finalize the latest completed Plan mode plan. Planning, investigation, and
material decisions are already complete; do not repeat them.

## Final plan contract

The final plan must:

- Be grounded in the relevant repository state inspected during planning;
  do not rely on assumptions that could have been checked locally.
- Be a concise, self-contained execution contract that does not require the
  preceding conversation.
- State the objective and observable end state.
- Name affected files, modules, symbols, and package or public surfaces when
  established, and state the intended change at each boundary.
- Describe the required changes in dependency order, preserving settled
  behavior, public API, compatibility, migration, generated-output, and scope
  decisions when relevant.
- Include explicit constraints and non-goals that prevent plausible but
  unwanted changes.
- Include objectively checkable acceptance criteria.
- Include concrete validation. Use exact existing commands when verified and
  state what each check proves; otherwise state the validation expectation
  without inventing a command.
- Leave no material product, architecture, API, compatibility, persistence,
  migration, or security decision unresolved.
- Distinguish required work from optional follow-up work.
- Omit exploratory analysis, rejected alternatives, settled rationale, and
  low-level details safely discoverable from nearby code.

Preserve the source plan's wording, structure, and implementation detail when it
already meets the contract. Otherwise add only required information established
during planning, plus explicit later decisions and corrections. Preserve exact
validation commands when known; otherwise state validation expectations.

The result must stand alone without losing settled boundaries, acceptance
criteria, compatibility requirements, or details needed for implementation.
Exclude superseded decisions, exploratory discussion, and unrelated history.

If finalization needs new investigation or a material decision, output a concise
blocker identifying the missing element and smallest next action. Do not invent
requirements, reopen decisions, implement, delegate, or invoke execution.

On success, output only the final implementation plan.
