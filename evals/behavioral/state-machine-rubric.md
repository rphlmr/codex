# State-machine comparison rubric

Use the same prompts, fixtures, model, effort, runner, and rubric for both skill
versions. Freeze these criteria before running either version. Automated text
matches are smoke checks, not evidence of complete or correct reasoning.

Score each item pass or fail with an answer excerpt or specific omission. Do
not award points for terminology alone. Record any rubric corrections and
retain the original results. One sample per case cannot establish reliability
or a statistically meaningful improvement.

## state-cancellable-export-plan

1. Defines states, events, guards, and effects sufficient to cover selection,
   start, success, failure, cancellation, and retry. Empty start, selection
   changes during export, and another start during export are refused.
2. Makes transition rules authoritative. Callers dispatch events; they do not
   independently choose success, failure, or cancellation and mirror that
   choice into a status value.
3. Correlates success and failure with the active operation ID, including
   after cancel followed by immediate restart. An obsolete callback cannot
   change the new operation's state or trigger a download or error.
4. Enumerates allowed and refused transitions in a concrete table, exhaustive
   state/event list, or equivalent pseudocode. Refused events leave state
   unchanged and perform no forbidden effects; cancellation may explicitly
   issue its authorized cancellation effect.
5. Gives concrete validation sequences for duplicate start, cancel then late
   completion, and cancel then restart then obsolete success or failure.
   Tests assert effects as well as resulting states. Active success downloads
   once, and failure followed by retry uses a fresh operation ID.

## state-explicit-switch

1. Identifies the existing implementation as explicit and ties that conclusion
   to the enumerable state/event decisions in transitionApproval.
2. Explains that createApprovalController owns the state and runs only effects
   returned by the transition function; the machine is authoritative rather
   than a status mirror.
3. States that a library conversion is not required to meet the existing
   contract. A separately labeled architectural preference is acceptable;
   absence of XState alone is not a defect or blocker.
4. Gives concrete sequences covering empty submit, edit/submit while pending,
   reject then edit/resubmit, and repeated accept after approval. Refused
   events preserve state and emit no effects; publication is queued once.
5. Invents no contract violation and makes no source changes. Does not claim
   that code inspection proves runtime validation passed.

## Existing guardrails

- state-simple-request: handle send rejection and expose an error, without
  recommending a separate machine for the single-request form.
- state-outbox: recommend an explicit machine for the outbox's ordered send
  and retry lifecycle, skip the theme store, and distinguish architecture
  advice from a demonstrated defect.

For every case, separately verify the requested model and effort, successful
process completion, and unchanged fixture files, HEAD, and index from the
runner's recorded checks.
