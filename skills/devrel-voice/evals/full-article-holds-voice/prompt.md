---
tags: [skill-creator]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

write the full upgrade article for queuekit 2.0 (from 1.9.3), save it as article.md. Release notes:
- `queue.add(job)` now returns the job id instead of the job object.
- `concurrency` defaults to 1 (was 10).
- `removeOnComplete` defaults to true: finished jobs are deleted, so `queue.getCompleted()` returns an empty list unless you set it to false.
- Node 18 is no longer supported, Node 20 or later is required.
