# Shortcut Cheat Sheet

This repo uses `Super` / `Win` as the main desktop modifier.

## Common Desktop Shortcuts

| Shortcut | Action |
| --- | --- |
| `Super+Enter` | Open Ghostty attached to tmux session `main` |
| `Super+Shift+Enter` | Open Ghostty |
| `Super+Space` | Open rofi app launcher |
| `Super+Q` | Close focused window |
| `Ctrl+Space` | Switch keyboard layout |
| `Super+F1` / `Super+F2` | Brightness down / up |
| `Super+F11` / `Super+F12` | Volume down / up |
| `Super+Shift+F12` | Toggle mute |
| `Super+F8` / `Super+F9` / `Super+F10` | Play-pause / previous / next |
| `Super+Shift+4` | Select screenshot region and copy to clipboard |
| `Super+Shift+B` | Open Bluetooth menu |
| `Super+Shift+N` | Open Wi-Fi menu |
| `Super+Ctrl+N` | Open NetworkManager connection editor |
| `Ctrl+Super+Q` | Lock screen |
| `Super+Shift+C` | Reload compositor config |
| `Super+Shift+E` | Exit compositor session |

## Sway

| Shortcut | Action |
| --- | --- |
| `Super+Arrow` | Move focus |
| `Super+Shift+Arrow` | Move focused window |
| `Super+1..9` | Switch workspace |
| `Ctrl+Super+Shift+1..9` | Move focused container to workspace |
| `Ctrl+Left` / `Ctrl+Right` | Previous / next workspace |
| `Super+N` | Move current workspace to the next active output |
| 3-finger swipe left / right | Next / previous workspace |

## Niri

| Shortcut | Action |
| --- | --- |
| `Super+Left` / `Super+Right` | Focus column left / right |
| `Super+Up` / `Super+Down` | Focus window up / down |
| `Super+Ctrl+Left` / `Super+Ctrl+Right` | Move column left / right |
| `Super+R` | Cycle preset column width |
| `Super+Shift+R` | Cycle preset window height |
| `Super+F` | Fullscreen window |
| `Super+Shift+F` | Maximize column |
| `Super+Shift+Left` / `Super+Shift+Right` | Focus monitor left / right |
| `Super+Ctrl+Shift+Left` / `Super+Ctrl+Shift+Right` | Move workspace to monitor left / right |
| `Super+1..9` | Focus workspace |
| `Super+Ctrl+1..9` | Move column to workspace |
| `Ctrl+Left` / `Ctrl+Right` | Workspace down / up |
| `Super+WheelScrollLeft/Right` | Focus column left / right |
| `Super+Ctrl+WheelScrollLeft/Right` | Move column left / right |
| `Super+WheelScrollUp/Down` | Workspace up / down |
| `Super+Ctrl+WheelScrollUp/Down` | Move column to workspace up / down |
| `Super+TouchpadScrollLeft/Right` | Focus column right / left |
| `Super+Ctrl+TouchpadScrollLeft/Right` | Move column right / left |
| `Super+TouchpadScrollUp/Down` | Workspace up / down |
| `Super+Ctrl+TouchpadScrollUp/Down` | Move column to workspace up / down |

Niri uses `Alt` as the nested-session modifier.

## Hyprland

| Shortcut | Action |
| --- | --- |
| `Super+Arrow` | Move focus |
| `Super+Shift+Arrow` | Move focused window |
| `Ctrl+Super+Arrow` | Resize active window |
| `Super+Mouse Left` | Move window |
| `Super+Mouse Right` | Resize window |
| `Super+1..9` | Switch workspace |
| `Ctrl+Super+Shift+1..9` | Move focused window to workspace |
| `Ctrl+Left` / `Ctrl+Right` | Previous / next workspace |
| `Super+N` | Move current workspace to the next active output |
| 3-finger horizontal gesture | Switch workspace |

## tmux

Default prefix is tmux's standard `Ctrl+B`.

| Shortcut | Action |
| --- | --- |
| `Ctrl+B s` | fzf session switcher |
| `Ctrl+B w` | fzf window switcher |
| `Ctrl+B p` | fzf pane switcher |
| `Ctrl+B b` | fzf buffer picker and paste |
| `Ctrl+B f` | Project/session picker via `tmux-sessionizer` |

Config defaults:

- Windows and panes start at index `1`.
- Mouse mode is enabled.
- Copy mode uses vi keys.

## Shell Aliases

| Alias | Command |
| --- | --- |
| `edsw` | `code ~/.config/sway/config` |
| `l` | `eza --icons --group-directories-first` |
| `la` | `eza --icons --all --group-directories-first` |
| `ll` | `eza --icons -l --time-style=long-iso --group-directories-first` |
| `lg` | `eza --icons -l --all --git --time-style=long-iso --group-directories-first` |
| `lll` | `eza --icons -l --sort=modified --time-style=long-iso --group-directories-first` |
| `cat` | `bat` |
| `ccat` | `/usr/bin/cat` |
| `grep` | `rg` |
| `chef` | Run CyberChef container on port `8080` |
| `gs` | `git status` |
| `gc` | `git commit -m` |
| `gf` | `git fetch --all` |
| `gp` | `git pull` |
| `gpp` | `git push` |
| `ga` | `git add` |
| `gaa` | `git add --all` |
| `gd` | `git diff` |
| `gds` | `git diff --staged` |
| `gb` | `git branch` |
| `gco` | `git checkout` |
| `gcb` | `git checkout -b` |
| `gl` | `git log --oneline --decorate --graph --all` |
| `grs` | `git restore` |
| `grst` | `git restore --staged` |

## Helper Function

| Function | Action |
| --- | --- |
| `ftpmd file_or_dir [...]` | Copy `files-to-prompt --markdown` output to the Wayland clipboard |

## Stow Commands

```bash
./stow-clean-restow.sh
./stow-clean-restow.sh shell sway
stow shell sway waybar ghostty tmux env hyprland niri
```

## Bootstrap

```bash
./bootstrap-fedora-dev.sh
```
