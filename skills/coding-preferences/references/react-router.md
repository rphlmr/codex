---
paths:
  - "**/react-router.config.{ts,js}"
  - "**/routes.{ts,js}"
  - "**/routes/**/*.{ts,tsx,js,jsx}"
  - "**/root.{tsx,jsx}"
---

# React Router

- A state machine that drives a save only declares a save actor, and the
  component provides it with `.provide()`. The machine never imports React
  Router.
- Implement the provided save with `fetcher.submit` when the machine only
  needs to know the save finished. `fetcher.submit` resolves to `void` once
  the action and revalidation finish, even when the action throws or is
  aborted, so the outcome reaches only `fetcher.data` and the error boundary.
  When the machine needs the outcome (its data, or success vs failure),
  implement the save with a direct call to the service instead.
