# Branch descriptions

## Establish the comparison

Use local Git state only. The end of the comparison is local `HEAD`, including
unpushed commits. Use the user's supplied base; otherwise infer it from locally
recorded remote-default refs, then unambiguous conventional base branches.
The feature branch's upstream is not automatically its PR base.
Ask for a base if the available candidates remain ambiguous.

Compute `git merge-base HEAD <target>`. Inspect history and the effective diff
from that merge base to `HEAD`. For large branches, inspect by meaningful area;
statistics alone are insufficient. Include every meaningful final outcome,
rather than narrating commits or temporary implementation states.

Exclude staged, unstaged, and untracked changes. Mention their exclusion when
the worktree is dirty. If no branch-specific commits exist, say so.
If Git context or the merge base cannot be established, report the limitation.

## Write for the reader

Lead with the concrete problem and resulting behavior. Include compatibility,
migration, public API, or operational implications only when supported.
For a small PR, one or two sentences and relevant validation are sufficient.
Use domain-oriented sections for larger changes or follow the repository's
PR template. Release notes describe externally observable changes.

When the base was inferred, disclose it before the description:
`> Comparison target: <target> (inferred from local Git metadata).`

Distinguish tests added from tests actually run. Do not infer passing CI,
deployment, motivation, or compatibility from filenames or commit messages.
Include user-supplied validation evidence with its actual limits.

Return only the requested copyable Markdown. Do not create a PR, change Git
state, contact remotes, or run builds and tests solely to write the description.
