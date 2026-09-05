---
name: pr-changelog
description: Generate a paste-ready PR/MR description, reviewer changelog, review-prep summary, or release notes from every committed change on the current local Git branch since its branch point. Does not open a PR or include uncommitted changes.
---

# PR Changelog

Generate a polished changelog for the complete committed changeset on the
current local Git branch using exactly one `pr_changelog` custom agent.

Whether commits have been pushed is irrelevant.

This skill produces text only.

It does not:

- open or update a pull request;
- open or update a merge request;
- modify Git state;
- include staged, unstaged, or untracked changes.

## Workflow scope

The delegation and output rules below are defaults for the changelog-generation
step. Explicit user instructions take precedence over these skill guidelines.
The custom agent retains its committed-only, read-only scope; use another
workflow for requirements outside that scope.

For a request to create or update a PR, the parent may perform authorized
preparation before this step and publish the description afterward. Returning
text alone does not complete a request for a PR. Parent restrictions below apply
while the delegated changelog analysis runs, not to the rest of the task.

## Supported Output Modes

The supported modes are:

1. `PR/MR description`
   - Default mode.
   - Produces polished Markdown ready to paste into a pull request or merge
     request.

2. `Review prep`
   - Produces the PR/MR description plus focused reviewer guidance.

3. `Release notes`
   - Includes only user-visible or externally observable changes.

4. `Changelog only`
   - Produces a compact complete change list without the summary section.

When the user does not explicitly select a mode, use:

`PR/MR description`

## Prepare the Request

Pass the user's request to the custom agent with any explicitly supplied:

- base or target branch;
- output mode;
- language;
- formatting requirement;
- desired detail level;
- review focus;
- release-note audience;
- compatibility emphasis.

Do not invent missing preferences.

Do not infer a base branch in the parent thread.

Do not infer whether commits have been pushed.

Do not pass the complete conversation when a concise request is sufficient.

## Committed-Changes Boundary

This workflow covers only:

- every commit on the current local branch since its merge base with the
  selected comparison target;
- the complete effective committed diff represented by local `HEAD`;
- both pushed and unpushed local commits.

This workflow always excludes:

- staged but uncommitted changes;
- unstaged changes;
- untracked files.

If the user explicitly requires uncommitted changes to be included, do not
silently omit them or ask the custom agent to violate its scope. Explain this
committed-only boundary and return control to the parent to fulfill the request
outside this skill. Do not commit uncommitted work just to fit the skill unless
the user authorized committing it.

## Delegate

When the request is within scope, spawn exactly one fresh custom-agent thread
using:

`pr_changelog`

The custom agent owns the complete Git workflow, including:

- validating repository context;
- identifying the current local branch;
- determining the comparison target;
- computing the merge base;
- reading the complete branch commit history;
- inspecting the effective committed diff;
- identifying all meaningful workstreams;
- collapsing fixups and intermediate states;
- detecting compatibility and migration implications;
- identifying relevant committed test coverage;
- producing the final professional changelog.

## Parent Boundaries

The parent agent must not:

- run Git commands;
- inspect repository status;
- inspect commit history;
- inspect diffs;
- determine the base branch;
- determine the merge base;
- determine which commits have been pushed;
- independently summarize the branch;
- add unsupported context;
- rewrite or polish the custom agent's response;
- append additional findings;
- spawn another agent.

Do not perform a second changelog analysis in the parent thread.

## Output

Return the `pr_changelog` custom agent's result unchanged.

Preserve:

- headings;
- bullet grouping;
- compatibility notes;
- breaking-change notes;
- test-coverage notes;
- dirty-repository notes;
- review-focus sections.

Do not add:

- an introduction;
- an explanation;
- commentary;
- an alternative changelog;
- analysis before the result;
- analysis after the result;
- a statement explaining how the changelog was generated.

## Agent Unavailable

If the `pr_changelog` custom agent is unavailable or cannot be spawned, report:

PR-changelog agent unavailable.

When the user did not require that specific agent, the parent may complete the
requested text-generation step directly using the same evidence boundaries.
Do not claim that the custom agent produced the result. When the user did
require that agent, report the blocked step and continue only other authorized
work that does not depend on its result.
