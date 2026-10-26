# Decisions

- Drafts ship for the first time in 1.0.0. Only `saveDraft` writes drafts, always as `{ id, title, text, updatedAt }`.
  No browser holds a draft from an earlier version, so nothing needs to read another draft format.
- Storage failures are shown to the person, never hidden: they decide what to do with their text.
