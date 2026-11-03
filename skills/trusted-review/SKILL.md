---
name: trusted-review
description: Reviews code and fixes existing findings with concrete evidence, impact-based priorities, scoped validation, and an explicit stopping point. Use when reviewing a diff, branch, PR, or feature, auditing code, acting on review findings, or planning a review or fix round.
---

# Trusted Review

A review exists so the user can trust its result. Report fewer, proven
findings over many plausible ones.

## Scope and stopping point

Before starting, identify the requested outcome, review scope, acceptance
criteria, and relevant validation from the request and repository. Do not
require a separate planning exercise when these are already clear. Completion
means the agreed work and checks are done, not that no further improvement is
conceivable or that several models agree.

Route a request about existing findings to a fix round, triage, or targeted
verification, as requested. A targeted verification checks the named behavior
and plausible related regressions; it is not a new general audit.

When a repeated request seeks reassurance about unchanged, already reviewed
work, state the existing result and recommend closure or the specific missing
check before launching another review. Do not automatically seek a second
model's verdict. If the user explicitly chooses another review after this
reminder, honor it. New code, requirements, evidence, or an uncovered acceptance
criterion can justify a scoped review without that reminder. Never conceal a
supported serious defect to satisfy a review limit.

## Independent review

Use Codex's bundled `review-agent` skill as the base review procedure. Resolve
its absolute path from `$CODEX_HOME/skills/.system/review-agent/SKILL.md`, or
`~/.codex/skills/.system/review-agent/SKILL.md` when `CODEX_HOME` is unset.
Confirm it exists before spawning. Do not copy or maintain its procedure here.
If it is unavailable, report that dependency as blocked rather than silently
substituting another review process.

For a review or audit, the parent spawns exactly one fresh built-in agent with
`fork_turns: "none"`. Do not reuse the implementation agent or an earlier
reviewer. An explicitly requested independent review after fixes gets a new
agent too, scoped to the requested verification rather than automatically to
the whole feature.

Give the reviewer only:

- the repository's absolute path and the diff, branch, PR, feature, or files
  in scope, with a comparison base when established;
- the user's objective, explicit requirements, constraints, and acceptance
  criteria that define correct behavior;
- the absolute path to the bundled `review-agent` skill, explicitly invoked
  as `$review-agent`, and the absolute path to [your extra checks](references/review.md).

Tell the agent it is already the delegated reviewer: read and apply the
bundled skill plus the extra checks, inspect the target independently, and
return the report. Do not run this parent orchestration again.

Do not pass conversation history, implementation reports, parent analysis,
suspected findings, proposed fixes, or a preferred verdict. The reviewer reads
current code, repository instructions, and raw evidence independently. If the
scope is materially unclear, resolve it before spawning; do not invent it.
For a targeted verification, pass the behavior to verify and relevant paths
as the scope, without a prior verdict or the proposed implementation rationale.

The parent waits without performing a competing review or changing the code.
The reviewer owns inspection, proof, ranking, and targeted checks, and changes
no files or Git state. It must not delegate further.

Preserve the reviewer's complete findings-first report unchanged in a linked
detail file outside the target repository, using an authorized writable
artifact location. This supporting file is part of the review deliverable;
the reviewer itself remains read-only. Return a short recommendation followed
by **🛠️ Act first**, **🔎 Resolve before deciding**, **🕒 Can wait**, and
**🧪 Checks and limits** as needed. For immediate actions, give a plain title,
a short trigger and user-impact explanation, and a concrete **Change:**
recommendation. Link supporting evidence and name one starting action only
when work remains. Do not use coded finding IDs such as C01: label findings
**Issue 1**, **Issue 2**,
and so on in the summary, with links to their corresponding unchanged findings
in the supporting report. These numbers are references, not priorities. Do not
reduce the report to checkboxes or impose a 150-word cap. Derive this summary
only from the reviewer's findings, priorities, and gaps; do not add findings,
strengthen confidence, or imply every P2 blocks launch. Retain all findings
in the detail file, grouping lower-impact items when necessary. If no writable
artifact location is available, link the reviewer's source evidence and keep
the full report available in its returned output; disclose that the detail
file could not be saved. If the agent is unavailable, report that the
independent review could not run; do not substitute a parent review.

## Fix requests

For a request to fix existing findings, the parent follows the rules below.
An existing review report is input to the fix round; do not spawn a review
merely to repeat it. Fixes remain in the parent unless implementation was
separately delegated. Start another independent review only when requested.

## Fix by impact

A review alone changes no code. When the user asks for fixes:

- When the user names the findings to fix, fix exactly those. Their choice
  wins over the ranking.
- Otherwise, fix demonstrated defects that prevent the agreed behavior or
  have material security, data-integrity, or operational impact within scope.
  Recheck the evidence behind a priority label before treating it as required
  work. A request to fix all confirmed defects includes lower-priority ones.
- Account for already reported items left unchanged with a short reason;
  do not make the user choose from a fresh list of optional improvements.
- For a testable defect, use a regression check that fails before the fix
  and passes after. Use proportionate validation for documentation or other
  changes where an automated regression test would not establish behavior.
- Prefer the smallest fix, or a visible limitation, over a new mechanism.
  Ask before adding one (a retry, a fallback, a watchdog, a cache, a state).
- Before fixing a finding, check whether it exists only because a premise was
  ignored. Then the fix deletes code instead of guarding it.

## Close the round

- After fixes, verify the corrected behavior and plausible related
  regressions, and run the repository's required gates. Run broader suites
  when the affected boundary or an observed failure warrants them; do not
  require every suite and e2e run for every fix. Report actual results and
  any material validation gap. A review alone runs checks relevant to its scope.
- Close when the requested fixes and required checks are complete. Report
  any unresolved blocker with its scenario, evidence, impact, and the reason
  it prevents the intended use. Priority alone does not establish a blocker.
- State that the review or fix round is complete without claiming the entire
  product is defect-free or ready to release beyond the verified scope.
  Do not propose another review or append optional improvements.
