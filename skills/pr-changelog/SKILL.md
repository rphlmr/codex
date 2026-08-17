---
name: pr-changelog
description: Draft PR/MR changelogs from all committed changes on the current local Git branch since its branch point. Use when the user asks for a pull request, merge request, branch, review-prep, or release-note style summary based on local commits or branch changes.
---

# PR Changelog

Generate a changelog for the complete committed changeset on the current local Git branch.

Whether commits have been pushed is irrelevant.

## Execution

Delegate the complete task to exactly one `pr_changelog` custom agent.

Pass the user's request to the agent, including any explicit:

- target or base branch;
- output mode;
- formatting requirements;
- desired level of detail;
- review focus;
- release-note constraints.

The `pr_changelog` agent owns the complete workflow, including:

- validating the Git repository context;
- identifying the current local branch;
- determining the comparison target;
- computing the branch point;
- reading all local branch commits since that branch point;
- inspecting the complete committed changeset;
- inspecting focused diffs when necessary;
- identifying the effective changes;
- grouping related commits;
- producing the final changelog.

The parent agent must not perform any part of that Git analysis.

Specifically, the parent agent must not:

- run Git commands;
- inspect commit history;
- inspect diffs;
- determine the comparison base;
- determine which commits have been pushed;
- summarize the branch independently;
- revise or augment the subagent's changelog;
- spawn additional agents.

Wait for the `pr_changelog` agent to complete.

## Changeset Definition

The changelog represents:

- every committed change on the current local branch since it diverged from its selected base branch;
- commits that have already been pushed;
- commits that have not yet been pushed.

Push state must not affect the generated changelog.

Staged, unstaged, and untracked changes are excluded unless the user explicitly asks to include them.

## Output

Return the `pr_changelog` agent's result unchanged.

Do not add:

- an introduction;
- an explanation;
- commentary;
- alternative changelogs;
- analysis before or after the result.

If the `pr_changelog` custom agent is unavailable or cannot be spawned, output exactly:

PR-changelog agent unavailable.

Do not fall back to performing the task in the parent agent.
