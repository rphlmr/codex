---
name: verify-implementation
description: Independently verify a completed implementation against its approved plan, constraints, and acceptance criteria using a fresh Sol Medium verifier. Use after implementation when the user wants an independent correctness check.
---

# Verify Implementation

Independently verify the completed implementation using exactly one
`sol_verifier` subagent.

This is verification, not implementation.

## Prepare the verification brief

Extract the final approved state from the current conversation.

Provide the verifier with:

- original objective;
- final approved implementation plan;
- explicit decisions;
- relevant constraints;
- acceptance criteria;
- explicit non-goals when relevant;
- implementation agent's completion report, if available.

Do not include superseded plans, rejected alternatives, or irrelevant planning
discussion.

The repository itself is the source of truth for what was actually implemented.

## Spawn the verifier

Spawn exactly one:

`sol_verifier`

The verifier must use a fresh agent thread.

Do not ask the implementation agent to verify itself.

Do not ask the verifier to modify or repair the implementation.

Wait for the verifier to finish.

## PASS

If the verifier returns `PASS`:

- report that independent verification passed;
- summarize the acceptance criteria verified;
- include validation results;
- clearly mention anything the verifier could not independently verify.

Do not perform additional implementation work.

## FAIL

If the verifier returns `FAIL`:

Do not automatically ask the verifier to fix anything.

Inspect the verifier's evidence in the parent thread.

Classify the failure as one of:

1. `IMPLEMENTATION_FAILURE`
   - the approved plan is still valid;
   - implementation does not correctly satisfy it.

2. `PLAN_FAILURE`
   - implementation exposed a flaw, ambiguity, or missing decision in the
     approved plan itself.

For `IMPLEMENTATION_FAILURE`:

- explain the concrete failure;
- the implementation can subsequently be resumed with the original implementer
  or another explicitly selected implementation agent.

For `PLAN_FAILURE`:

- return to parent-agent reasoning;
- resolve the plan or ask the user only when product intent is genuinely
  required;
- do not delegate architectural decision-making to the verifier.
