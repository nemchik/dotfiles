# Dotfiles

Personal configuration shared across machines, plus the setup that puts it in place.

## Language

**Shared Git config**:
The tracked Git settings, the same on every machine.
_Avoid_: global config, gitconfig

**Local Git config**:
The untracked Git settings for one machine, including anything tools write. It overrides the **Shared Git config**.
_Avoid_: global config, private config, machine config
