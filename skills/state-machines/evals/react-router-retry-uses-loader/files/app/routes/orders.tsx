import { useEffect, useState } from "react";

import { fetchOrders, type Order } from "~/features/orders/service";

import type { Route } from "./+types/orders";

export function meta({}: Route.MetaArgs) {
  return [{ title: "Orders" }];
}

export default function Orders() {
  const [orders, setOrders] = useState<Order[]>([]);
  const [isLoading, setIsLoading] = useState(true);
  const [isError, setIsError] = useState(false);
  const [retryCount, setRetryCount] = useState(0);

  useEffect(() => {
    setIsLoading(true);

    fetchOrders()
      .then((result) => {
        setOrders(result);
        setIsLoading(false);
      })
      .catch(() => {
        setIsError(true);
        setIsLoading(false);
      });
  }, [retryCount]);

  return (
    <main>
      {isLoading && <p>Loading orders…</p>}
      {isError && (
        <p role="alert">
          Could not load orders.{" "}
          <button onClick={() => setRetryCount((count) => count + 1)}>
            Retry
          </button>
        </p>
      )}
      <ul>
        {orders.map((order) => (
          <li key={order.id}>
            {order.reference} · {order.total}
          </li>
        ))}
      </ul>
    </main>
  );
}
