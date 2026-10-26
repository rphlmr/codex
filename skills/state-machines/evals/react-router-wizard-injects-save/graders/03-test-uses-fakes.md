---
type: llm
focus: trace
weight: 1
---

app/features/onboarding/onboarding-machine.test.ts provides a fake for each actor the test reaches (at least the draft save) with `.provide()` or the machine factory, so it no longer reaches the network. It still checks that a saved draft moves the machine to the documents step with the draft id from the fake.
