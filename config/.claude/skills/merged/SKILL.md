---
name: merged
description: Post-merge cleanup. Verify the work is merged, delete merged local and remote branches, remove clean worktrees, and report what was removed and kept. Use for /merged after a PR merges.
disable-model-invocation: true
---

# Merged

Clean up after a merge. Act on your own for local, reversible-enough git housekeeping when you are confident. Confirm anything that posts or changes something outside git.

## Never touch

- A branch with commits that are in no merged PR and not in the default branch (check with `git cherry <default> <branch>`; a `+` line is unique work).
- A dirty worktree (`git -C <path> status --porcelain` is not empty), and stashes.
- A worktree whose path is not reachable from this environment. From a VM, WSL or container, worktrees registered with Windows paths (`C:/...`) look prunable. Don't run `git worktree prune` and don't remove them; report them as kept.

Valuable unmerged work is kept until a PR for it is opened and accepted. Say which future PR it belongs to.

## Steps

1. **Orient.** `git fetch --prune origin`. Find the default branch and repo settings with `gh repo view --json defaultBranchRef,deleteBranchOnMerge`. The target branch is the argument, else the current branch.
2. **Verify the merge.** `gh pr list --state merged --head <branch> --json number,headRefOid,mergedAt`. You are confident only when a PR is merged and the local branch tip equals its `headRefOid` or is an ancestor of it. Squash merges hide this from `git branch --merged`, so use the PR, not the graph. If not confident, stop and report.
3. **Update the default branch.** Switch to it (or use the worktree that has it) and `git pull --ff-only`. If the switch would carry uncommitted changes, stop and report them.
4. **Remote branch.** If `deleteBranchOnMerge` is true, check that the remote branch is gone (`git ls-remote --heads origin <branch>`). If it still exists, the setting didn't fire: `git push origin --delete <branch>`.
5. **Local branch.** `git branch -D <branch>` (`-D` because squash merges are not ancestors).
6. **Worktrees.** `git worktree list --porcelain`. Remove each clean, reachable worktree whose branch you just deleted or that has no branch left: `git worktree remove <path>`.
7. **Sweep.** Repeat steps 2 and 4 to 6 for other local branches whose upstream is `gone` and that pass step 2. Anything that fails a check is kept.
8. **Non-local follow-ups.** Linked issues still open, criteria not ticked, PR comments to answer: draft the change locally, show it, and act only after the user confirms. Never post without confirmation.

## Report

End with exactly three short sections:

- **Removed:** branches (local/remote) and worktrees.
- **Kept:** each with the reason (unmerged work, dirty, unreachable path, not confident).
- **Uncommitted changes:** per worktree, or "none".
