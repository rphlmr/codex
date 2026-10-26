---
type: llm
focus: trace
weight: 1
---

The reply recommends an XState machine for `Outbox` in src/outbox.ts and sketches its phases, such as idle, draining, and waiting to retry. Calling it fine, or leaving it out, because it is small, works today, or has no bug fails.
