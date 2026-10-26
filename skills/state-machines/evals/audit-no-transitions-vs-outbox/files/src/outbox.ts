const RETRY_DELAY_MS = 2_000;

/** Sends queued notes in order, one at a time, and retries the head after a failure. */
export class Outbox {
  readonly #send: (note: string) => Promise<void>;
  readonly #queue: string[] = [];
  #isDraining = false;
  #retryTimer: ReturnType<typeof setTimeout> | undefined;

  constructor(send: (note: string) => Promise<void>) {
    this.#send = send;
  }

  /** Queue a note. It goes out after every note queued before it. */
  push(note: string): void {
    this.#queue.push(note);
    void this.#drain();
  }

  /** Stop retrying. Queued notes stay until the next push. */
  pause(): void {
    clearTimeout(this.#retryTimer);
    this.#retryTimer = undefined;
  }

  async #drain(): Promise<void> {
    if (this.#isDraining || this.#retryTimer !== undefined) {
      return;
    }

    this.#isDraining = true;

    try {
      while (this.#queue.length > 0) {
        await this.#send(this.#queue[0]);
        this.#queue.shift();
      }
    } catch {
      this.#retryTimer = setTimeout(() => {
        this.#retryTimer = undefined;
        void this.#drain();
      }, RETRY_DELAY_MS);
    } finally {
      this.#isDraining = false;
    }
  }
}
