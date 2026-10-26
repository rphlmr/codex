import { createActor, waitFor } from "xstate";
import { describe, expect, it } from "vitest";

import { onboardingMachine } from "./onboarding-machine";

describe("onboardingMachine", () => {
  it("moves to documents once the draft is saved", async () => {
    const actor = createActor(onboardingMachine).start();

    actor.send({
      type: "details.submit",
      details: { name: "Ada", email: "ada@example.com" },
    });

    const snapshot = await waitFor(actor, (state) =>
      state.matches("documents"),
    );
    expect(snapshot.context.draftId).not.toBe("");
  });
});
