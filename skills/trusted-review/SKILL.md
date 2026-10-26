---
name: trusted-review
description: Makes code reviews, audits, and review-fix rounds trustworthy, with proven findings ranked by impact, a maintainer's read of fit and public contracts, a verification pass, and fixes limited to what matters. Use when reviewing a diff, branch, PR, or feature, when auditing code, when acting on review findings or reports, or when planning a review or fix round.
---

# Trusted Review

A review exists so the user can trust its result. Report fewer, proven
findings over many plausible ones.

## Independent review

Use Codex's bundled `review-agent` skill as the base review procedure. Resolve
its absolute path from `$CODEX_HOME/skills/.system/review-agent/SKILL.md`, or
`~/.codex/skills/.system/review-agent/SKILL.md` when `CODEX_HOME` is unset.
Confirm it exists before spawning. Do not copy or maintain its procedure here.
If it is unavailable, report that dependency as blocked rather than silently
substituting another review process.

For a review or audit, the parent spawns exactly one fresh built-in agent with
`fork_turns: "none"`. Do not reuse the implementation agent or an earlier
reviewer. A review after fixes gets a new agent too.

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

The parent waits without performing a competing review or changing the code.
The reviewer owns inspection, proof, ranking, and targeted checks, and changes
no files or Git state. It must not delegate further.

Return the reviewer's report without adding, deleting, or rewriting findings
or strengthening its confidence. If the agent is unavailable, report that the
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
- Otherwise, fix highs and mediums, and list lows and nits for the user to
  pick.
- Give each fix a test that fails before it and passes after.
- Prefer the smallest fix, or a visible limitation, over a new mechanism.
  Ask before adding one (a retry, a fallback, a watchdog, a cache, a state).
- Fix code added by the previous round with the same care: new code is where
  the next findings come from.
- Before fixing a finding, check whether it exists only because a premise was
  ignored. Then the fix deletes code instead of guarding it.
- For each fix that adds code, name the smaller option you rejected.

## Close the round

- After a fix round, run the full test suite, e2e, and gates once, and
  report the real output. A review alone runs only what proves its findings.
- Do not start another review round on your own. When the user asks for
  one after a fix round, review the whole flow once, not each finding again.
