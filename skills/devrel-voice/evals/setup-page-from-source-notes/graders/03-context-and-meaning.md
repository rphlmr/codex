---
type: llm
focus: trace
weight: 1
---

The cleanup warning identifies upgrades from rc4, removal of replaced project
skills, backing up custom edits before installation, and unchanged user-level
skills. Readers should not have to infer why old skills exist or whether the
warning applies to a first install. Place the warning where it informs installation.

The update instructions say to rerun the install command after updating Kit and
do not imply that revision checks update skills automatically. If a revision
command is shown, distinguish the bundled revision from the agent's installed
revision. A complete revision-inspection walkthrough is optional.

The page distinguishes generated SQL from applied database changes, without
repeated permission disclaimers. It does not promise that installing the skill
enforces review or guarantees correct renames. It speaks to the reader about
practical behavior instead of repeatedly narrating what internal instructions
tell the agent to do. Preserve these distinctions even when cutting prose.
