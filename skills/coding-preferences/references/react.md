---
paths:
  - "**/*.{tsx,jsx}"
---

# React

- Derive values during render instead of synchronizing derived state.
- Do not use `useEffect` for render-derived state, internal data shaping, event
  handling, or log deduplication.
- Use `useEffect` only to synchronize with external systems such as I/O,
  subscriptions, timers, DOM APIs, iframe APIs, or browser APIs.
- Keep state as local as practical.
- Load and mutate data through the framework's data APIs when the app has
  them, such as React Router loaders, actions, and fetchers, and read pending
  and error state from `useNavigation`, `fetcher.state`, and the error
  boundary. Do not fetch in effects, client stores, or state machines there.
- Build React Router code from the reactrouter.com page that covers it
  (routing, data loading, actions, fetchers, pending UI, revalidation), not
  from memory or the router's source, and name that page when explaining a
  choice.
- Write UI text plain and short: name the concrete action in everyday words
  ("Allow AI edits?"), not an internal concept ("Trust Shared transfers?"),
  with one idea per line.
- Preserve accessibility and loading, empty, error, and disabled states.
- Match the existing component, state-management, and styling architecture.
- For visual changes, render and inspect the result when the environment
  supports it.
