---
name: future-architect-mode
description: Run an independent architecture review of a raw technical idea, architecture question, emerging design, or implementation plan, focused on evolvability, reversibility, migration cost, and credible future constraints.
---

# Future Architect Mode

Obtain independent architectural feedback from exactly one
`future_architect` custom agent.

This workflow is advisory.

It does not:

- implement changes;
- modify repository files;
- rewrite a plan automatically;
- decide on behalf of the user;
- treat architectural feedback as mandatory.

Invoking this skill explicitly means that an independent architecture review is
requested.

Ordinary architecture questions that do not invoke this skill can be handled in
the parent thread without spawning the custom agent.

## Supported Input

The input may be:

- a raw technical or product idea;
- a broad architecture question;
- an emerging design;
- competing approaches;
- an existing architecture;
- a migration proposal;
- a draft implementation plan;
- a refined implementation plan;
- a specific hard-to-reverse decision.

Do not require a formal plan.

Do not force a raw idea into an implementation plan.

## Prepare the Review Brief

Extract the relevant architectural context from the current conversation.

Prepare a concise brief containing only what the independent agent needs:

- the exact question, idea, design, or plan to review;
- the maturity of the input:
  - raw idea;
  - architecture question;
  - emerging design;
  - draft plan;
  - refined plan;
- the current objective;
- explicit requirements and constraints;
- relevant current-system or repository context already established;
- explicit decisions that should be treated as current;
- credible alternatives already under consideration;
- material assumptions or uncertainties;
- the aspect the user wants evaluated, when explicitly stated;
- any known non-goals.

When reviewing a plan, include the final current version of that plan.

Do not include:

- the complete conversation;
- superseded plans;
- rejected alternatives unless their rejection remains architecturally relevant;
- exploratory discussion that no longer affects the decision;
- your own architectural conclusion;
- recommendations that would bias the independent review.

Do not silently convert assumptions into facts.

When information is incomplete but a reasonable assumption permits useful
analysis, ask the agent to state the assumption and continue.

Do not block the review merely because the input is not fully specified.

## Delegate

Spawn exactly one fresh custom-agent thread using:

`future_architect`

Give it the prepared review brief.

Ask it to provide independent architectural feedback according to its own output
contract.

Do not ask it to:

- implement anything;
- modify files;
- rewrite the complete plan;
- make the final decision;
- delegate to another agent.

The parent agent must not perform a duplicate architecture review before the
subagent returns.

Do not spawn additional architecture, exploration, or review agents.

## Present the Result

Return the `future_architect` response unchanged by default.

Preserve:

- its headings;
- finding identifiers;
- priorities;
- evidence;
- actions;
- evolution triggers;
- uncertainty;
- final next action.

Do not:

- compress the findings into a prose summary;
- merge separate findings;
- remove apparently optional findings;
- rewrite the result into a plan;
- silently accept or reject recommendations;
- modify the user's current direction automatically.

Only when the user explicitly asks for the parent agent's own opinion, append a
clearly separated section:

## Parent Assessment

State where the parent agent agrees or disagrees with the independent review and
why.

Do not alter the original independent findings.

## Subsequent Plan Changes

Treat incorporating the feedback as a separate action.

When the user later asks to update or refine a plan:

1. use only the findings the user accepted, unless the user delegates that
   decision;
2. preserve decisions the user rejected or deferred;
3. make targeted plan changes rather than rewriting unaffected sections;
4. distinguish required corrections from optional future improvements.

## Agent Unavailable

If the `future_architect` custom agent is unavailable or cannot be spawned,
output exactly:

Future-architect agent unavailable.

Do not substitute parent-thread reasoning while claiming that it is an
independent review.
