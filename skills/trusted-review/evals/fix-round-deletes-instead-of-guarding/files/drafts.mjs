function toDraftKey(id) {
  return `draft:${id}`;
}

/** Saves a draft as `{ id, title, text, updatedAt }`. */
export function saveDraft(storage, draft) {
  storage.setItem(toDraftKey(draft.id), JSON.stringify(draft));
}

function isBodyDraft(value) {
  return typeof value === "object" && value !== null && "body" in value && !("text" in value);
}

/** Loads a draft, or null when none is stored. */
export function loadDraft(storage, id) {
  const stored = storage.getItem(toDraftKey(id));

  if (stored === null) {
    return null;
  }

  const value = JSON.parse(stored);

  // Tolerate drafts stored with `body` instead of `text`, so a malformed draft never loses its text.
  if (isBodyDraft(value)) {
    const text = value.body.length > 0 ? value.body : "";

    return { id: value.id, title: value.title ?? "Untitled", text, updatedAt: new Date(0).toISOString() };
  }

  return value;
}
