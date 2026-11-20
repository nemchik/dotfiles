---
name: recall-notes
description: Recover context for a project or topic from my own notes and recent Claude Code session state. Use when I ask to recall, catch up on, or pick back up a project or topic.
---

# Recall notes

Rebuild where a project or topic stands. Read-only.

1. **Pin the scope.** Which project or topic, and how far back (default: the last 7 days). If either is unclear, ask one question and stop.
2. **Read only what matches the topic**, in this order:
    - My notes: `~/.claude/work/` and `~/.claude/oss/` (grep for the topic).
    - The repo's own record: `GLOSSARY.md`, `docs/adr/`, `docs/agents/`, and open specs and tickets in its issue tracker.
    - Recent sessions: `~/.claude/projects/<slug>/*.jsonl`, where `<slug>` is the project path with every non-alphanumeric character replaced by `-`. Take the newest by modification time (`ls -t`), grep for the topic, and read only the matching regions. Skip the current session.
    - Live state: `git status`, branches, worktrees, `gh pr list --author @me`.
3. **Brief** (one screen at most):
    - **Where it stands:** up to 5 bullets.
    - **Open threads:** one line each, tagged `[merged #N]`, `[open PR #N]`, `[in flight <branch>]`, `[uncommitted]` or `[planned]`.
    - **Next move:** the one most useful action.

Cite each point by file path, PR number or session file name.
