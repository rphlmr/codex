---
name: trusted-review
description: Review code or fix existing findings with concrete evidence, impact-based priorities, and scoped validation. Invoke explicitly for this review workflow.
---

# Trusted Review

Establish the requested scope, objective, comparison base, and relevant checks
from the request and repository. A review is read-only unless fixes are requested.
Prefer fewer demonstrated defects to plausible concerns.

## Review

Work in the current chat unless an independent review or delegation is requested.
Use [the maintainer and evidence checks](references/review.md).
Do not broaden a diff review into a codebase audit.

For an explicitly requested independent review, use one fresh built-in agent
with `fork_turns: "none"` and the bundled `review-agent` skill if available.
Give it the repository, scope, requirements, raw evidence, and the maintainer
checks reference, without a preferred verdict or the implementation narrative.
It must not delegate again.
If independence cannot be provided, report that limitation rather than calling
a self-review independent.

Report actionable findings first, with impact, source location, evidence, and
the smallest correction. Separate material unverified concerns from confirmed
defects. Follow with actual checks and relevant gaps. Say when no findings exist.
Save a separate report only when requested or needed for a large deliverable.

## Fixes

Fix the findings the user names. Otherwise fix demonstrated in-scope defects
that prevent the requested behavior or have material impact.
Use failing-first regression coverage for testable defects, then run the
affected checks. Preserve repository architecture and avoid speculative fixes.
Explain any reported items left unresolved.

A targeted fix verification checks the named behavior and related regressions;
it does not automatically start a general audit or another independent review.
Finish once the requested scope and checks are complete. Priority alone does
not establish a release blocker, and a scoped review does not certify a release.
