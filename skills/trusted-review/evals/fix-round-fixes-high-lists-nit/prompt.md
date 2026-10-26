---
tags: [skill-creator]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

the reviewer left these on retry.mjs, can you fix what needs fixing?
1. HIGH: withRetry retries forever when attempts is 0 or negative, it should throw a RangeError instead
2. NIT: rename 'fn' to 'operation'
3. LOW: maybe add jitter to the delay
Input files: retry.mjs, retry.test.mjs
