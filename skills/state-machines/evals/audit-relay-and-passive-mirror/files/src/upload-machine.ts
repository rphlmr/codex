import { assign, setup } from "xstate";

interface UploadContext {
  progress: number;
  error?: string;
}

type UploadEvent =
  | { type: "upload.start" }
  | { type: "upload.progress"; progress: number }
  | { type: "upload.succeed" }
  | { type: "upload.fail"; error: string }
  | { type: "upload.cancel" };

/** Upload status that `UploadController` reports to its subscribers. */
export const uploadMachine = setup({
  types: {
    context: {} as UploadContext,
    events: {} as UploadEvent,
  },
}).createMachine({
  id: "upload",
  initial: "idle",
  context: { progress: 0 },
  states: {
    idle: {
      on: { "upload.start": "uploading" },
    },
    uploading: {
      entry: assign({ progress: 0, error: undefined }),
      on: {
        "upload.progress": {
          actions: assign({ progress: ({ event }) => event.progress }),
        },
        "upload.succeed": "succeeded",
        "upload.fail": {
          target: "failed",
          actions: assign({ error: ({ event }) => event.error }),
        },
        "upload.cancel": "cancelled",
      },
    },
    succeeded: {
      on: { "upload.start": "uploading" },
    },
    failed: {
      on: { "upload.start": "uploading" },
    },
    cancelled: {
      on: { "upload.start": "uploading" },
    },
  },
});
