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

## Machine-local links

Some folders under `config/.claude/work/` or `config/.claude/oss/` live elsewhere, for example in a synced cloud folder that doubles as their backup. Link them once by hand on the machines that need them. Their contents are gitignored. On Windows:

```powershell
New-Item -ItemType Junction -Path config\.claude\work\acme -Target "$env:OneDriveCommercial\claude\acme"
```

## Hooks

Run `lefthook install` once per clone. The `pre-commit` hook rejects staged files under `config/.claude` that its allowlist ignores (see `config/.claude/README.md`).
