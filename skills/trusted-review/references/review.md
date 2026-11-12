# Review checks

Read the affected flow against the user's requirements and repository contracts.
For a diff, identify defects introduced by the change. For an explicitly
requested feature or codebase audit, assess the named scope as it stands.

Consider public APIs, stored data, callers, error behavior, tests, and docs.
Check repository fit and unnecessary complexity when they have concrete impact.
A missing state machine, duplicated helper, naming preference, or simpler
alternative alone is not a defect or release blocker.

For each finding:
- Establish a reachable trigger, violated contract, and user or data impact.
- Link the smallest useful source location and supporting evidence.
- Attempt to disprove material findings against current code before reporting.
- Recommend the smallest correction and an appropriate regression check.

Keep unsupported suspicions out of actionable findings. Mention an unresolved
question only when it materially affects acceptance, with the exact missing
evidence. Distinguish source inspection from reproduced runtime behavior.
Omit harmless nits unless requested. Never invent findings to fill a report.

Use the bundled finding format when the bundled reviewer is used. Otherwise
choose a concise format suited to the scope. Report all supported findings,
actual checks, and material limits without imposing a separate artifact,
findings table, or fixed set of sections.
