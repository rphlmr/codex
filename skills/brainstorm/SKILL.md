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
- Otherwise present the one approach you recommend, with one line on the
  strongest alternative and why you set it aside.

## Write the design

Write the agreed design in chat, sized to the work:

- objective and observable outcome;
- chosen approach and the parts of the code it touches;
- key decisions, with assumptions marked as such;
- acceptance criteria;
- open risks.

When correctness depends on state transitions, apply the `state-machines`
skill and include the machine.

Save the design to a file only when the user asks, at the path they name or one
that fits the repository's docs layout.

## Close

End with one recommended next step: implement in this session, enter plan mode
first for large multi-step work, or `$session-handoff` when the work should
continue in a fresh session. Wait for the user before implementing.
