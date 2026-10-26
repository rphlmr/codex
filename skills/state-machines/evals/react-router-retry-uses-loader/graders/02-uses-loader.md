---
type: llm
focus: trace
weight: 1
---

app/routes/orders.tsx loads the orders in an exported `loader` or `clientLoader` and reads them from `loaderData` or `useLoaderData`. The useEffect and the isLoading, isError, and retryCount state are gone. A failed load is handled by the route's `ErrorBoundary` or by the loader's returned data, and retry revalidates (`useRevalidator`, a `Form`, or a link back to the route) instead of refetching in component state.
