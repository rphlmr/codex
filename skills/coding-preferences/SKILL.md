---
name: coding-preferences
description: Apply the user's code style, naming, TypeScript architecture, React, and React Router preferences when creating, editing, or reviewing source code, including new projects.
---

# Coding Preferences

Preserve the user's coding preferences in new and modified code. For an
existing project, respect its explicit requirements, formatter, and lint rules.
For a new project, use these preferences as the defaults for the requested stack.
Do not reformat unrelated code or turn a style review into an architecture rewrite.

Read only the references relevant to the work before inspecting or editing
matching code. Each reference retains its original `paths` scope.

| Work | References |
| --- | --- |
| Source code or shell scripts | [Code style](references/code-style.md) |
| Creating source files or folders, including CSS | [File naming](references/file-naming.md) |
| TypeScript | [TypeScript](references/typescript.md) and [architecture](references/architecture.md) |
| JSX or TSX | [React](references/react.md), plus TypeScript references for TSX |
| React Router configuration or routes | [React Router](references/react-router.md), plus applicable language and React references |

These preferences do not authorize new dependencies, a state-machine conversion,
or changes outside the user's request. Keep review findings grounded in concrete
impact; a preference alone is not a correctness defect or release blocker.
