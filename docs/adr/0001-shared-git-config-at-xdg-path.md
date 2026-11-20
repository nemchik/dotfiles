# Shared Git config lives at the XDG path, local Git config in ~/.gitconfig

`git maintenance register`, editor installers and other tools write to `~/.gitconfig` with `git config --global`. While that file was a symlink to the tracked config, every such write dirtied the repo. Now the tracked config sits at `~/.config/git/config` (the `config/git` folder, linked through `config_dirs`), and `~/.gitconfig` is a real, untracked file that setup creates empty if it is missing. Git reads both files, writes `--global` changes to `~/.gitconfig` whenever it exists, and lets its values override the XDG file.

## Considered Options

- **`~/.gitconfig` as a generated local file that includes the tracked one**: the same result, but setup would have to generate the file rather than link it.
- **`git maintenance register --config-file`**: only covers maintenance, has to be remembered every time, and does nothing about other tools writing `--global`.
- **`GIT_CONFIG_GLOBAL`**: the scheduled maintenance task doesn't see shell variables, so it would need a user-level environment variable on every machine.
- **Clean filter or `skip-worktree`**: hides the drift instead of preventing it.

## Consequences

- If `~/.gitconfig` is missing, Git writes `--global` changes to the tracked file again, so setup must create it.
- `git config --global --list` shows only `~/.gitconfig` when that file exists. Use `git config --list --show-origin` to see both.
- Relative `include` paths in the tracked config resolve inside `~/.config/git/`, so files it includes live in `config/git/` too.
