import { formatCents, toCents } from "./money.ts";

export type Line = { unitPrice: number; quantity: number };

const TAX_RATE_PERCENT = 20;

export function getInvoiceTotal(lines: Line[]): string {
  let subtotalCents = 0;
  for (const line of lines) {
    subtotalCents += toCents(line.unitPrice) * line.quantity;
  }
  const taxCents = Math.round((subtotalCents * TAX_RATE_PERCENT) / 100);
  return formatCents(subtotalCents + taxCents);
}
