---
type: llm
focus: trace
weight: 1
---

app/routes/onboarding.tsx provides the machine's draft save and submit with direct calls to `createDraft` and `submitApplication`, through `.provide()` or the machine factory. Neither goes through `fetcher.submit`, `useSubmit`, a `<Form>`, or a route `action`, because the machine needs the draft id and whether each call failed, which a fetcher cannot return. Moving either call into a route action or a fetcher fails.
