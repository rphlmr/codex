---
name: state-machines
description: Makes explicit state machines the default design for features whose correctness depends on state transitions, states, workflows, or sequences, using XState in TypeScript and an in-house XState-style machine in SwiftUI. Use when analyzing, reviewing, planning, or building multi-step workflows, async lifecycles with retry or cancellation, connection, session, sync, or playback lifecycles, or UI with mutually exclusive modes, and when code shows boolean flag clusters, status values set from several places, events handled in the wrong state, or a machine that only mirrors status, even if the user doesn't mention state machines. Not for data loading or mutations that the framework or a data library already handles, such as React Router loaders and actions.
---

# State Machines

Explicit state machines are the default architecture for features whose
correctness depends on states, transitions, or sequences: multi-step workflows,
wizards, and ordered steps, async lifecycles with retry or cancellation,
connection, session, sync, and playback lifecycles, and UI with mutually
exclusive modes. A machine makes impossible states unrepresentable, keeps every
transition rule in one reviewable place, and lets transitions be tested without
the UI.

## When building

When implementing a new feature of this kind, model it as a machine first.
Reach for flags, status strings, or chained effects only for the cases listed
under "When to skip". For an existing flow, extend its machine when it has one;
a focused correction does not itself authorize converting the whole flow.
Use the review criteria below to decide whether a conversion is needed.

## When reviewing existing code

Read the transitions in the requested scope, including those in a class,
factory closure, hook, module, or worker. These signals can reveal an implicit
machine and help locate behavior that needs verification:

- boolean flag clusters (`isLoading`, `isError`, `isSubmitting`) that allow
  impossible combinations;
- a hand-rolled status union, or status values mutated from several places;
- transition rules spread across handlers, effects, or methods that call each
  other;
- hand-built locks and gates, such as promise tails or `withResolvers`
  waiters;
- bugs where an event arrives in the wrong state.

A machine that only mirrors status counts too. When the code decides first
and then sends the machine an event, the machine refuses nothing and the real
transitions stay implicit. Inspect the code that actually makes the decisions
before drawing a conclusion about correctness.

For a defect review, establish the reachable event sequence, violated
requirement, and concrete impact. Rank that impact using the review workflow's
evidence bar. The absence of a machine, or use of a passive one, alone does not
justify a finding, minimum severity, mandatory refactor, or release blocker.
Do not turn a fix verification into an architecture audit.

When architecture advice or a state-machine audit is explicitly requested,
recommend machines for applicable units and sketch their states, events,
guards, and effects. Distinguish an architectural recommendation from a proven
defect. Otherwise recommend a conversion only when needed for the requested
change or a supported fix, keeping the refactor within that boundary. Leave
working, out-of-scope flows and settled designs alone. The machine-first
preference for new features remains unchanged.

## When to skip

Skip a machine for units with no transitions, where every event is handled
the same way whatever happened before: a toggle, a field value, a settings
store that sets and notifies, a stateless transform. To tell, ask: can this
event arrive at a moment when it must be refused or handled differently? If
never, the unit is not a state machine, and a machine adds ceremony without
removing risk. A single request's pending and error states are not transitions
of their own: leave them to the framework, below, or to one status value where
no framework owns the request, as in a CRUD form.

Skip it for data loading and mutations that the framework or a data library
already owns, such as React Router loaders, actions, and fetchers, or a query
library the project uses. Their pending, error, and revalidation states
already model the request lifecycle, so fix flag clusters around a request by
moving it into the loader or action. When a flow around them still needs a
machine, such as a multi-step wizard, the machine drives the steps and only
declares a save actor. The component provides it with the framework's submit
(`fetcher.submit`, `useSubmit`), so the machine never knows the framework.
When the machine needs the save's outcome (its data, or success vs failure)
and the framework's submit cannot return it, the component provides a direct
call to the service instead.

## TypeScript

Use XState rather than hand-rolled reducers or other state libraries:

- Define machines with `setup()` so context, events, guards, actions, and
  actors are typed.
- Keep I/O out of the machine. Declare each actor as a placeholder that throws
  until the caller injects the real one with `.provide()`, or build the setup
  in a factory that takes typed dependencies (`setupFlowMachine(options)`).
- Name events by domain, subject, and verb in `dot.case`: `editor.file.open`,
  `beneficiary.add`, `prices.refresh`. Stately strongly encourages
  `dot.case` for XState v5 events, since it enables wildcards like
  `editor.*`
  ([What's in a name?](https://stately.ai/blog/2024-01-23-state-machines-whats-in-a-name#what-style-should-that-name-be-in)).
  Apply this convention to new machines; do not rename existing events as a
  side effect of a focused fix. State names and machine ids cannot contain
  dots; keep them camelCase. Wire protocol message types are not machine
  events and keep their own names.
- Export actor ids as constants when transitions or tests refer to them.
- Test transitions without the UI, following Stately's
  [testing](https://stately.ai/docs/testing) and
  [graph](https://stately.ai/docs/graph) docs:
  - Write example tests as arrange, act, assert: start the machine with
    `createActor`, send events, and assert with `waitFor`, `snapshot.matches`
    and the context. Mock actions with `vi.fn()` and actors with a fake
    `fromPromise`, supplied through `setup()` or `.provide()`.
  - For a machine with guards or branches, also generate paths with
    `xstate/graph` (part of `xstate`; the separate `@xstate/test` and
    `@xstate/graph` packages are deprecated). `createTestModel` refuses
    machines with `invoke` or `after`, so walk the real machine with
    `getShortestPaths` and `getAdjacencyMap` instead: one path per
    transition, replayed on a running actor whose invoked actors are fakes
    that the path settles, plus a snapshot of the transition table so a
    changed guard shows as a diff. Give payload events explicit `events`
    values, keep the serialized state to the value and the context guards
    read, and bound the walk with `limit`. Keep `createTestModel` for an
    abstract model of a UI or system that has no invokes.
  - A state entered and left through `always` in one step never shows in a
    snapshot. Test it through the inspection API, or use `after: { 0: ... }`
    so it emits one.
- In React, use `@xstate/react` and expose the actor through small selector
  hooks (`useFlowSelector`, `useActiveStep`) instead of passing snapshots
  down.

## SwiftUI

Recommend an in-house machine modeled on XState, with no third-party library:

- Model states and events as enums, with context in associated values or a
  `Context` struct.
- Keep transitions in one pure `(State, Event) -> (State, [Effect])` function
  that returns the state unchanged for events the current state does not
  handle, as XState ignores them.
- An `@Observable @MainActor` store owns the current state, applies events
  through `send(_:)`, and runs effects in `Task`s that report results back
  through `send`, so views only read state and send events.

## Approval

XState is pre-approved. Build the machine with it directly, and add it as a
dependency where the project doesn't have it yet, new projects included,
instead of asking first or leaving the machine as a sketch in a doc. In
SwiftUI, build the in-house machine directly.
