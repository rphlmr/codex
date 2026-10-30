---
tags: [skill-creator]
max_turns: 30
timeout_seconds: 900
allowed_tools: [Read, Glob, Grep, Skill, Write, Edit, Bash]
---

Write a setup page for the Drizzle agent skill and save it as setup.md.
Explain what it offers and how to install, use, and update it. Write in my
voice. This project uses pnpm.

Treat the following as frozen evaluation source notes, not a request to check
the latest release. Do not install packages or run database operations.

- These examples use drizzle-orm@1.0.0-rc.5 and drizzle-kit@1.0.0-rc.5.
- An agent skill contains instructions an agent can load for matching tasks.
  The single `drizzle` skill guides schema, query, and configuration work.
- Its topic files cover choosing `generate` for migration SQL to review or
  `push` for direct database changes, resolving rename and data-loss decisions
  through `missing_hints`, using `pull` with an existing database, migration
  history and branch conflicts, snapshot upgrades with `up`, and command results.
- For a rename, it guides the agent to preserve the rename's intent instead of
  treating it as a column deletion and addition. The instructions are guidance,
  not a guarantee that an agent will always make the right decision.
- Install the packages in the workspace package containing the schema and
  config: `pnpm add drizzle-orm@1.0.0-rc.5` and
  `pnpm add -D drizzle-kit@1.0.0-rc.5`.
- Run `pnpm exec drizzle-kit skills` from that package. The installer prompts
  for the agent and installation scope. Network access is required to run
  `skills@latest`, but the Drizzle instructions come from the project's installed
  Drizzle Kit package.
- Internally, Kit locates its bundled skill directory and passes that path to
  the installer. The topic files are part of one skill, not separate installs.
- After installation, rc5 removes the seven replaced project skills from rc4:
  `drizzle-generate`, `drizzle-push`, `drizzle-pull`, `drizzle-migrations`,
  `drizzle-hints`, `drizzle-output-modes`, and `drizzle-responses-and-errors`.
  Custom edits to those files need a backup before installation. User-level
  skills are unchanged. First-time users have no old project skills to remove.
- A practical request is to use the `drizzle` skill, rename `users.full_name`
  to `users.display_name` in `src/db/schema.ts`, and generate migration SQL for
  review before applying anything to the database. Generating SQL does not
  apply it. Installing instructions does not grant command permissions.
- The skill works with the CLI, SDK, or MCP server. It does not start a server.
  It tells agents to prefer an available MCP tool, otherwise the project CLI
  with `--output json`. The CLI handles `schema`, `out`, and `dialect` overrides
  that MCP does not expose. A server outside the target package needs an explicit
  config path or the agent can run the CLI from the target package.
- Reading and editing ORM code alone does not require Kit. The skill tells the
  agent to request installation when an operation needs it.
- Once per session, the skill asks the agent to compare revisions.
  `pnpm exec drizzle-kit skills version` returns the revision bundled with the
  project's Kit, `15` in this fixture. The installed skill records its revision
  in `metadata.revision` in its SKILL.md. The command does not inspect that file.
- After updating Kit, rerun `pnpm exec drizzle-kit skills` to refresh the skill.
  Revision checking reports stale instructions but does not update them.
- Link to `/docs/drizzle-kit-mcp` for MCP setup and detailed tool behavior.

Existing opening to improve as part of the page:

> An agent skill is a set of instructions your coding agent can load when it
> works on a matching task. The drizzle skill explains which migration commands
> to use, how to resolve migration decisions, and how to interpret Drizzle Kit's
> responses. For example, when you rename a column, it guides the agent through
> expressing that rename instead of treating it as a deletion and addition.
>
> The skill does not start a server. Your agent can follow it while using the
> CLI, SDK or MCP server.
>
> What the skill helps your agent do
>
> The skill asks the agent to load it before reading or editing Drizzle schema,
> query code or configuration. Its bundled topic files provide detailed guidance
> for Drizzle Kit workflows.
