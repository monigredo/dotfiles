# Fedora + Sway/Hyprland/Niri dotfiles – Quickstart for a NEW user

This is the **short, command-only** checklist to bring a fresh user into your standard dev environment.

---

## 0. Create the user (run as root / another admin)

Replace \`user\` with the new username (or \`client_x\` for a client persona):

```bash
sudo dnf install -y zsh
sudo useradd -m -s /usr/bin/zsh user
sudo passwd user
sudo usermod -aG wheel user
```

Log out and log in as this new user.

---

## 1. Install minimal tools (as the new user)

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

(If you need HTTPS:)

```bash
cd ~
git clone https://github.com/YOURUSER/dotfiles.git ~/dotfiles
cd ~/dotfiles
```

---

## 3. Run bootstrap script

This installs packages, fonts, git defaults, and **prompts for git user.name/email**. It also prompts to set `zsh` as your login shell, installs \`rofi-bluetooth\` from GitHub, and links it into \`~/.local/bin\` for you:

```bash
cd ~/dotfiles
./bootstrap-fedora-dev.sh
```

During bootstrap:

- Hyprland may prompt for an extra COPR-backed install path on Fedora 43 if it is not available in the enabled standard repos.
- Niri installs by default when it is available in the enabled standard Fedora repos.

---

## 4. Stow dotfiles

```bash
cd ~/dotfiles
stow shell
stow sway
stow waybar
stow alacritty
stow tmux
stow env
stow hyprland
stow niri
```

If \`stow\` reports conflicts, resolve them (move/delete old files) and re-run.

---

## 5. Log out and choose a session in GDM

- Log out of the session.
- At the Fedora login screen, choose either:
  - `Sway`
  - `Hyprland`
  - `Niri`

This picks up:
- Sway config + keybinds
- Hyprland config
- Niri config
- Waybar config
- Alacritty config
- Shell config
- Helper scripts in \`~/.local/bin\`

---

## 6. Quick sanity checks (optional)

In a new terminal after logging into the session you want to test:

```bash
# Check idle lock helper
ps aux | grep '[s]wayidle'

# Check wifi menu
wifi-menu

# Check bluetooth menu
rofi-bluetooth
```

For `Niri`, also check:

```bash
# Confirm the Niri session process exists
ps aux | grep '[n]iri'

# Confirm the Niri-specific Waybar config was stowed
ls -l ~/.config/waybar-niri/config ~/.config/waybar-niri/style.css
```

Expected manual checks by session:

- `Sway`: Waybar appears, terminal/launcher open, idle lock works.
- `Hyprland`: Hyprland starts, Hyprland Waybar appears, lock and lid handling still work.
- `Niri`: Niri starts from GDM, Niri Waybar appears, terminal/launcher open, at least one X11 app launches, and idle lock works.

If those work and the chosen session behaves correctly, the new user is fully bootstrapped.
