---
tags: [skill-creator]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

write the blog section for this change in our upgrade guide, save it as section.md

release notes, fetchkit 3.0.0 (from 2.8.1):
- `retries` is removed from `createClient()`. Set it per request: `client.get(url, { retries: 3 })`.
- `createClient({ retries })` is now ignored at runtime in JS (TS reports it as an unknown property).
- default retries per request is 0.
