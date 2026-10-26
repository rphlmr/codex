---
type: llm
focus: trace
weight: 1
---

No state machine is recommended for the theme store in src/theme-store.ts, and the reply says why: it has no transitions, because every `setTheme` is handled the same way whatever happened before. Recommending a machine or a reducer for it fails, and so does treating its subscribers or its stored value as phases.
