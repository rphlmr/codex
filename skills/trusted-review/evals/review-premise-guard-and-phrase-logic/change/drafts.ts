import type { Draft } from "./types.ts";

function toDraftKey(id: string): string {
  return `draft:${id}`;
}

export function saveDraft(storage: Storage, draft: Draft): void {
  storage.setItem(toDraftKey(draft.id), JSON.stringify(draft));
}

/** A draft whose text sits in `body`, as some stored drafts may have it. */
interface LegacyDraft {
  id: string;
  title?: string;
  body: string;
}

function isLegacyDraft(value: unknown): value is LegacyDraft {
  return typeof value === "object" && value !== null && "body" in value && !("text" in value);
}

export function loadDraft(storage: Storage, id: string): Draft | null {
  const stored = storage.getItem(toDraftKey(id));

  if (stored === null) {
    return null;
  }

  const value: unknown = JSON.parse(stored);

  // Tolerate drafts stored with `body` instead of `text`, so a malformed draft never loses its text.
  if (isLegacyDraft(value)) {
    return { id: value.id, title: value.title ?? "Untitled", text: value.body, updatedAt: new Date(0).toISOString() };
  }

  return value as Draft;
}

/** Whether leaving the page should ask first, from the toolbar's save status. */
export function shouldWarnOnLeave(status: string): boolean {
  return status !== "Saved";
}
