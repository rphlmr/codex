---
name: session-handoff
description: Create a continuation prompt that transfers established work to a fresh Codex session, including another repository.
---

# Session Handoff

Write one self-contained continuation prompt addressed to a fresh Codex session
with no access to this conversation. Infer the relevant target work; a handoff
request transfers existing authorization and does not itself authorize edits or
external actions.

Include established information that affects the receiving session's decisions:

- objective, observable outcome, deliverable, and permitted operating mode;
- relevant source or consumer behavior explaining the requirement;
- completed and remaining work, affected repositories, files, and symbols;
- settled contracts, exact APIs, signatures, examples, failures, and constraints;
- validation performed, with exact commands, results, and unverified checks;
- acceptance criteria, blockers, material risks, dependencies, and next action.

Keep concrete technical details when they affect correctness. Distinguish facts,
requirements, and assumptions. Remove superseded decisions, unrelated history,
repeated rationale, and rejected directions that no longer constrain the work.

For another repository, separate consumer requirements from implementation
assumptions. Include target architecture, paths, APIs, or commands only when
established, preserving uncertainty. State any target investigation or planning
still required; do not invent its implementation.

The receiving session follows its own active instructions and inspects its
repository before making local decisions. Transfer source workflow rules only
when they are part of the actual requirement.

Output only the copyable prompt, structured to suit the task. Preserve everything
needed to continue correctly without expanding scope or continuing planning here.
