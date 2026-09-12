# Verification Status Handling

## Status Handling

The `verifier` agent owns the complete verification report schema.

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
`verifier` thread.

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

If the `verifier` custom agent is unavailable or cannot be spawned, output:

INCONCLUSIVE

## Verdict

The `verifier` custom agent was unavailable, so independent verification was not
performed.

Do not fall back to parent-thread verification while presenting it as
independent verification.
