#!/usr/bin/env bash
# Builds a throwaway Git repository in the current, empty directory: `main`
# plus a checked-out `feature/fetch-retry` branch with three commits (one a
# fixup), a staged edit, an unstaged edit, and an untracked file. No remote is
# configured, so the comparison target must be inferred from local branches.

set -euo pipefail

if [[ -n "$(ls -A)" ]]; then
  echo "Run this in an empty directory." >&2
  exit 1
fi

git init -q -b main
git config user.name "Eval Fixture"
git config user.email "eval@example.com"
git config commit.gpgsign false

commit() {
  git add -A
  git commit -q --no-verify -m "$1"
}

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

printf '# http-kit\n\nSmall fetch helpers.\n' > README.md
commit "chore: initial commit"

git switch -q -c feature/fetch-retry

cat > src/http.ts <<'EOF'
export interface FetchJsonOptions {
  retries?: number;
}

export async function fetchJson<T>(
  url: string,
  { retries = 2 }: FetchJsonOptions = {},
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

printf '# http-kit\n\nSmall fetch helpers.\n\n`fetchJson(url, { retries })` retries failed requests.\n' > README.md
commit "add retry option to fetchJson"

sed -i.bak 's/retries = 2/retries = 1/' src/http.ts
rm src/http.ts.bak
commit "fixup! add retry option to fetchJson"

cat > src/http.test.ts <<'EOF'
import { expect, test, vi } from "vitest";

import { fetchJson } from "./http";

test("retries once by default", async () => {
  const fetchMock = vi
    .fn()
    .mockResolvedValueOnce(new Response(null, { status: 503 }))
    .mockResolvedValueOnce(Response.json({ ok: true }));

  vi.stubGlobal("fetch", fetchMock);

  await expect(fetchJson("/api")).resolves.toEqual({ ok: true });
  expect(fetchMock).toHaveBeenCalledTimes(2);
});
EOF
commit "test retry behavior"

echo "Work in progress." > NOTES.txt
echo "Staged but not committed." >> README.md
git add README.md
echo "// TODO: jitter" >> src/http.ts
