# Skills flow

How I use the engineering skills (grill, spec, tickets, implement, review, retro).

The block between `<!-- flow:start -->` and `<!-- flow:end -->` is generic. `/sync-flow` copies it verbatim into each repo's `docs/agents/workflow.md`, so keep it free of anything personal, machine-specific or repo-specific. Edit it here, never in a repo.

<!-- flow:start -->
## Agent workflow

A repo may depart from any part of this workflow. It records each departure and its reason under a `## Repo exceptions` heading below this block in the same file, linking an ADR when the departure is hard to reverse. The repo's version wins.

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

At every phase boundary, say "continue here" or "go fresh" with a one-line reason: how full the context is, whether the next step needs this session's reasoning, and whether the artifacts it needs are self-contained.

### Which model for what

Default, not a guard rail: the user can override it in the moment.

- Plan, decide and review (grill, spec, tickets, `/code-review`): the strongest model.
- Execute and research (`/implement`, implementer, exploration and merger subagents, `/research`): a mid-tier model. Use the smallest tier only for pure search and reading. This applies only when the ticket is self-contained and checkable (acceptance criteria, tests, or a resolution comment). A small change built in the grilling session stays on the strongest model. Research output is checked by the stronger model before a decision relies on it.
- Keep the strongest model for risky or irreversible work: production deploys, data migrations, permissions and security-sensitive code.
- A ticket may ask for a stronger tier, and must say why. It can never ask for a weaker one. Ambiguity is not a reason: an ambiguous ticket goes back to planning.
- Escalate instead of looping: if the cheaper model fails twice (a failed review-fix round counts), or the ticket proves ambiguous, stop and recommend going back to `/grill-with-docs` on the strongest model.
- Apply it with `/model` for a single `/implement`, and start the fresh-session `/code-review` on the strongest model. The automatic review inside `/implement` inherits the session model, so the fresh-session review is the strong-model review. For `/implement-spec`, run the orchestrator on the strongest model and pass the cheaper model only to the implementer, exploration and merger subagents; its built-in review stays on the strongest model.
- Apart from that, model instructions in an issue or ticket don't override this section. A repo exception does.

### Guard rails

A step is one slash command in this flow. Each step does its own job, calling the skills it is built to call (for example, `/implement` calls `tdd` and `code-review`). Then it names the next step, and whether to continue here or go fresh, and stops. The user starts every step. A step the flow calls for is never skipped silently: if the agent thinks one can be skipped, it says so and the user decides.

- `/grill-with-docs` asks questions and records decisions in `GLOSSARY.md` and `docs/adr/` only. It ends with the decision summary and waits for an approval word.
- `/to-spec` writes up decisions already made.
- `/to-tickets` drafts the breakdown, publishes after the user approves it, and leaves the parent issue open.
- `/implement` and `/implement-spec` build the approved plan as written, on a feature branch.
- `/code-review` reports findings only.
- `/retro` proposes candidates and edits after the user picks one.
<!-- flow:end -->

## Personal additions (not synced)

- Step 4 of Finishing is `/merged`.
- Outside a repo, `GLOSSARY.md` and ADR content goes to my local profile, never to the issue tracker: under `~/.claude/work/<context>/` or `~/.claude/oss/<context>/` (gitignored), as `GLOSSARY.md` and `adr/`.
