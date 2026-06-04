# tmux Shortcut Cheat Sheet

Default prefix is tmux's standard `Ctrl+B`.

## Configured Bindings

| Shortcut | Action |
| --- | --- |
| `Ctrl+B s` | fzf session switcher |
| `Ctrl+B w` | fzf window switcher in the current session |
| `Ctrl+B p` | fzf pane switcher in the current window |
| `Ctrl+B b` | fzf buffer picker and paste |
| `Ctrl+B f` | Project/session picker via `tmux-sessionizer` |
| `Ctrl+B I` | Install TPM plugins |
| `Ctrl+B U` | Update TPM plugins |
| `Ctrl+B Alt+u` | Remove TPM plugins not listed in config |
| `Ctrl+B Ctrl-s` | Save tmux state with tmux-resurrect |
| `Ctrl+B Ctrl-r` | Restore tmux state with tmux-resurrect |

## Sessions

| Shortcut | Action |
| --- | --- |
| `Ctrl+B d` | Detach from tmux |
| `Ctrl+B $` | Rename current session |
| `Ctrl+B (` / `Ctrl+B )` | Previous / next session |
| `Ctrl+B L` | Switch to last session |

Useful commands:

```bash
tmux new -A -s main
tmux ls
tmux attach -t main
tmux kill-session -t main
```

## Windows

| Shortcut | Action |
| --- | --- |
| `Ctrl+B c` | New window |
| `Ctrl+B ,` | Rename current window |
| `Ctrl+B &` | Kill current window |
| `Ctrl+B n` | Next window |
| `Ctrl+B l` | Last window |
| `Ctrl+B 1..9` | Jump to window by index |

Note: `Ctrl+B p` is configured as the fzf pane switcher, so use the status bar, window number bindings, or `Ctrl+B w` for window navigation.

## Panes

| Shortcut | Action |
| --- | --- |
| `Ctrl+B %` | Split pane left/right |
| `Ctrl+B "` | Split pane top/bottom |
| `Ctrl+B Arrow` | Focus pane |
| `Ctrl+B z` | Toggle pane zoom |
| `Ctrl+B x` | Kill pane |
| `Ctrl+B !` | Break pane into a new window |
| `Ctrl+B {` / `Ctrl+B }` | Move pane left / right |
| `Ctrl+B Space` | Cycle pane layouts |

Mouse mode is enabled, so pane focus, resizing, and scrollback can also be controlled with the mouse.

## Copy Mode And Buffers

| Shortcut | Action |
| --- | --- |
| `Ctrl+B [` | Enter copy mode |
| `Ctrl+B ]` | Paste latest buffer |
| `Ctrl+B b` | Pick and paste a buffer with fzf |

Copy mode uses vi keys.

## Commands And Help

| Shortcut | Action |
| --- | --- |
| `Ctrl+B :` | tmux command prompt |
| `Ctrl+B ?` | List key bindings |
| `Ctrl+B t` | Show clock |

## Persistence Notes

Continuum saves every 15 minutes and restores when a tmux server starts. Resurrect can restore sessions, windows, panes, layouts, current directories, and supported editor session state, but not arbitrary process memory.
