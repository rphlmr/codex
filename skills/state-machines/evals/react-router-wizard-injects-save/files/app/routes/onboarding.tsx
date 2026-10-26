import { useMachine } from "@xstate/react";

import { onboardingMachine } from "~/features/onboarding/onboarding-machine";

import type { Route } from "./+types/onboarding";

export function meta({}: Route.MetaArgs) {
  return [{ title: "Onboarding" }];
}

export default function Onboarding() {
  const [snapshot, send] = useMachine(onboardingMachine);

  if (snapshot.matches("done")) {
    return <p>Thanks, your application is in.</p>;
  }

  if (snapshot.matches("documents") || snapshot.matches("submitting")) {
    return (
      <form
        onSubmit={(event) => {
          event.preventDefault();
          const formData = new FormData(event.currentTarget);
          send({
            type: "documents.submit",
            documents: formData.getAll("documents").map(String),
          });
        }}
      >
        {snapshot.context.error && (
          <p role="alert">{snapshot.context.error}</p>
        )}
        <input name="documents" type="file" multiple />
        <button type="button" onClick={() => send({ type: "step.back" })}>
          Back
        </button>
        <button disabled={snapshot.matches("submitting")}>Submit</button>
      </form>
    );
  }

  return (
    <form
      onSubmit={(event) => {
        event.preventDefault();
        const formData = new FormData(event.currentTarget);
        send({
          type: "details.submit",
          details: {
            name: String(formData.get("name")),
            email: String(formData.get("email")),
          },
        });
      }}
    >
      {snapshot.context.error && <p role="alert">{snapshot.context.error}</p>}
      <input name="name" placeholder="Name" />
      <input name="email" type="email" placeholder="Email" />
      <button disabled={snapshot.matches("savingDraft")}>Continue</button>
    </form>
  );
}
