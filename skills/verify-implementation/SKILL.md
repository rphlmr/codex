---
name: verify-implementation
description: Independently verify a completed implementation against its final approved plan, decisions, constraints, acceptance criteria, and required validation using exactly one fresh sol_verifier custom agent.
---

# Verify Implementation

Independently verify a completed implementation using exactly one fresh
`sol_verifier` custom agent.

This workflow performs verification only.

It does not:

- implement changes;
- repair failures;
- revise the plan automatically;
- ask the implementation agent to verify itself;
- treat implementation-agent claims as proof.

## Prepare the Verification Brief

Extract the final approved state from the current conversation.

Prepare a concise verification brief containing:

- the original objective;
- the final approved implementation plan;
- explicit decisions;
- relevant constraints;
- every acceptance criterion;
- required validation commands or validation expectations;
- explicit non-goals when relevant;
- known affected areas when already established;
- a known comparison base when already established;
- the implementation agent's completion report, when available;
- validation claimed by the implementation agent, when available;
- known environmental limitations relevant to verification.

Preserve existing acceptance-criterion identifiers.

When acceptance criteria do not have identifiers, preserve their exact wording
and allow the verifier to assign stable identifiers.

Treat the implementation agent's report as claims to verify.

Do not convert claimed validation into confirmed validation.

Do not include:

- superseded plans;
- rejected approaches;
- exploratory planning discussion;
- implementation alternatives that were not approved;
- unrelated repository context;
- your own verification conclusion.

The repository is the source of truth for what was actually implemented.

If a material requirement is absent or ambiguous, identify that absence in the
brief.

Do not invent acceptance criteria merely to make verification possible.

## Delegate

Spawn exactly one fresh custom-agent thread with `fork_turns: "none"` using:

`sol_verifier`

Give it the prepared verification brief.

Ask it to independently inspect the implementation and return exactly one of:

- `PASS`;
- `FAIL`;
- `INCONCLUSIVE`.

The verifier owns:

- repository inspection;
- diff inspection;
- acceptance-criteria mapping;
- evidence collection;
- targeted validation;
- classification of concrete findings;
- identification of verification blockers;
- the complete verification report.

## Parent Boundaries

Before the verifier returns, the parent agent must not:

- run validation commands;
- perform a second implementation review;
- independently inspect the diff for correctness;
- ask the implementation agent to self-verify;
- spawn another verifier;
- ask the verifier to modify or repair files.

Do not bias the verifier with a parent-agent conclusion.

Do not ask the verifier to approve a preferred implementation merely because it
matches the plan superficially.

## Validate the Result Contract

The first non-empty line of the verifier response must be exactly one of:

`PASS`

`FAIL`

`INCONCLUSIVE`

Do not reinterpret an ambiguous or malformed response as `PASS`.

## Present the Verification Result

Treat the complete `sol_verifier` response as the canonical independent
verification report.

Return that report unchanged.

Do not create a second parent-authored digest.

The verifier already owns:

- the user-facing status;
- the verification snapshot;
- findings and blockers;
- the complete acceptance-criteria map;
- validation evidence;
- reported repository-state changes.

Do not:

- add, remove, merge, or rewrite findings or blockers;
- rewrite the verdict or snapshot;
- omit passed acceptance criteria;
- omit successful validation;
- weaken evidence or uncertainty;
- strengthen confidence;
- convert failed or unverified criteria into verified criteria;
- add implementation fixes;
- append a separate parent review or assessment.

For `FAIL` and `INCONCLUSIVE`, the only parent-authored addition is
`## Workflow Route`, appended after the unchanged verifier report.

## Status Handling

The `sol_verifier` agent owns the complete verification report schema.

The parent owns only workflow routing after a valid verification status is
returned.

When the verifier returns `PASS`, return the complete verifier report unchanged
and end the verification workflow.

When the verifier returns `FAIL`, return the complete verifier report unchanged.

Do not perform another repository review or implement a fix.

Then append:

## Workflow Route

- **Classification:** `<classification>`
- **Next action:** `<single concrete next action>`

Use exactly one of these classifications:

### `IMPLEMENTATION_FAILURE`

Use when:

- the approved plan remains valid;
- every reported finding is classified as `IMPLEMENTATION`.

The next action should be:

Resume implementation using the approved plan and the verifier's failed findings
as correction requirements.

### `PLAN_FAILURE`

Use when:

- every reported finding is classified as `PLAN`;
- correct implementation requires plan refinement before implementation
  resumes.

The next action should be:

Refine the approved plan before resuming implementation.

### `MIXED_FAILURE`

Use when:

- at least one finding is classified as `IMPLEMENTATION`;
- at least one finding is classified as `PLAN`.

The next action should be:

Resolve the plan-level findings first, then resume implementation with the
remaining implementation findings.

### `UNRESOLVED_FAILURE`

Use only when:

- the verifier established a failure;
- one or more findings do not have a reliable `IMPLEMENTATION` or `PLAN`
  classification;
- the available evidence does not support `IMPLEMENTATION_FAILURE`,
  `PLAN_FAILURE`, or `MIXED_FAILURE`.

The next action should identify the exact classification evidence that remains
missing.

Do not guess.

## INCONCLUSIVE

When the verifier returns `INCONCLUSIVE`, return the complete verifier report
unchanged.

Do not treat the implementation as passed or failed.

Do not start implementation work.

Then append:

## Workflow Route

- **Classification:** `VERIFICATION_BLOCKED`
- **Next action:** `<single concrete action required to remove the highest-impact verification blocker>`

The next action must come directly from the verifier's reported blockers.

After the blocker is resolved, run this verification workflow again with a fresh
`sol_verifier` thread.

## Invalid Verifier Result

If the custom agent returns a result whose first non-empty line is not `PASS`,
`FAIL`, or `INCONCLUSIVE`, do not infer a status.

Return:

INCONCLUSIVE

## Verdict

The verifier did not follow the required result contract, so no reliable
verification status can be assigned.

## Verifier Output

Then include the custom agent's original response unchanged.

Do not silently repair or reinterpret its conclusion.

## Agent Unavailable

If the `sol_verifier` custom agent is unavailable or cannot be spawned, output:

INCONCLUSIVE

## Verdict

The `sol_verifier` custom agent was unavailable, so independent verification
was not performed.

Do not fall back to parent-thread verification while presenting it as
independent verification.
