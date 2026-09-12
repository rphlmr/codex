---
name: verify-implementation
description: Independently verify completed work against an approved plan and its acceptance criteria. Does not implement fixes.
---

# Verify Implementation

Independently verify a completed implementation using exactly one fresh
`verifier` custom agent.

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

`verifier`

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

Treat the complete `verifier` response as the canonical independent
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

For `PASS`, return the complete report unchanged and end the workflow.
For `FAIL`, `INCONCLUSIVE`, malformed output, or an unavailable agent, read
[status handling](references/status-handling.md) for the exact response and
workflow route. Do not start fixes or substitute parent verification.
