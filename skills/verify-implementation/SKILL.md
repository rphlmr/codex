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

Spawn exactly one fresh custom-agent thread using:

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

Use the complete verifier response as authoritative evidence.

Do not reproduce it verbatim by default. Present a concise, faithful digest
without performing another repository review.

Always preserve:

- the exact status and material verdict;
- every finding or blocker and its identifier;
- every failed or materially unverified acceptance criterion;
- the evidence and impact needed to understand each finding;
- each finding's implementation-level or plan-level classification;
- every relevant failed, blocked, or unavailable validation command;
- every material uncertainty or qualification.

You may omit:

- evidence for acceptance criteria that passed;
- successful validation unrelated to the result;
- repeated rationale and duplicated conclusions;
- non-material detail that does not affect the status or next action.

Do not add findings, merge distinct findings or blockers, weaken evidence,
strengthen confidence, convert unverified criteria into verified criteria, or
include implementation fixes.

Do not append a separate parent review or assessment. For `FAIL` and
`INCONCLUSIVE`, the only parent-authored addition is `## Workflow Route`.

When the user explicitly requests the complete independent verification report,
return the verifier response unchanged.

If the report cannot be compressed without risking loss or reinterpretation,
return it unchanged rather than guessing.

## PASS

When the verifier returns `PASS`, return:

PASS

## Verification Summary

- **Verdict:** `<concise verifier conclusion>`
- **Acceptance criteria:** `<verified count>/<total count> verified`, when
  reliably determinable; otherwise state that every material criterion was
  verified.
- **Validation:** `<each required or material command and its result>`
- **Unverified:** `<reported non-material unverified items>`, when any exist.

Do not reproduce evidence for every passed criterion unless it is needed to
understand a material qualification or the user requested the complete report.

Do not add another review, perform implementation work, manufacture follow-up
concerns, or automatically invoke another agent.

A `PASS` ends this verification workflow.

## FAIL

When the verifier returns `FAIL`, return:

FAIL

## Verification Summary

State the verifier's concise verdict.

## Findings

Include every finding, preserving its identifier, affected criterion, evidence,
impact, and implementation-level or plan-level classification.

## Failed or Unverified Criteria

Include every failed or materially unverified acceptance criterion and its
concise reason.

## Validation

Include every relevant failed, blocked, or unavailable validation command.

Include successful validation only when it is necessary to understand the
verified boundary.

Do not begin another repository review merely to prepare the digest.

Do not automatically implement a fix.

Append:

## Workflow Route

- **Classification:** `<classification>`
- **Next action:** `<single concrete next action>`

Use exactly one of these classifications:

### `IMPLEMENTATION_FAILURE`

Use when:

- the approved plan remains valid;
- the implementation does not correctly satisfy it;
- the issue is local to implementation execution.

The next action should be:

Resume implementation using the approved plan and the verifier's failed
findings as correction requirements.

### `PLAN_FAILURE`

Use when:

- implementation exposed a flaw, contradiction, omission, or unresolved
  decision in the approved plan;
- correct implementation requires plan refinement first.

The next action should be:

Refine the approved plan before resuming implementation.

### `MIXED_FAILURE`

Use when:

- at least one issue is local to implementation;
- at least one issue requires plan reconsideration.

The next action should be:

Resolve the plan-level findings first, then resume implementation with the
remaining implementation findings.

### `UNRESOLVED_FAILURE`

Use only when:

- the verifier established a failure;
- the report does not contain enough evidence to classify it reliably as
  implementation-level, plan-level, or mixed.

The next action should identify the exact classification evidence that remains
missing.

Do not guess.

## INCONCLUSIVE

When the verifier returns `INCONCLUSIVE`, return:

INCONCLUSIVE

## Verification Summary

State the verifier's concise verdict.

## Verification Blockers

Include every blocker, preserving its identifier, affected criteria, evidence,
and required input or capability.

## Blocked or Unverified Criteria

Include every materially blocked or unverified acceptance criterion and its
concise reason.

## Validation

Include every relevant blocked, unavailable, or unrun validation command.

You may omit evidence for criteria that were already verified.

Do not treat the implementation as passed or failed.

Do not start implementation work.

Append:

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
