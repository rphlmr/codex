---
type: llm
focus: trace
weight: 1
---

The review recommends no XState machine, reducer, or other state machine for the form. Saying that one isn't needed is fine, and so is suggesting a single `status` value kept in `useState` (such as `idle`, `submitting`, `sent`, `error`) in place of the boolean. Recommending or sketching a machine or a reducer with events and transitions fails.
