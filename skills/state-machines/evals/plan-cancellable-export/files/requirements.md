# Export flow

The user selects records, starts an export, and receives a download when the
export service finishes. This is a new feature; no implementation exists yet.

- Selection can change while idle and after an export succeeds or fails.
- Starting an export captures the selected records and assigns an operation ID.
  Empty selections cannot start an export.
- While exporting, another start and selection changes are refused.
- Cancel immediately leaves the exporting phase and requests cancellation of
  that operation. A new export may start immediately after cancellation.
- Cancellation is best effort. Success or failure callbacks may still arrive
  for an operation that was cancelled, including while a newer one is running.
- Only success for the currently active operation may trigger a download.
- A failure for the active operation shows an error. The user may then change
  the selection or retry. Retry starts a new operation with a new ID.
- There is no automatic retry, persistence, or background resumption.
