# Shared Git config lives at the XDG path, local Git config in ~/.gitconfig

`git maintenance register`, editor installers and other tools write to `~/.gitconfig` with `git config --global`. While that file was a symlink to the shared Git config, every such write dirtied the repo. Now the shared Git config sits at `~/.config/git/config` (the `config/git` folder, linked through `config_dirs`), and the local Git config is a real, untracked `~/.gitconfig` that setup creates empty if it is missing or a broken link. Git reads both files, writes `--global` changes to `~/.gitconfig` whenever it can read it, and lets its values override the shared Git config.

## Considered Options

- **`~/.gitconfig` as a generated local file that includes the shared one**: the same result, but setup would have to generate the file rather than link it.
- **`git maintenance register --config-file`**: only covers maintenance, has to be remembered every time, and does nothing about other tools writing `--global`.
- **`GIT_CONFIG_GLOBAL`**: the scheduled maintenance task doesn't see shell variables, so it would need a user-level environment variable on every machine.
- **Clean filter or `skip-worktree`**: hides the drift instead of preventing it.

## Consequences

- If `~/.gitconfig` is missing or unreadable, Git writes `--global` changes to the shared Git config again, so setup must create it.
- `git config --global --list` shows only `~/.gitconfig` when that file exists. Use `git config --list --show-origin` to see both.
- Relative `include` paths in the shared Git config resolve inside `~/.config/git/`, so files it includes live in `config/git/` too.
