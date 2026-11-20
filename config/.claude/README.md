# config/.claude

Portable Claude Code user config. Setup links this whole folder to `~/.claude` (see the root `README.md`), so everything Claude Code writes at runtime also lands here. The `.gitignore` in this folder keeps that out of git.

## Layout

| Path | What it is |
| --- | --- |
| `CLAUDE.md` | Global rules. Imports `flow.md`. |
| `flow.md` | The skills flow. The block between its markers is the generic copy that `/sync-flow` puts in repos. |
| `.gitignore` | The allowlist. |
| `skills/merged/` | `/merged`: post-merge branch and worktree cleanup. |
| `skills/recall-notes/` | `/recall-notes`: recover context from notes and recent sessions. |
| `skills/sync-flow/` | `/sync-flow`: copy the generic flow block into repos, one confirmed PR each. |
| `work/`, `oss/` | Private notes per context, each folder optionally indexed by its own `README.md`. Only the folders are tracked. |
| everything else | Runtime state written by Claude Code, never tracked. |

## The allowlist

`.gitignore` ignores `*`, then un-ignores the tracked paths. It is the only list of what is tracked. Each own skill needs a pair of lines (`!/skills/<name>/` and `!/skills/<name>/**`); other skills in `skills/` stay ignored. `settings.json` is deliberately ignored for now.

To track something new, add it to `.gitignore`. The lefthook `pre-commit` guard (`scripts/check-claude-allowlist.sh`) rejects any staged path under `config/.claude` that the allowlist ignores, including paths added with `git add -f`.
