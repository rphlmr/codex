import assert from "node:assert/strict";
import { test } from "node:test";

import { loadDraft, saveDraft } from "./drafts.mjs";

function createMemoryStorage() {
  const items = new Map();

  return {
    getItem: (key) => items.get(key) ?? null,
    setItem: (key, value) => items.set(key, value),
  };
}

test("should load the draft it saved", () => {
  const storage = createMemoryStorage();
  const draft = { id: "a", title: "Hello", text: "World", updatedAt: "2026-01-01T00:00:00.000Z" };

  saveDraft(storage, draft);

  assert.deepEqual(loadDraft(storage, "a"), draft);
});

test("should return null when no draft is stored", () => {
  assert.equal(loadDraft(createMemoryStorage(), "missing"), null);
});
