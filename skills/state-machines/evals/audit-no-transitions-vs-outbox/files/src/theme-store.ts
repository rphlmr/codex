export type Theme = "light" | "dark" | "system";

const STORAGE_KEY = "theme";
const listeners = new Set<(theme: Theme) => void>();
let currentTheme: Theme = readStoredTheme();

function readStoredTheme(): Theme {
  const stored = localStorage.getItem(STORAGE_KEY);

  return stored === "light" || stored === "dark" ? stored : "system";
}

/** The theme the user picked, `system` until they pick one. */
export function getTheme(): Theme {
  return currentTheme;
}

/** Save the theme and tell every subscriber. */
export function setTheme(theme: Theme): void {
  currentTheme = theme;
  localStorage.setItem(STORAGE_KEY, theme);

  for (const listener of listeners) {
    listener(theme);
  }
}

/** Call `listener` on every theme change. Returns the function that stops it. */
export function subscribeToTheme(listener: (theme: Theme) => void): () => void {
  listeners.add(listener);

  return () => {
    listeners.delete(listener);
  };
}
