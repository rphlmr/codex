import { strict as assert } from "node:assert";
import { test } from "node:test";
import { slugify } from "./slugify.ts";

test("slugify", () => {
  assert.equal(slugify("Héllo, World!"), "hello-world");
  assert.equal(slugify("  --a  b--  "), "a-b");
  assert.equal(slugify("!!!"), "");
  assert.equal(slugify("Crème brûlée"), "creme-brulee");
  assert.equal(slugify("Straße"), "stra-e");
  assert.equal(slugify("東京"), "");
});
