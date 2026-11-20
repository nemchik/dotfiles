# Coding standards

Judgement calls for review. Formatting and lint rules live in `.editorconfig` and tooling, not here.

## Setup scripts (`setup.sh`, `setup.ps1`)

The scripts stay small and uniform: every linked item goes through the same code path.

- **New items go in the existing lists** (`config_dirs`, `home_files`). An item that needs different handling changes the shared helper for every item, not a branch for that one item.
- **Behaviour changes apply to every item alike**, in both scripts, so `setup.sh` and `setup.ps1` stay parallel.
- **The scripts read no config files and take no new flags.** Data lives in the arrays at the top of each script; the menu and arguments stay as they are.
- **Keep each script close to its original size and shape.** A new function or a growth of more than a few lines needs a one-line reason in the PR body; flag one without a reason as Speculative Generality.
