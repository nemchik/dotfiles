#!/usr/bin/env sh

# https://typicode.github.io/husky/how-to.html#node-version-managers-and-guis
export FNM_COREPACK_ENABLED="true"
export FNM_RESOLVE_ENGINES="true"
export FNM_VERSION_FILE_STRATEGY="recursive"
eval "$(fnm env --use-on-cd || true)"
