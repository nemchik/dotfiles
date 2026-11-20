#!/usr/bin/env sh
# Rejects staged paths under config/.claude that its allowlist .gitignore does not cover.
# check-ignore --no-index tests the pattern even for files added with `git add -f`.
set -eu

bad=$(git -c core.quotePath=false diff --cached --name-only --diff-filter=ACMRT -- config/.claude |
    while IFS= read -r path; do
        if git check-ignore -q --no-index -- "$path"; then
            printf '  %s\n' "$path"
        fi
    done)

if [ -n "$bad" ]; then
    echo "config/.claude is allowlist-only. These staged paths are outside it:" >&2
    echo "$bad" >&2
    echo "Unstage them (git restore --staged <path>), or add them to config/.claude/.gitignore." >&2
    exit 1
fi
