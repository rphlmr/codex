---
paths:
  - "**/*.{ts,tsx,mts,cts}"
---

# TypeScript

## Types

- Write precise types. Don't escape the type system to make code compile, such
  as with `as any`, `as unknown as T`, `@ts-ignore`, or untyped `any`
  parameters; fix the types instead.
- `any` is acceptable where precise typing isn't practical, such as deep
  generic or inheritance-heavy type code.
- Avoid unsafe casts and non-null assertions unless the invariant is
  established.
- Check literals against a type with `satisfies` instead of annotating them,
  so the narrow inferred type survives.
- Derive types from their source instead of restating them: `z.output<typeof
  RuleSchema>`, `ReturnType<typeof createFlowMachine>`, indexed access types.
- Store a category or state as a text enum (`topic: "playground" |
  "bug_repro"`), never as a boolean flag, even when only one value is
  special, in schemas, stored records, and API contracts. A checkbox in the UI
  can still set it.
- Give a value that drives logic a literal union or key, and map it to display
  text in one place (`saveStateLabels[state]`). Never compare, match, or parse
  user-facing text or error messages to decide behavior.
- Write status and state literals in snake_case (`"read_only"`,
  `"rolled_back"`), not kebab-case.
- Name generic parameters for their role when there is more than one or the
  meaning is not obvious (`TActorIdPrefix`, `Output`), not `T` and `U`.

## Modules

- Use named exports. Use a default export only where a framework or tool
  requires one.
- Import types with `import type`, or an inline `type` specifier in a mixed
  import.
- Group imports: packages first, a blank line, then relative imports. Inside
  each group, put type imports before value imports when the formatter does
  not already sort them.

## Functions

- Declare exported and top-level functions with `function`. Use arrow
  functions for inline callbacks and short object members.
- Take an options object, destructured in the signature, once a function needs
  more than two parameters or any optional one.
- Build services as factories: `createSubscriptionService(dependencies)` takes
  a typed `SubscriptionServiceDependencies` object and returns an object of
  named inner functions. Use classes only for errors and stateful resources.
- Name schemas in PascalCase with a `Schema` suffix (`PaymentContextSchema`),
  and validate untrusted input with `safeParse` before using it.
- Use numeric separators and arithmetic for readable constants (`5_000`,
  `64 * 1024`) and template literals over string concatenation.

## JSDoc

- Write doc comments as JSDoc `/** */` blocks, following the `code-style`
  rule on when to add one.
- Document a parameter as `@param seconds - The number of seconds to cache`
  when its name and type leave its meaning or unit unclear, and `@returns`
  when the result is not obvious from the title. Use `@example` for shapes
  worth showing.
- Use `@deprecated` with the replacement to call instead.

## Tests

- Nest one `describe` per unit under test, and phrase each case as
  `it("should <expected behavior>")`, such as
  `it("should return undefined for invalid ISO string")`.
- Separate arrange, act, and assert with blank lines when a case has more than
  two statements.
- Build test input with `make<Thing>()` helpers that take an options object
  with defaults, so each case states only what it changes.

## Validation with Zod

- Validate data whose shape isn't guaranteed by the type system with a Zod
  schema at the boundary where it enters: request bodies, URL and search
  params, parsed JSON, storage, environment variables, API responses, and
  messages. Don't hand-write type guards or cast `unknown` to a type instead.
- Use `safeParse` when invalid input is an expected branch, and handle the
  failure explicitly. Use `parse` only when invalid data means a bug.
- Reuse and compose existing schemas, including generated ones, with
  `extend`, `pick`, `omit`, `discriminatedUnion`, and `transform` instead of
  redefining a shape.
- Match the Zod version and import path the project already uses. If the
  project validates with another library, follow it instead.

## Error handling

- Name the caught value `cause`. Use a bare `catch {}` when it's unused.
- At a service or I/O boundary, rethrow with the inputs needed to debug,
  following the `code-style` rule on errors. Without a project error type, use
  `new Error(message, { cause })`.
- When catching only to report, such as a callback or telemetry, rethrow the
  same `cause` afterwards. Don't report cancellations (`AbortError`), including
  ones wrapped in another error.
- When a failure is expected and has a fallback, such as `JSON.parse` or
  `new RegExp` on external input, wrap only that call and return the fallback.
- Swallow an error only in best-effort side work whose failure must not break
  the main flow, such as user-supplied callbacks, and log it with context.
- When one plugin, rule, or batch item fails, isolate it: log it with context,
  turn it into a result such as an issue or `undefined`, and continue.
- Use `try/finally` for cleanup or rescheduling that must run either way.
