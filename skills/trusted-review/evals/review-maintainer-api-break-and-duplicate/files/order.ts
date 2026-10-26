export type OrderItem = { name: string; priceCents: number; quantity: number };

export type Order = { items: OrderItem[]; totalCents: number };
