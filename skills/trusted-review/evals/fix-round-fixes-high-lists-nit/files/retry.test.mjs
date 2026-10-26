import { strict as assert } from "node:assert";
import { test } from "node:test";
import { withRetry } from "./retry.mjs";

test("returns the first success", async () => {
  let calls = 0;
  const result = await withRetry(async () => {
    calls++;
    if (calls < 2) throw new Error("boom");
    return "ok";
  }, { delayMs: 1 });
  assert.equal(result, "ok");
  assert.equal(calls, 2);
});
