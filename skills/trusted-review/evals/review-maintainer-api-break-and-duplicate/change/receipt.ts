import type { Order } from "./order";

function toMoney(cents: number): string {
  return "$" + (cents / 100).toFixed(2);
}

export function buildReceipt(order: Order, taxCents: number): string {
  const lines = order.items.map(
    (item) => `${item.name} x${item.quantity}  ${toMoney(item.priceCents * item.quantity)}`,
  );
  lines.push(`Tax  ${toMoney(taxCents)}`);
  lines.push(`Total  ${toMoney(order.totalCents + taxCents)}`);
  return lines.join("\n");
}
