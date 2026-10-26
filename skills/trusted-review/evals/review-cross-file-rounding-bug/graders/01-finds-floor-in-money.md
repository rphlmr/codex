---
type: llm
focus: trace
weight: 1
---

The review identifies that toCents in money.ts uses Math.floor on a floating-point product, so a price such as 19.99 becomes 1998 cents instead of 1999.
