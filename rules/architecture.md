---
paths:
  - "**/*.{ts,tsx,mts,cts}"
---

# Architecture

Follow the project's existing structure. These principles shape new code.

- Group code by feature, not by technical kind such as `types/` or
  `services/`.
- Put a feature's types, schemas, and inputs in `contract.ts`, and its I/O in
  `service.ts`. Other features depend on the contract, not on the service.
- Pass a service everything it uses (API client, URLs) through its factory's
  dependencies object. Don't import singletons or read global configuration
  inside a service.
- Wire dependencies once at the composition root, such as the app entry or a
  provider, and hand services to the orchestrating code, such as state
  machine actors.
- Point dependencies one way: entry and orchestration, then features, then
  API clients and utilities. When a lower layer needs a type from a higher
  one, move the type down.
- Keep the pure core (evaluation, rules, schemas) free of framework and I/O
  imports. Reach the host through a ports type of injected functions, such as
  `getLanguage`.
- Accept an `AbortSignal` in service functions that do I/O, and pass it on.
- Keep test helpers, fakes, and fixture data in a `test/` folder at the
  package root that mirrors the `src` path, never in `src/`, where they read
  like package API. Test files stay next to the code they test, and build
  configs leave `test/` out of the output.
