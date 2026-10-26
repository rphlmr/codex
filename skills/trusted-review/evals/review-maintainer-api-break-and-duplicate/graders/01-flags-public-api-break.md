---
type: llm
focus: trace
weight: 1
---

The review reports that buildReceipt, exported from index.ts of the published @acme/receipts package, now requires a taxCents argument, so existing buildReceipt(order) calls break (a type error, or 'Tax $NaN' and 'Total $NaN' in plain JavaScript), and ranks it high or medium, not only as a nit or an unranked suspicion.
