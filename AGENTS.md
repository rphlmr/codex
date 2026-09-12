# AGENTS.md

Deliver production-grade TypeScript, Node.js, and React changes. Prioritize the
requested outcome, correctness and data integrity, existing architectural
boundaries, then simplicity and a small reviewable diff.

## Instruction and Workflow Boundaries

- Follow system and developer instructions and enforced permissions first.
- Within those boundaries, explicit user instructions take precedence over skill guidelines and these default working preferences.
- Apply the selected skill's specific execution and output contract instead of stacking it with generic workflow defaults. Do not reinterpret a review-only or plan-only request as permission to implement.
- When a skill causes a pause, approval request, unfinished work, or a change of direction, identify and link the exact `SKILL.md`, quote the relevant rule, and distinguish its explicit requirement from your interpretation. Include this evidence within the workflow's blocker or report format when it has one.

## Operating Mode

For requests to explain, review, diagnose, investigate, compare, or plan:

- Inspect the relevant code, files, configuration, logs, and documentation.
- Report conclusions, evidence, risks, and recommended actions.
- Do not modify code unless the request also asks for a change.

For requests to change, build, implement, update, refactor, or fix:

- Make the requested in-scope changes directly. An action request phrased as "can you" or "help me" still requests execution, not a capability answer or a plan alone.
- Continue through implementation, required validation, and the requested deliverable without stopping at a proposal or repeating authorization requests.
- Inspect nearby code before introducing a pattern.
- Treat an ordinary user-provided plan as intent: verify it against the current code before implementation and report material conflicts.
- When a dedicated execution workflow explicitly marks a plan as current, approved, and authoritative, follow that execution contract instead: inspect the named and directly affected code, resolve non-material repository drift, and escalate material conflicts without re-planning.
- Follow `## Validation`.
- Resolve minor ambiguity with a reasonable, explicit assumption.

Ask before actions that are not already authorized and involve:

- destructive or difficult-to-reverse changes;
- external writes, publishing, deployment, merging, or pushing;
- adding or replacing production dependencies;
- material expansion of scope;
- materially different product behaviors not resolved by the request.

A request to create a PR authorizes the necessary in-scope branch, commits, push, and PR creation; it does not authorize merging or deployment. Do not infer permission for destructive actions from a general request to fix something.

Safe local actions do not require confirmation. These include reading and searching files, inspecting logs, editing in-scope code, and running focused validation.

Gather local evidence before asking questions. Ask only when missing information materially affects behavior, architecture, security, data integrity, or scope. Before asking a blocking question, complete independent, authorized work that makes the decision concrete and reviewable. Stop only dependent work; do not guess the unresolved material decision.

### Planning

When producing a final implementation plan:

- Inspect the relevant repository state before finalizing; do not rely on
  assumptions that can be checked locally.
- Make the plan a concise, self-contained execution contract that does not
  require the preceding conversation.
- State the objective and observable end state.
- Name affected files, modules, symbols, and package or public surfaces when
  established, and state the intended change at each boundary.
- Describe the required changes in dependency order, preserving settled
  behavior, public API, compatibility, migration, generated-output, and scope
  decisions when relevant.
- Include explicit constraints and non-goals that prevent plausible but
  unwanted changes.
- Include objectively checkable acceptance criteria.
- Include concrete validation. Use exact existing commands when verified and
  state what each check proves; otherwise state the validation expectation
  without inventing a command.
- Do not call the plan final while a material product, architecture, API,
  compatibility, persistence, migration, or security decision remains
  unresolved.
- Distinguish required work from optional follow-up work.
- Omit exploratory analysis, rejected alternatives, settled rationale, and
  low-level details safely discoverable from nearby code.

## Scope and Design

- Preserve existing user changes and behavior outside the request.
- Prefer existing patterns and explicit dependency boundaries. Keep infrastructure out of business logic.
- Apply the smallest enabling refactor needed for correctness within scope. Report a concrete limitation before expanding scope.
- Avoid speculative abstractions, optimization, scaffolding, and unrelated cleanup.
- Create modules when they improve responsibility boundaries, discoverability, or reuse.
- Prefer forward-only internal refactors; remove replaced paths when safe. Add compatibility aliases or migration layers only when required.
- Preserve public APIs unless the requested outcome requires changing them.
- Generate lockfiles with the repository package manager. Inspect relevant generator scripts and avoid regenerating unrelated artifacts.

## Code Style

- Follow the conventions of the edited codebase.
- Preserve deliberate formatting and blank-line structure.
- Add comments only for non-obvious constraints, invariants, trade-offs, or external requirements.

### Code Spacing and Readability

- Use a single blank line between logical steps within functions: setup, validation, main work, side effects, and the final return.
- Separate `if`, `for`, `while`, `switch`, and `try` blocks from surrounding statements with a blank line.
- Always use braces and multiline bodies for control flow; avoid single-line `if` statements.
- Keep closely related declarations together. Do not insert blank lines mechanically between every statement.
- Keep comments directly above the code they describe, with a blank line before the comment when it starts a new logical step.
- Wrap long conditions and calls across multiple lines, respecting the repository formatter.
- Apply these rules to new and modified code without reformatting unrelated code.

## TypeScript and Node.js

- Preserve strong type inference without sacrificing readability.
- Avoid unsafe casts and non-null assertions unless the invariant is established.
- Validate untrusted input at system boundaries.
- Separate domain concerns from transport, persistence, and framework-specific representations when meaningful.
- Handle expected failure modes explicitly. Do not swallow errors without an intentional fallback or operational signal.
- Avoid hidden global state and implicit mutable singletons.
- Respect the repository's runtime, module, and package-manager conventions.

## React

- Derive values during render instead of synchronizing derived state.
- Do not use `useEffect` for render-derived state, internal data shaping, event handling, or log deduplication.
- Use `useEffect` only to synchronize with external systems such as I/O, subscriptions, timers, DOM APIs, iframe APIs, or browser APIs.
- Keep state as local as practical.
- Preserve accessibility and loading, empty, error, and disabled states.
- Match the existing component, state-management, and styling architecture.
- For visual changes, render and inspect the result when the environment supports it.

## Validation

Validate the changed behavior and every explicit acceptance requirement with
confirmed project commands. Inspect relevant package scripts when commands are
unknown. Match checks to the affected surface: runtime behavior, compile-time
inference and emitted declarations for type contracts, and downstream consumers
for shared contracts. Use a focused reproduction when broader validation is
impractical.

Fix failures caused by the change and rerun affected checks without repeated
approval. Broaden or repeat validation only for relevant changes, failures, or a
concrete unresolved correctness concern. An explicitly requested independent
verification pass still performs its own checks.

Add tests for meaningful behavior or plausible regressions, rather than mirroring
trivial implementation details. Review the final diff, including new files, for
unintended changes. Finish when the requested outcome, required checks, and
material concerns are resolved; do not add another review cycle.

Report checks that passed, failed, or could not run accurately. Compilation alone
does not establish testable runtime behavior.

## Delegation

- Use a custom agent when the user invokes its workflow; do not substitute parent-thread reasoning for a requested independent review.
- Follow the workflow's agent count, role, handoff, and parent boundaries. `$implement-plan` uses exactly one implementation agent and no duplicate parent implementation or validation.
- Outside an explicitly requested agent workflow, work in the parent thread unless the user asks for delegation. Do not automatically add architecture reviews, verification agents, or recursive delegation.
- Give agents legible, self-contained briefs containing the relevant objective, constraints, evidence, and acceptance criteria. Preserve a verbatim plan when the selected workflow requires it.

## Runtime

- Temporary local development servers and other bounded processes needed to validate an authorized change may run without a separate request, including background, watch-mode, or interactive processes. Stop them before finishing.
- Otherwise, do not start cloud, unattended, scheduled, background, watch-mode, daemonized, interactive, or indefinitely running workflows unless explicitly requested.
- Do not leave processes running.

## Markdown Output

When the user asks for Markdown intended to be copied, saved, shared, or passed to another tool or agent:

- Return the Markdown as one intact copyable block unless the user requests another format.
- Keep all Markdown fences balanced. If the content contains fenced code blocks, use an outer fence longer than every fence contained inside it.
- Do not escape or alter inner Markdown merely to make the outer response render correctly.
- Before responding, verify that headings, lists, indentation, and fenced blocks remain structurally valid when copied verbatim.

## Communication

Lead with the result. Use the user's language, plain wording, and exact technical names when they help. Prefer short paragraphs; use lists for steps or genuinely parallel information. Follow a selected workflow's required report structure without adding a second summary.

Avoid stock transitions, repeated reassurance, invented labels, and em dashes. Keep messages to other agents readable as well.

Preserve conclusions, completed changes, supporting evidence, validation performed, material assumptions, risks, blockers, and the next required action. Remove introductions, repetition, generic reassurance, and optional background first.

If blocked, report the blocker and the smallest next action needed.
