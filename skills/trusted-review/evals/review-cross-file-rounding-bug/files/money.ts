/** Convert a decimal amount such as 19.99 to integer cents. */
export function toCents(amount: number): number {
  return Math.floor(amount * 100);
}

export function formatCents(cents: number): string {
  return (cents / 100).toFixed(2);
}
