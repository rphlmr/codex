---
type: llm
focus: trace
weight: 1
---

The reply says that `UploadController` makes the decisions itself (the one-upload-at-a-time check, the cancel flag, picking success, failure, or cancel) and only reports them to `uploadMachine` afterwards, and recommends moving those decisions into the machine's guards and invoked actors. Calling the upload code fine because it already uses XState fails.
