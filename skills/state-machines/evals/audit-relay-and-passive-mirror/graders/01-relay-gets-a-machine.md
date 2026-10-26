---
type: llm
focus: trace
weight: 1
---

The reply recommends an XState machine for `RelayClient` in src/relay.ts and sketches its phases, such as connecting, open, retrying (backoff), and closed. Calling it fine, or leaving it out, because it is small, works today, or has no bug fails.
