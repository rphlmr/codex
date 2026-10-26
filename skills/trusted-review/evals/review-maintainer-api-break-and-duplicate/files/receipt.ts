import { formatCents } from "./money";
import type { Order } from "./order";

export function buildReceipt(order: Order): string {
  const lines = order.items.map(
    (item) => `${item.name} x${item.quantity}  ${formatCents(item.priceCents * item.quantity)}`,
  );
  lines.push(`Total  ${formatCents(order.totalCents)}`);
  return lines.join("\n");
}
