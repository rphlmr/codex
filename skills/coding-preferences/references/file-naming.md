---
paths:
  - "**/*.{ts,tsx,mts,cts,js,jsx,mjs,cjs}"
  - "**/*.{swift,m,mm,kt,kts,java,dart}"
  - "**/*.{go,rs,py,rb,php,cs,scala}"
  - "**/*.{c,h,cc,cpp,hpp}"
  - "**/*.{sh,bash,zsh}"
  - "**/*.{css,scss}"
---

# File Naming

Name new files and folders in kebab-case: lowercase words joined by hyphens,
such as `user-profile.tsx`, `use-flow-machine.ts`, or `api-client/`. Apply it
even where existing files use another case. Do not rename existing files unless
asked. The repository's lint configuration takes precedence.

- Lowercase acronyms and keep role suffixes after a dot:
  `http-client.test.ts`, `auth.contract.ts`.
- Keep names that tools or conventions fix, such as `README.md`, `AGENTS.md`,
  `SKILL.md`, `Dockerfile`, `Package.swift`, and framework routing syntax
  (`$id.tsx`, `_index.tsx`, `[slug]/`, `(group)/`).
- Follow the language's naming where kebab-case breaks imports, compilation,
  or tooling: snake_case for Python and Rust modules, PascalCase for Java and
  Kotlin classes, and PascalCase for Swift files named after the type they
  declare.
