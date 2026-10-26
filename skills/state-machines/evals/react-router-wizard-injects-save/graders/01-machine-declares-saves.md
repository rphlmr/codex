---
type: llm
focus: trace
weight: 1
---

After the change, app/features/onboarding/onboarding-machine.ts imports nothing from `react-router` and nothing from the onboarding service, and calls no `fetch`. Its draft save and submit actors are declared as placeholders that the caller replaces with `.provide()`, or the machine is built by a factory that takes them as dependencies. A machine that still calls the service or React Router itself fails.
