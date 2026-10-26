---
tags: [skill-creator]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

onboarding-machine.ts calls the API itself, and the test hits the real API so it fails in CI. can you move the saves out of the machine the way our rules want?
Input files: package.json, app/routes.ts, app/routes/onboarding.tsx, app/features/onboarding/onboarding-machine.ts, app/features/onboarding/onboarding-machine.test.ts, app/features/onboarding/service.ts
