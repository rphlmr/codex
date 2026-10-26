---
type: llm
focus: trace
weight: 1
---

For finding 1, drafts.mjs no longer has the `body` branch (isBodyDraft and its use in loadDraft are removed), citing docs/decisions.md that no other draft format exists. Adding a null check or other guard inside the `body` branch while keeping it fails.
