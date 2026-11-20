---
name: sync-flow
description: Copy the generic flow block from ~/.claude/flow.md into each repo's docs/agents/workflow.md and open one PR per repo after I confirm it. Use for /sync-flow.
disable-model-invocation: true
---

# Sync flow

Bring each repo's `docs/agents/workflow.md` in line with the generic flow block in `~/.claude/flow.md`. There is no CI drift check; this skill is the only sync. Don't add one.

## Rule: repos stay self-contained

Nothing written to a repo (file content, branch name, commit message, PR title or body) may mention `~/.claude`, dotfiles, this skill, or any other repo. If the source block itself contains such a mention, stop and report it instead of syncing.

## Steps

1. **Source.** Extract the lines strictly between `<!-- flow:start -->` and `<!-- flow:end -->` in `~/.claude/flow.md`. Normalize line endings to LF and hash with `git hash-object --stdin`.
2. **Targets.** Use the repos given as arguments. Otherwise list the git repos under `~/git/*/*` that have `docs/agents/workflow.md`, and ask which to include.
3. **Compare.** For each repo, read `docs/agents/workflow.md` from its default branch on `origin` (after `git fetch`), extract the same marker block, normalize and hash it.
    - Same hash: in sync, skip.
    - No markers: report it and propose where the block should go. Don't guess.
4. **Confirm per repo.** Show the diff for each out-of-sync repo. Continue only with the repos the user confirms.
5. **Open the PR.** For each confirmed repo, without touching the user's checkout:
    - `git worktree add <tmp> -b docs/sync-agent-workflow origin/<default>`
    - Replace only the content between the markers, keeping the file's existing line endings.
    - Commit (`docs: update agent workflow`), push, `gh pr create` with a body that describes the change only.
    - Remove the worktree.
6. **Report.** Per repo: in sync, PR opened (with link), skipped by the user, or needs markers.
