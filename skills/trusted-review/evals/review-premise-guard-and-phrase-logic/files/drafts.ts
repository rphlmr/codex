import type { Draft } from "./types.ts";

function toDraftKey(id: string): string {
  return `draft:${id}`;
}

export function saveDraft(storage: Storage, draft: Draft): void {
  storage.setItem(toDraftKey(draft.id), JSON.stringify(draft));
}

export function loadDraft(storage: Storage, id: string): Draft | null {
  const stored = storage.getItem(toDraftKey(id));

  return stored === null ? null : (JSON.parse(stored) as Draft);
}
