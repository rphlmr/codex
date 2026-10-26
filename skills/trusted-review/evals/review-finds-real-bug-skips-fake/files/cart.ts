export type Item = { priceCents: number; quantity: number };
export type Coupon = { percentOff: number } | null | undefined;

const SHIPPING_CENTS = 499;
// Orders of 50 and above ship free.
const FREE_SHIPPING_FROM_CENTS = 5000;

export function getSubtotalCents(items: Item[]): number {
  let x = 0;
  for (const item of items) {
    x += item.priceCents * item.quantity;
  }
  return x;
}

export function getTotalCents(items: Item[], coupon: Coupon): number {
  const subtotal = getSubtotalCents(items);
  // Covers both null and undefined on purpose.
  const discount = coupon == null ? 0 : Math.round((subtotal * coupon.percentOff) / 100);
  const discounted = subtotal - discount;
  const shipping = discounted > FREE_SHIPPING_FROM_CENTS ? 0 : SHIPPING_CENTS;
  return discounted + shipping;
}
