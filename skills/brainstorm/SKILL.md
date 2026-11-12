---
name: brainstorm
description: Turns a rough idea into an agreed design through short rounds of focused questions, before any code is written.
---

# Brainstorm

Reach an agreed design for the idea in the request. Stop at the agreed design:
brainstorming does not authorize implementation.

## Ground the idea

Read the relevant code, docs, and recent commits first, so every question is
about a decision, not a fact the repository already answers.
Reuse the user's accepted choices and success criteria. Reopen a choice only
when a changed requirement, relevant new evidence, or the user's explicit
change of direction makes it necessary. The existence of another viable
option is not enough.

## Ask with the question tool

- Ask through the available structured question tool. If none is available,
  ask concise questions in chat.
- Ask only questions whose answer changes the design: purpose, constraints,
  success criteria, and scope edges.
- Respect the question tool’s limits, with concrete options,
  the recommended one first and marked "(Recommended)". Use option previews when the tool supports them to compare layouts or
  code shapes.
- Ask in rounds and let each answer shape the next round. Stop once the
  remaining unknowns would not change the design, and state them as
  assumptions.

## Choose an approach

- Present two or three distinct approaches, each with its trade-off and a
  recommendation, when the user asks for options or when several viable
  designs differ materially in cost, risk, or user experience. Let the user
  pick through the available structured question tool.
- Otherwise present the one approach you recommend and its reason. Do not
  append alternatives the user does not need to decide.

## Write the design

Write the agreed design in chat, sized to the work:

- objective and observable outcome;
- chosen approach and the parts of the code it touches;
- key decisions, with assumptions marked as such;
- acceptance criteria;
- material open risks that could change the decision or acceptance criteria.

If the user also invokes `state-machines`, apply that skill to the transition
design. Do not automatically activate other personal skills.

Save the design to a file only when the user asks, at the path they name or one
that fits the repository's docs layout.

## Close

Once the material choices and acceptance criteria are settled, state that the
design is complete. Do not start another comparison or add speculative risks
to keep the discussion open. Name the single next step justified by the
agreed work, if one is needed. Wait for the user before implementing.
