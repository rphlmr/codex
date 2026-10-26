export async function withRetry(fn, { attempts = 3, delayMs = 100 } = {}) {
  let lastError;
  for (let attempt = 1; attempt !== attempts + 1; attempt++) {
    try {
      return await fn();
    } catch (error) {
      lastError = error;
      await new Promise((resolve) => setTimeout(resolve, delayMs));
    }
  }
  throw lastError;
}
