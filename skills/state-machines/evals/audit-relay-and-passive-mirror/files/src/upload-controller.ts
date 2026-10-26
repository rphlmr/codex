import { createActor, type SnapshotFrom } from "xstate";

import { uploadMachine } from "./upload-machine";

export type UploadFile = (
  file: Blob,
  options: { signal: AbortSignal; onProgress: (progress: number) => void },
) => Promise<void>;

/**
 * Upload controller
 *
 * Runs one upload at a time. `start` is ignored while an upload runs, and `cancel` is ignored when none does.
 */
export class UploadController {
  readonly #upload: UploadFile;
  readonly #actor = createActor(uploadMachine).start();
  #abort: AbortController | undefined;
  #isCancelRequested = false;

  constructor(upload: UploadFile) {
    this.#upload = upload;
  }

  get snapshot(): SnapshotFrom<typeof uploadMachine> {
    return this.#actor.getSnapshot();
  }

  subscribe(listener: (snapshot: SnapshotFrom<typeof uploadMachine>) => void): () => void {
    const subscription = this.#actor.subscribe(listener);
    return () => subscription.unsubscribe();
  }

  async start(file: Blob): Promise<void> {
    if (this.#abort !== undefined) {
      return;
    }

    const abort = new AbortController();
    this.#abort = abort;
    this.#isCancelRequested = false;
    this.#actor.send({ type: "upload.start" });

    try {
      await this.#upload(file, {
        signal: abort.signal,
        onProgress: (progress) => this.#actor.send({ type: "upload.progress", progress }),
      });
      this.#actor.send({ type: "upload.succeed" });
    } catch (cause) {
      if (this.#isCancelRequested) {
        this.#actor.send({ type: "upload.cancel" });
      } else {
        const error = cause instanceof Error ? cause.message : String(cause);
        this.#actor.send({ type: "upload.fail", error });
      }
    } finally {
      this.#abort = undefined;
    }
  }

  cancel(): void {
    if (this.#abort === undefined) {
      return;
    }

    this.#isCancelRequested = true;
    this.#abort.abort();
  }
}
