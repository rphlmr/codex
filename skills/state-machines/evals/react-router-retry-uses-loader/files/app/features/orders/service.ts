export type Order = {
  id: string;
  reference: string;
  total: string;
};

export async function fetchOrders(signal?: AbortSignal): Promise<Order[]> {
  const response = await fetch("/api/orders", { signal });

  if (!response.ok) {
    throw new Error(`Orders request failed with ${response.status}`);
  }

  return response.json();
}
