# Approval contract

- A draft can be edited and submitted when its text is nonempty.
- Submitting enters pending and requests one review.
- Pending drafts cannot be edited or submitted again.
- Accepting a pending draft enters approved and queues publication once.
- Rejecting a pending draft returns to draft with the same text.
- Approved is terminal. Every event is ignored there.
- Every event not accepted by the current phase leaves state unchanged and
  produces no effects.
- All callers use the controller's send method. No caller holds a mutable
  reference to its internal state, and no other code requests review or queues
  publication.

The JavaScript module is intentional. This task is about the existing design,
with no TypeScript migration or dependency change requested.
