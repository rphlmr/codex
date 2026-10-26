const UNITS = ["B", "KB", "MB", "GB"];

/** Format a byte count for display, such as `1.5 MB`. */
export function formatBytes(bytes: number): string {
  let value = bytes;
  let unitIndex = 0;

  while (value >= 1024 && unitIndex < UNITS.length - 1) {
    value /= 1024;
    unitIndex += 1;
  }

  return `${value.toFixed(unitIndex === 0 ? 0 : 1)} ${UNITS[unitIndex]}`;
}
