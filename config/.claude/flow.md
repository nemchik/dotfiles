# Skills flow

How I use the engineering skills (grill, spec, tickets, implement, review, retro). This file is the single source of truth.

The block between `<!-- flow:start -->` and `<!-- flow:end -->` is generic. `/sync-flow` copies it verbatim into each repo's `docs/agents/workflow.md`, so keep it free of anything personal, machine-specific or repo-specific. Edit it here, never in a repo.

<!-- flow:start -->
## Agent workflow

### Choosing a route

- A question, a one-line fix or a small edit needs no skill.
- **Small change:** `/grill-with-docs`, then `/implement`, in the same session. The build needs the grilling's reasoning, not a summary of it.
- **Larger work:** `/grill-with-docs` → `/to-spec` → `/to-tickets` in one unbroken window. Don't `/clear` or `/compact` until `/to-tickets` is done. `/to-spec` may be skipped: `/to-tickets` can run straight from the grilling thread.
    - Then build in a **fresh session**. The spec and tickets carry everything the build needs.
    - Multi-ticket work: `/implement-spec` (the default).
    - A single ticket, or when the user wants to steer each ticket: `/implement`, with `/clear` between tickets.
- Work that won't fit one session even after grilling: `/wayfinder`. A question that needs runnable code to answer: `/prototype`.

### Approval words

Grilling ends with a summary of the decisions and stops. "yes" or "lgtm" approves only the summary. Building starts only on "implement it", "go ahead" or `/implement`.

### Commit, then review

- `/code-review` diffs commits (`<fixed-point>...HEAD`), so uncommitted work is never reviewed. Commit first.
- Before recommending `/code-review`, run `git status` and check for commits not yet pushed. Report any uncommitted or unpushed work with a recommendation (commit it, push it, stash it, or leave it out on purpose and say why).
- The `implement` skill runs its review before it commits. This rule overrides it: commit, then review.
- After `/implement`: a separate `/code-review` in a fresh session is required.
- After `/implement-spec`: skip the separate review. The orchestrator wrote no code (its subagents did), and it already reviewed the committed integration branch.

### Fixing review findings

- The review session never fixes, never loops until clean (it never converges) and never spawns more reviewers.
- Fixes go back to the original implement session if it still has room (under ~150k tokens): paste the findings in. Otherwise run a fresh `/implement` seeded with the findings.
- `/implement-spec` fixes its own findings in one fresh implementer subagent.

### Finishing

1. Push and open a PR whose body has `Closes #N` for each ticket.
2. Close the tickets and tick their acceptance criteria. `/implement` does neither.
3. Merge once the PR has been reviewed.
4. Clean up merged branches and worktrees.
5. Optional: `/retro`, only if the session was rough. Run it in the session it looks back on, before clearing; after a clear, point it at that session's log.

### Phase boundaries

At every phase boundary, say "continue here" or "go fresh" with a one-line reason: how full the context is, whether the next step needs this session's reasoning, and whether the artifacts it needs are self-contained. This is enforced by instruction only; there are no hooks.

### Guard rails (must not)

- Never start a step the user hasn't chosen. Name the slash command to type and stop. Never do another step's work.
- `/grill-with-docs` touches no code, branches, commits, PRs, issues or deploys. It edits only `GLOSSARY.md` and `docs/adr/`, and doesn't build on "yes" or "lgtm".
- `/to-spec` doesn't interview or make new decisions.
- `/to-tickets` writes no code, publishes nothing before the user approves the breakdown, and doesn't close the parent issue.
- `/implement` and `/implement-spec` don't reopen the plan, don't interview, and don't build on the default branch.
- `/code-review` doesn't fix anything.
- `/retro` changes nothing until the user picks a candidate.
<!-- flow:end -->

## Personal additions (not synced)

- Step 4 of Finishing is `/merged`.
- Outside a repo, `GLOSSARY.md` and ADR content goes to my local profile, never to the issue tracker: under `~/.claude/work/<context>/` or `~/.claude/oss/<context>/` (gitignored), as `GLOSSARY.md` and `adr/`.
