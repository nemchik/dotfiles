# dotfiles

## Setup

Run as yourself, never as root or administrator.

- Linux, macOS, Termux: `./setup.sh` (menu), or `./setup.sh all`, `install` or `symlinks`. In a Codespace it runs everything automatically.
- Windows: `./setup.ps1`. Turn on Developer Mode first (Settings > System > For developers) so symbolic links work without administrator rights.

Close Claude Code before the first setup on a machine, because `~/.claude` gets merged and linked.

## Links

Setup links each item in `config/` into your home folder (`config_dirs` go to `~/.config`). When the destination already exists, setup:

1. Copies it over the repo copy, so its differences show up as unstaged changes in this clone. Review them in VS Code.
2. Moves the original to `~/.dotfiles-backup/<timestamp>/`. Backups are never deleted automatically.
3. Creates the link.

If the copy fails, setup warns and leaves that item untouched and unlinked. When copying a folder on Windows, junctions inside it stay junctions, but symbolic links are copied as their contents.

## Git config

The shared Git config is `config/git/`, linked to `~/.config/git/`. `~/.gitconfig` is the local Git config: untracked, for this machine only, and it overrides the shared one. Setup creates it empty if it's missing and otherwise leaves it alone. `git config --global`, `git maintenance register` and installers write there, so they never change the repo. See [docs/adr/0001](docs/adr/0001-shared-git-config-at-xdg-path.md).

`git config --global --list` shows only `~/.gitconfig`. To see every setting and the file it comes from, run `git config --list --show-origin`.

To move a machine set up before this change, do these before pulling it. Git stops working while `~/.gitconfig` links to a file that's gone.

1. Copy any machine-specific settings out of `config/.gitconfig` (for example `maintenance.repo` entries), then discard the changes to it.
2. Delete the `~/.gitconfig` and `~/.gitattributes` links, and put the saved settings in a new, real `~/.gitconfig`.
3. Pull, then run `./setup.sh symlinks` or `./setup.ps1`.

## Machine-local links

Some folders under `config/.claude/work/` or `config/.claude/oss/` live elsewhere, for example in a synced cloud folder that doubles as their backup. Link them once by hand on the machines that need them. Their contents are gitignored. On Windows:

```powershell
New-Item -ItemType Junction -Path config\.claude\work\acme -Target "$env:OneDriveCommercial\claude\acme"
```
