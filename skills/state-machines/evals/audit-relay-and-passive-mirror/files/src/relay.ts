export interface RelayOptions {
  url: string;
  onMessage: (data: string) => void;
  createSocket?: (url: string) => WebSocket;
}

const BASE_DELAY_MS = 500;
const MAX_DELAY_MS = 30_000;

/**
 * Relay connection
 *
 * Keeps one WebSocket to the relay open and reconnects with exponential backoff until `close` is called.
 */
export class RelayClient {
  readonly #options: RelayOptions;
  #socket: WebSocket | undefined;
  #attempt = 0;
  #retryTimer: ReturnType<typeof setTimeout> | undefined;
  #closed = false;

  constructor(options: RelayOptions) {
    this.#options = options;
  }

  start(): void {
    if (this.#closed || this.#socket !== undefined || this.#retryTimer !== undefined) {
      return;
    }

    this.#connect();
  }

  send(data: string): boolean {
    if (this.#socket?.readyState !== WebSocket.OPEN) {
      return false;
    }

    this.#socket.send(data);
    return true;
  }

  close(): void {
    this.#closed = true;
    clearTimeout(this.#retryTimer);
    this.#retryTimer = undefined;
    this.#socket?.close();
    this.#socket = undefined;
  }

  #connect(): void {
    const createSocket = this.#options.createSocket ?? ((url: string) => new WebSocket(url));
    const socket = createSocket(this.#options.url);
    this.#socket = socket;

    socket.addEventListener("open", () => {
      this.#attempt = 0;
    });
    socket.addEventListener("message", (event) => {
      this.#options.onMessage(String(event.data));
    });
    socket.addEventListener("close", () => {
      if (this.#socket !== socket) {
        return;
      }

      this.#socket = undefined;

      if (!this.#closed) {
        this.#scheduleRetry();
      }
    });
  }

  #scheduleRetry(): void {
    const delay = Math.min(MAX_DELAY_MS, BASE_DELAY_MS * 2 ** this.#attempt);
    this.#attempt += 1;
    this.#retryTimer = setTimeout(() => {
      this.#retryTimer = undefined;

      if (!this.#closed) {
        this.#connect();
      }
    }, delay);
  }
}
