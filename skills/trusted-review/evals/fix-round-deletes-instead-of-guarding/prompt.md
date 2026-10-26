---
tags: [skill-creator]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

the reviewer left these on drafts.mjs, can you fix them?
1. MEDIUM: loadDraft throws when a stored draft has `body: null` (reads `.length` of null). guard it.
2. MEDIUM: saveDraft loses the draft when localStorage.setItem throws (quota exceeded). add a retry with backoff.
Input files: docs/decisions.md, drafts.mjs, drafts.test.mjs
