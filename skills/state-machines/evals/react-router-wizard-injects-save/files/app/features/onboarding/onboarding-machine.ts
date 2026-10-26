import { assign, fromPromise, setup } from "xstate";

import {
  createDraft,
  submitApplication,
  type ApplicantDetails,
} from "./service";

type OnboardingContext = {
  details: ApplicantDetails;
  draftId: string;
  documents: string[];
  error: string;
};

type OnboardingEvent =
  | { type: "details.submit"; details: ApplicantDetails }
  | { type: "documents.submit"; documents: string[] }
  | { type: "step.back" };

export const onboardingMachine = setup({
  types: {
    context: {} as OnboardingContext,
    events: {} as OnboardingEvent,
  },
  actors: {
    saveDraft: fromPromise(({ input }: { input: ApplicantDetails }) =>
      createDraft(input),
    ),
    submitApplication: fromPromise(
      ({ input }: { input: { draftId: string; documents: string[] } }) =>
        submitApplication(input.draftId, input.documents),
    ),
  },
}).createMachine({
  id: "onboarding",
  initial: "details",
  context: {
    details: { name: "", email: "" },
    draftId: "",
    documents: [],
    error: "",
  },
  states: {
    details: {
      on: {
        "details.submit": {
          target: "savingDraft",
          actions: assign({
            details: ({ event }) => event.details,
            error: "",
          }),
        },
      },
    },
    savingDraft: {
      invoke: {
        src: "saveDraft",
        input: ({ context }) => context.details,
        onDone: {
          target: "documents",
          actions: assign({ draftId: ({ event }) => event.output.id }),
        },
        onError: {
          target: "details",
          actions: assign({ error: "Could not save your details." }),
        },
      },
    },
    documents: {
      on: {
        "documents.submit": {
          target: "submitting",
          actions: assign({
            documents: ({ event }) => event.documents,
            error: "",
          }),
        },
        "step.back": "details",
      },
    },
    submitting: {
      invoke: {
        src: "submitApplication",
        input: ({ context }) => ({
          draftId: context.draftId,
          documents: context.documents,
        }),
        onDone: "done",
        onError: {
          target: "documents",
          actions: assign({ error: "Could not submit your application." }),
        },
      },
    },
    done: {
      type: "final",
    },
  },
});
