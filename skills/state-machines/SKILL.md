---
name: state-machines
description: Design explicit state machines or identify implicit state transitions in existing workflows, including scattered decisions and passive status mirrors. Invoke explicitly.
---

# State Machines

When this skill is invoked, prefer explicit state-machine design for flows
that must accept or reject events differently depending on their current state.
For a new stateful feature, model the machine before wiring handlers or effects.
Keep invalid combinations unrepresentable and transition decisions in one place.

## Find implicit machines

Inspect the actual decision points in classes, closures, hooks, workers, and
services, including flows that never call themselves state machines. Look for:

- boolean clusters that allow contradictory combinations;
- status values assigned from multiple handlers or effects;
- ordered steps, connection/session lifecycles, retries, or cancellation;
- hand-built gates, locks, promise queues, or completion waiters;
- events whose meaning or validity changes with the current state;
- a machine that receives events only after callers have already decided
  the transition, so it mirrors status without enforcing the rules.

For an on-demand architecture assessment, identify concrete candidate flows
and sketch their current states, events, guards, and effects. Explain what an
explicit model would clarify or prevent, and which simple units should stay
as they are. Distinguish a design recommendation from a demonstrated defect.
An assessment does not authorize converting the code unless changes are requested.

## Model the flow

Enumerate the relevant states, events, allowed transitions, guards, and effects.
State the invariants and how unhandled events behave.
Callers send events; the model decides transitions and effects. A machine that
only mirrors decisions made elsewhere does not enforce the flow's rules.

For cancellable or restartable operations, define how late completions are
associated with their originating operation. Verify that a stale result cannot
complete or alter a newer operation.

Test meaningful state/event sequences without the UI, including rejected
events and plausible races. Verify both the next state and allowed effects.

## Fit the repository

Extend an existing machine where available. A reducer, switch, or transition
table can be authoritative without a library. For TypeScript projects already
using XState, prefer typed `setup()`, injected actors, and small selector hooks.
Keep I/O dependencies outside the pure transition rules.

Use the repository's event and state naming. Do not rename existing events or
convert an entire working flow as a side effect of a focused fix.
Adding a production dependency still requires the user's authorization.

For SwiftUI, states and events can be enums, with a pure transition function
returning the next state and effects. A store executes effects and sends their
results back as events. Prefer the project's existing ownership patterns.

## When a separate machine is unnecessary

Simple values, toggles, stateless transforms, and ordinary single-request forms
usually do not need another transition model. Leave request pending/error/
revalidation lifecycles to the framework or query library that already owns
them. A wizard around those requests may still need its own step model.

## Assessment boundaries

Missing or passive machines are investigation signals, not proof of defects.
For a defect review, establish a reachable sequence, violated requirement,
and concrete impact. Recommend conversion only when necessary for the requested
change or when architecture advice was explicitly requested.
Leave working out-of-scope flows and settled decisions alone.
