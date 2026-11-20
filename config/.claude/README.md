# config/.claude

Portable Claude Code user config. Setup links this whole folder to `~/.claude` (see the root `README.md`), so everything Claude Code writes at runtime also lands here. The `.gitignore` in this folder keeps that out of git.

## Layout

| Path | Tracked | What it is |
| --- | --- | --- |
| `CLAUDE.md` | yes | Global rules. Imports `flow.md`. |
| `flow.md` | yes | The skills flow. The block between its markers is the generic copy that `/sync-flow` puts in repos. |
| `README.md` | yes | This file. |
| `.gitignore` | yes | The allowlist. |
| `skills/merged/` | yes | `/merged`: post-merge branch and worktree cleanup. |
| `skills/recall-notes/` | yes | `/recall-notes`: recover context from notes and recent sessions. |
| `skills/sync-flow/` | yes | `/sync-flow`: copy the generic flow block into repos, one confirmed PR each. |
| `work/`, `oss/` | folder only | Private notes per context, each folder optionally indexed by its own `README.md`. Contents are ignored; `.gitkeep` keeps the folders. |
| everything else | no | Runtime state: `projects/`, `history.jsonl`, `.credentials.json`, `plugins/`, `settings.json`, `settings.local.json`, caches, third-party skills. |

## The allowlist

`.gitignore` ignores `*`, then un-ignores exactly these:

- `.gitignore`, `CLAUDE.md`, `flow.md`, `README.md`
- `skills/merged/`, `skills/recall-notes/`, `skills/sync-flow/` (one pair of lines per own skill; other skills in `skills/` stay ignored)
- `work/.gitkeep`, `oss/.gitkeep`

`settings.json` is deliberately ignored for now.

To track something new, add it to `.gitignore` **and** to the list above. The lefthook `pre-commit` guard (`scripts/check-claude-allowlist.sh`) rejects any staged path under `config/.claude` that the allowlist ignores, including paths added with `git add -f`.
