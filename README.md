# Fedora + Sway/Hyprland Dev Dotfiles

Opinionated dotfiles for a **dev-focused Fedora + Sway/Hyprland** setup on a Framework 13 AMD (or similar laptop).

Goals:

- Keyboard-driven Wayland workflow (Sway + Hyprland + Waybar).
- Reproducible setup via **GNU Stow**.
- Good defaults for **development**: git, Java, containers, Alacritty, rofi.
- Small helper scripts in `~/.local/bin` for:
  - idle locking,
  - lid handling,
  - Wi-Fi TUI,
  - Bluetooth control via rofi.

> Target OS: **Fedora Workstation (Wayland)** with **Sway**, **Hyprland**, and **NetworkManager**.

---

## 0. Host prep (one-time, as admin/root)

From an existing admin user (or root), create a new user:

```bash
sudo useradd -m -s /bin/bash user
sudo passwd user
sudo usermod -aG wheel user
```

Then log into that user (TTY or display manager) and do everything else **as that user**.

> For a per-client persona, just use another username, e.g. `client_x`, same steps.

---

## 1. Install minimal tools to fetch dotfiles

Fedora Workstation usually has `git`, but make sure:

```bash
sudo dnf install -y git stow
```

---

## 2. Clone dotfiles

```bash
cd ~
git clone git@github.com:YOURUSER/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

If you prefer HTTPS:

```bash
git clone https://github.com/YOURUSER/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

---

## 3. Run the bootstrap script

Run the dev bootstrap script:

```bash
./bootstrap-fedora-dev.sh
```

What it does:

- **System packages** via `dnf`:
  - Core CLI tools:  
    `git`, `zsh`, `fzf`, `ripgrep`, `fd-find`, `bat`, `tmux`, `htop`, `wl-clipboard`, `jq`, `unzip`, etc.
  - Sway desktop runtime:
    `sway`, `swayidle`, `swaylock`, `waybar`, `rofi-wayland`, `grim`, `slurp`, `brightnessctl`, `playerctl`, `pavucontrol`, `wireplumber`, `nm-connection-editor`
  - Hyprland desktop runtime:
    `hyprland`, `hypridle`, `hyprlock`, `mako`, `lxqt-policykit`, `xdg-desktop-portal`, `xdg-desktop-portal-hyprland`, `xdg-desktop-portal-gtk`, `qt6-qtwayland`
    - On Fedora 43, this path is currently experimental and may require the `solopasha/hyprland` COPR when `hyprland` is not available in the enabled standard Fedora repos.
    - COPR package sets can lag behind Fedora updates; optional components such as `hyprland-qtutils` may be unavailable or temporarily incompatible.
    - You can skip Hyprland install and keep a Sway-only baseline.
  - Containers:  
    `podman`, `podman-docker`, `podman-compose`
  - Java:  
    `java-21-openjdk`, `java-21-openjdk-devel`
  - Misc:  
    `flatpak`, `pipx`, `jetbrains-mono-fonts`, `NetworkManager-tui`, `gh`, and others as added.
- **pipx & CLI helper**:
  - `pipx ensurepath`
  - `pipx install files-to-prompt`
- **Fonts**:
  - Installs JetBrains Mono (via `dnf`).
  - Downloads **FiraCode Nerd Font** into `~/.local/share/fonts/FiraCode-Nerd` and runs `fc-cache`.
- **Git defaults**:
  - Creates `~/.gitignore_global` (common junk: `.idea/`, `.vscode/`, `node_modules/`, build dirs, etc.).
  - Sets:
    - `core.excludesfile = ~/.gitignore_global`
    - `init.defaultBranch = main`
    - `pull.rebase = false`
    - `push.default = simple`
    - `rerere.enabled = true`
    - `core.editor = nano` (if available).
- **Git identity (interactive)**:
  - If running in a TTY, shows current `user.name` / `user.email` (if any).
  - Prompts:
    - `git user.name`
    - `git user.email`
  - Empty input keeps current values.
  - For a **client-specific user**, enter the client persona identity here.

If run non-interactively, it skips identity prompts and prints manual `git config` commands.

---

## 4. Install Bluetooth helper (`rofi-bluetooth`)

This is not in the repo; you install it once per user.

```bash
mkdir -p ~/code
cd ~/code

git clone https://github.com/nickclyde/rofi-bluetooth.git
mkdir -p ~/.local/bin
cp ~/code/rofi-bluetooth/rofi-bluetooth ~/.local/bin/
chmod +x ~/.local/bin/rofi-bluetooth
```

Check:

```bash
command -v rofi-bluetooth
```

You should see `/home/<user>/.local/bin/rofi-bluetooth`.

---

## 5. Create local helper scripts

These live in `~/.local/bin`. Some are also mirrored under `~/dotfiles/shell/.local/bin` – adapt as your repo evolves.

### 5.1 `wifi-menu` – Wi-Fi TUI via Alacritty + `nmtui`

```bash
mkdir -p ~/.local/bin

cat > ~/.local/bin/wifi-menu << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

alacritty -e nmtui
EOF

chmod +x ~/.local/bin/wifi-menu
```

### 5.2 `sway-handle-lid.sh` – lid close logic

Locks and suspends **only** when no external monitor is active.

```bash
cat > ~/.local/bin/sway-handle-lid.sh << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Internal laptop display name in Sway (change if not eDP-1)
LAPTOP_OUTPUT="${LAPTOP_OUTPUT:-eDP-1}"

# Count active outputs other than the laptop panel
OTHER_COUNT=$(swaymsg -t get_outputs -r   | jq --arg name "$LAPTOP_OUTPUT" '[.[] | select(.active == true and .name != $name)] | length')

if [ "$OTHER_COUNT" -eq 0 ]; then
  # No external monitors: lock + suspend
  if command -v swaylock >/dev/null 2>&1; then
    swaylock -f -c 000000 &
    sleep 0.2
  fi

  systemctl suspend
fi
EOF

chmod +x ~/.local/bin/sway-handle-lid.sh
```

### 5.3 `run-swayidle` – idle lock coordinator (argument-based timeout)

In the **dotfiles** repo (so it’s stowed for any user), create:

```bash
cd ~/dotfiles
mkdir -p shell/.local/bin

cat > shell/.local/bin/run-swayidle << 'EOF'
#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   run-swayidle [timeout_seconds]
# Default lock timeout: 900 seconds (15 minutes)
TIMEOUT="${1:-900}"
DPMS_DELAY=30
DPMS_TIMEOUT=$((TIMEOUT + DPMS_DELAY))

# Kill any old instance so we don't stack them
pkill -x swayidle 2>/dev/null || true

exec swayidle -w \
  timeout "$TIMEOUT" 'swaylock -f -c 000000' \
  timeout "$DPMS_TIMEOUT" 'swaymsg "output * dpms off"' \
  resume 'swaymsg "output * dpms on"' \
  before-sleep 'swaylock -f -c 000000'
EOF

chmod +x shell/.local/bin/run-swayidle
```

The script locks after the chosen timeout and then turns displays off 30 seconds later until you resume activity.

Then stow `shell` (later step) so `~/.local/bin/run-swayidle` is a symlink.

---

## 6. Stow the dotfiles

From `~/dotfiles`:

```bash
cd ~/dotfiles

stow shell
stow sway
stow waybar
stow alacritty
stow tmux
stow env
stow hyprland
```

What each package is expected to do:

- `shell/`
  - `~/.bashrc`, `~/.bash_profile`, `~/.profile`:
    - ensure `~/.local/bin` and `~/bin` are in PATH for shells.
    - aliases (`ls → eza` if installed, `cat → bat`, `grep → rg`, etc.).
  - `~/.local/bin/run-swayidle` (from above).
  - `~/.local/bin/mullvad-autoconnect` (connects on login if disconnected).
- `sway/`
  - `~/.config/sway/config`:
    - Alt as main modifier.
    - Keybindings (see cheat sheet below).
    - Lid binding → `sway-handle-lid.sh`.
    - Idle lock → `exec_always ~/.local/bin/run-swayidle 3000` (locks after 50 minutes; turns displays off 30s after locking).
    - Mullvad autoconnect → `exec_always ~/.local/bin/mullvad-autoconnect`.
- `waybar/`
  - `~/.config/waybar/config` and `style.css`:
    - Right-side modules: CPU, memory, network, Mullvad + Proton VPN indicators, **bluetooth**, audio, temp, battery, clock.
    - `on-click` for Mullvad → `~/.local/bin/mullvad-waybar` (toggle).
    - `on-click` for Proton VPN → `~/.local/bin/protonvpn-waybar` (toggle).
    - `on-click` for bluetooth → `~/.local/bin/rofi-bluetooth`.
    - `on-click` for network → `~/.local/bin/wifi-menu`.
- `alacritty/`
  - `~/.config/alacritty/alacritty.toml`:
    - JetBrains Mono; dark theme; padding.
    - `TERM=xterm-256color` for SSH compatibility.
    - OSC52 copy enabled with `OnlyCopy`.
- `tmux/`
  - `~/.config/tmux/tmux.conf`:
    - `default-terminal` uses `tmux-256color` when available, else `screen-256color`.
    - Truecolor and clipboard terminal features for Alacritty.
    - Vi copy-mode + sane history/window defaults.
    - fzf-powered switchers for sessions/windows/panes/buffers.
- `env/`
  - Optional: `~/.config/environment.d/10-local-bin.conf` if you decide to keep it.  
    GUI config mostly uses explicit `~/.local/bin/...`, so this is optional.
- `hyprland/`
  - `~/.config/hypr/hyprland.conf`, `hypridle.conf`, `hyprlock.conf`
  - `~/.config/mako/config`
  - `~/.config/waybar-hypr/config` and `style.css`
  - Hyprland-specific session glue while preserving the existing Sway package.

If `stow` complains about conflicts, move the existing file into the appropriate place under `~/dotfiles/...` and re-run `stow`.

---

## 7. Wire scripts into Sway and Waybar

### 7.1 Idle locking via `run-swayidle`

In `~/.config/sway/config` (managed by `stow`):

```sway
# Idle lock: 50 minutes + screen off 30s after lock + lock before sleep
exec_always ~/.local/bin/run-swayidle 3000
```

To test quickly, you can temporarily use `10` instead of `900`, reload Sway, and see if it locks after ~10s of inactivity.

### 7.2 Lid behavior

Same file, Sway config:

```sway
# Lid handling: suspend only when no external monitor
bindswitch --locked --reload lid:on exec ~/.local/bin/sway-handle-lid.sh
```

Behavior:

- **Laptop only**: lid close → `swaylock` then `systemctl suspend`.
- **Laptop + external monitor**: lid close → no suspend, no lock (you lock manually).

### 7.3 Mullvad autoconnect

In `~/.config/sway/config`:

```sway
# Mullvad autoconnect after login
exec_always ~/.local/bin/mullvad-autoconnect
```

### 7.4 Waybar: Bluetooth widget

In `~/.config/waybar/config`:

```jsonc
"bluetooth": {
  "format": " {status}",
  "format-disabled": "",
  "format-connected": " {num_connections} connected",
  "tooltip-format": "{controller_alias}	{controller_address}",
  "tooltip-format-connected": "{controller_alias}	{controller_address}

{device_enumerate}",
  "tooltip-format-enumerate-connected": "{device_alias}	{device_address}",
  "on-click": "~/.local/bin/rofi-bluetooth"
},
```

Add `"bluetooth"` into `"modules-right"`:

```jsonc
"modules-right": [
  "cpu",
  "memory",
  "network",
  "custom/mullvad",
  "custom/protonvpn",
  "bluetooth",
  "pulseaudio",
  "temperature",
  "battery",
  "clock"
],
```

In `style.css`:

```css
#bluetooth {
  padding: 0 8px;
}

#bluetooth.connected {
  color: #a3be8c;
}
#bluetooth.disconnected {
  color: #d8dee9;
}
#bluetooth.off {
  color: #bf616a;
}
```

### 7.5 Waybar: Network widget → `wifi-menu`

In `~/.config/waybar/config` network module:

```jsonc
"network": {
  // existing fields (interface, format, etc.)
  "on-click": "~/.local/bin/wifi-menu"
},
```

Clicking the network icon opens `nmtui` in Alacritty.

---

## 8. Sway keybindings

In `~/.config/sway/config` you should have (or add):

### Core

- **Mod key**: `Alt` (`Mod1`).
- `Alt+Enter` – Alacritty into persistent tmux session (`main`).
- `Alt+Shift+Enter` – Alacritty (terminal).
- `Alt+Space` – rofi app launcher.
- `Alt+Q` – close window.

### Focus / move windows

- `Alt+Arrow` – move focus.
- `Alt+Shift+Arrow` – move window.

### Workspaces

- `Alt+1..9` – switch to workspace.
- `Alt+Shift+1..9` – move focused container to workspace.
- `Ctrl+Left/Right` – prev/next workspace.
- 3-finger swipe left/right – workspace navigation (via your gesture setup).

### Media / brightness

- `Alt+F1/F2` – brightness down/up.
- `Alt+F11/F12` – volume down/up.
- `Alt+Shift+F12` – mute.
- `Alt+F8/F9/F10` – play-pause / prev / next (`playerctl`).

### Network & Bluetooth helpers

```sway
# Bluetooth menu (rofi)
bindsym $mod+Shift+b exec ~/.local/bin/rofi-bluetooth

# Wi-Fi menu (nmtui in Alacritty)
bindsym $mod+Shift+n exec ~/.local/bin/wifi-menu

# Full GUI network editor
bindsym $mod+Ctrl+n exec nm-connection-editor
```

### Locking

```sway
# Manual lock
bindsym Ctrl+Alt+q exec swaylock -f -c 000000
```

- Auto-lock after `run-swayidle` timeout (currently 3000s) and turn screens off 30s later.
- Lid close → `sway-handle-lid.sh`.

---

## 9. Files-to-prompt helper (for debugging configs)

Add this to `~/.bashrc` (or `shell/.bashrc` in dotfiles):

```bash
ftpmd() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: ftpmd file_or_dir [more...]" >&2
    return 1
  fi
  files-to-prompt --markdown "$@" | wl-copy
  echo "Copied files-to-prompt output for: $*" >&2
}
```

Example usage:

```bash
ftpmd ~/.bashrc ~/.config/sway/config ~/.config/waybar/config
```

Then paste directly into ChatGPT when debugging.

---

## 10. Terminal: Alacritty + tmux

- Sway launch:
  - `Alt+Enter` starts `alacritty -e tmux new-session -A -s main` (reattach/create `main`).
- Manual launch:
  - `tmux new -A -s main`
- Clipboard model:
  - Alacritty enables OSC52 with `OnlyCopy` (copy out allowed, clipboard reads blocked).
  - tmux `set-clipboard` is auto-selected (`external` on tmux >= 2.6, `on` on older tmux).
  - This supports local Wayland clipboard copy and remote SSH copy via OSC52-capable terminals.

### 10.1 fzf-powered tmux navigation

Dependencies:
- Required: `fzf` (includes `fzf-tmux` on Fedora package builds).
- Optional but useful for project picking: `fd`/`fd-find`, `ripgrep`.

Bindings (tmux prefix + key):
- `s` — Session switcher (`fzf-tmux` popup).
- `w` — Window switcher in current session (`fzf-tmux` popup).
- `p` — Pane switcher in current window (`fzf-tmux` popup).
- `b` — Buffer selector + paste (`fzf-tmux` popup).
- `f` — `tmux-sessionizer` project picker (`~/.local/bin/tmux-sessionizer`).

Notes:
- If `fzf` / `fzf-tmux` is missing, tmux shows a message instead of failing.
- `tmux-sessionizer` scans project roots (`~/code`, `~/workdir`, `~/Documents`) for git repos, then creates/switches to a session based on selected directory name.

---

## 11. Typical “new user / new client persona” flow

For a fresh user (personal or client-specific):

1. **Create user + add to `wheel`** (from admin):

   ```bash
   sudo useradd -m -s /bin/bash client_x
   sudo passwd client_x
   sudo usermod -aG wheel client_x
   ```

2. **Log in as `client_x`**.

3. **Install `git` and `stow`** (if needed):

   ```bash
   sudo dnf install -y git stow
   ```

4. **Clone dotfiles**:

   ```bash
   git clone git@github.com:YOURUSER/dotfiles.git ~/dotfiles
   cd ~/dotfiles
   ```

5. **Run bootstrap**:

   ```bash
   ./bootstrap-fedora-dev.sh
   ```

   - At git identity prompt: set `user.name` / `user.email` for this persona (e.g. client identity).

6. **Install `rofi-bluetooth`** (once per user):

   ```bash
   mkdir -p ~/code
   cd ~/code
   git clone https://github.com/nickclyde/rofi-bluetooth.git
   mkdir -p ~/.local/bin
   cp ~/code/rofi-bluetooth/rofi-bluetooth ~/.local/bin/
   chmod +x ~/.local/bin/rofi-bluetooth
   ```

7. **Ensure helper scripts exist** (either in dotfiles or recreate):

   - `~/.local/bin/wifi-menu`
   - `~/.local/bin/sway-handle-lid.sh`
   - `~/.local/bin/run-swayidle` (via `stow shell`)
   - `~/.local/bin/tmux-sessionizer` (via `stow shell`, optional)

8. **Stow configs**:

   ```bash
   cd ~/dotfiles
   stow shell sway waybar alacritty tmux env
   ```

9. **Log out and choose a session in GDM** to ensure environment + configs are applied.
   - Choose `Sway` to keep the current workflow.
   - Choose `Hyprland` to test the additive migration path on the same user.

After that, the new user has:

- Same Sway/Waybar behavior,
- Same dev tools and fonts,
- Their own git identity,
- Correct lid + idle behavior,
- Bluetooth & Wi-Fi helpers wired in.

---

## 12. Troubleshooting

- **Stow conflicts**  
  Move or delete conflicting files under `$HOME`, then re-run `stow`. Conflicts mean there was an existing non-symlink file where Stow wants to place a symlink.

- **Idle lock not working**  
  Check:

  ```bash
  ps aux | grep '[s]wayidle'
  ```

  You should see a `swayidle` process. If not, confirm this line exists in `sway/config` and the script is executable:

  ```sway
  exec_always ~/.local/bin/run-swayidle 3000
  ```

- **Bluetooth menu doesn’t open from widget/hotkey**  
  Confirm:

  ```bash
  command -v rofi-bluetooth
  ls -l ~/.local/bin/rofi-bluetooth
  ```

  And check Waybar/Sway use `~/.local/bin/rofi-bluetooth`, not just `rofi-bluetooth`.

- **Wi-Fi menu doesn’t open**  
  Make sure `wifi-menu` exists and is executable:

  ```bash
  ls -l ~/.local/bin/wifi-menu
  ```

  And that the Waybar network `on-click` and Sway bindings point to `~/.local/bin/wifi-menu`.

- **tmux binding shows “fzf not installed”**  
  Install `fzf` and ensure `fzf-tmux` is on `PATH`.

- **tmux popup picker doesn’t render correctly**  
  Your tmux version may not support popup mode well; switch `fzf-tmux -p 80%,60%` to split mode (for example `fzf-tmux -d 40%`) in `~/.config/tmux/tmux.conf`.

---

This README is meant to be your full “rebuild from scratch” guide:  
new user → dotfiles → bootstrap → stow → Sway/Waybar/scripts wired → dev-ready environment.
