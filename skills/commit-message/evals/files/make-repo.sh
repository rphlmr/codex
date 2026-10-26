#!/usr/bin/env bash
# Builds a throwaway Git repository in the current, empty directory for one
# eval scenario: feature, fix, or unstaged-only.

set -euo pipefail

scenario="${1:-}"

case "$scenario" in
  feature | fix | unstaged-only) ;;
  *)
    echo "Usage: make-repo.sh feature|fix|unstaged-only" >&2
    exit 1
    ;;
esac

if [[ -n "$(ls -A)" ]]; then
  echo "Run this in an empty directory." >&2
  exit 1
fi

git init -q -b main
git config user.name "Eval Fixture"
git config user.email "eval@example.com"
git config commit.gpgsign false

mkdir -p src

cat > src/http.ts <<'EOF'
export async function fetchJson<T>(url: string): Promise<T> {
  const response = await fetch(url);

  if (!response.ok) {
    throw new Error(`Request failed with status ${response.status}`);
  }

  return (await response.json()) as T;
}
EOF

cat > src/paginate.ts <<'EOF'
export function lastPage(totalItems: number, pageSize: number): number {
  return Math.floor(totalItems / pageSize);
}
EOF

echo "# Fixture" > README.md

git add .
git commit -q --no-verify -m "chore: initial commit"

case "$scenario" in
  feature)
    cat > src/http.ts <<'EOF'
export interface FetchJsonOptions {
  retries?: number;
}

export async function fetchJson<T>(
  url: string,
  { retries = 0 }: FetchJsonOptions = {},
): Promise<T> {
  for (let attempt = 0; ; attempt++) {
    const response = await fetch(url);

    if (response.ok) {
      return (await response.json()) as T;
    }

    if (attempt >= retries) {
      throw new Error(`Request failed with status ${response.status}`);
    }
  }
}
EOF

    cat > src/http.test.ts <<'EOF'
import { expect, test, vi } from "vitest";

import { fetchJson } from "./http";

test("retries a failed request", async () => {
  const fetchMock = vi
    .fn()
    .mockResolvedValueOnce(new Response(null, { status: 503 }))
    .mockResolvedValueOnce(Response.json({ ok: true }));

  vi.stubGlobal("fetch", fetchMock);

  await expect(fetchJson("/api", { retries: 1 })).resolves.toEqual({ ok: true });
  expect(fetchMock).toHaveBeenCalledTimes(2);
});
EOF

    git add src/http.ts src/http.test.ts
    ;;
  fix)
    cat > src/paginate.ts <<'EOF'
export function lastPage(totalItems: number, pageSize: number): number {
  return Math.max(1, Math.ceil(totalItems / pageSize));
}
EOF

    git add src/paginate.ts
    echo "Pagination helpers." >> README.md
    ;;
  unstaged-only)
    echo "Pagination helpers." >> README.md
    ;;
esac
