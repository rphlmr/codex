import type { Pool } from "pg";

export type ListOptions = { sortColumn: string; limit: number; offset: number };

export async function listUsers(pool: Pool, options: ListOptions) {
  const result = await pool.query(
    `SELECT id, email, created_at FROM users ORDER BY ${options.sortColumn} LIMIT $1 OFFSET $2`,
    [options.limit, options.offset],
  );
  return result.rows;
}
