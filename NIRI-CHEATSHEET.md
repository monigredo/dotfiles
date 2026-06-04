# Niri Shortcut Cheat Sheet

This repo uses `Super` / `Win` as the main Niri modifier. Niri uses `Alt` as the nested-session modifier.

## Launchers And Session

| Shortcut | Action |
| --- | --- |
| `Super+Enter` | Open Ghostty attached to tmux session `main` |
| `Super+Shift+Enter` | Open Ghostty |
| `Super+Space` | Open rofi app launcher |
| `Super+Q` | Close focused window |
| `Ctrl+Space` | Switch keyboard layout |
| `Ctrl+Super+Q` | Lock screen |
| `Super+Shift+C` | Reload Niri config |
| `Super+Shift+E` | Exit Niri session |

## Windows And Columns

| Shortcut | Action |
| --- | --- |
| `Super+Left` / `Super+Right` | Focus column left / right |
| `Super+Up` / `Super+Down` | Focus window up / down |
| `Super+Ctrl+Left` / `Super+Ctrl+Right` | Move column left / right |
| `Super+R` | Cycle preset column width |
| `Super+Shift+R` | Cycle preset window height |
| `Super+F` | Fullscreen window |
| `Super+Shift+F` | Maximize column |

## Monitors And Workspaces

| Shortcut | Action |
| --- | --- |
| `Super+Shift+Left` / `Super+Shift+Right` | Focus monitor left / right |
| `Super+Ctrl+Shift+Left` / `Super+Ctrl+Shift+Right` | Move workspace to monitor left / right |
| `Super+1..9` | Focus workspace |
| `Super+Ctrl+1..9` | Move column to workspace |
| `Ctrl+Left` / `Ctrl+Right` | Workspace down / up |

## Pointer And Touchpad Navigation

| Shortcut | Action |
| --- | --- |
| `Super+WheelScrollLeft/Right` | Focus column left / right |
| `Super+Ctrl+WheelScrollLeft/Right` | Move column left / right |
| `Super+WheelScrollUp/Down` | Workspace up / down |
| `Super+Ctrl+WheelScrollUp/Down` | Move column to workspace up / down |
| `Super+TouchpadScrollLeft/Right` | Focus column right / left |
| `Super+Ctrl+TouchpadScrollLeft/Right` | Move column right / left |
| `Super+TouchpadScrollUp/Down` | Workspace up / down |
| `Super+Ctrl+TouchpadScrollUp/Down` | Move column to workspace up / down |

## System Controls

| Shortcut | Action |
| --- | --- |
| `Super+F1` / `Super+F2` | Brightness down / up |
| `Super+F11` / `Super+F12` | Volume down / up |
| `Super+Shift+F12` | Toggle mute |
| `Super+F8` / `Super+F9` / `Super+F10` | Play-pause / previous / next |
| `Super+Shift+4` | Select screenshot region and copy to clipboard |
| `Super+Shift+B` | Open Bluetooth menu |
| `Super+Shift+N` | Open Wi-Fi menu |
| `Super+Ctrl+N` | Open NetworkManager connection editor |

## Dotfiles Commands

```bash
./stow-clean-restow.sh
./stow-clean-restow.sh shell niri waybar ghostty tmux env
stow shell waybar ghostty tmux env niri
./bootstrap-fedora-dev.sh
```
