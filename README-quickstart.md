# Fedora + Sway dotfiles – Quickstart for a NEW user

This is the **short, command-only** checklist to bring a fresh user into your standard dev environment.

---

## 0. Create the user (run as root / another admin)

Replace \`user\` with the new username (or \`client_x\` for a client persona):

```bash
sudo useradd -m -s /bin/bash user
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

This installs packages, fonts, git defaults, and **prompts for git user.name/email**. It also installs \`rofi-bluetooth\` from GitHub and links it into \`~/.local/bin\` for you:

```bash
cd ~/dotfiles
./bootstrap-fedora-dev.sh
```

---

## 4. Stow dotfiles

```bash
cd ~/dotfiles
stow shell
stow sway
stow waybar
stow alacritty
stow git
stow env
```

If \`stow\` reports conflicts, resolve them (move/delete old files) and re-run.

---

## 5. Log out and back into Sway

- Log out of the session.
- Log back in and start Sway (your usual way).

This picks up:
- Sway config + keybinds
- Waybar config
- Alacritty config
- Shell/git config
- Helper scripts in \`~/.local/bin\`

---

## 6. Quick sanity checks (optional)

In a new terminal (Alacritty inside Sway):

```bash
# Check swayidle is running (idle lock)
ps aux | grep '[s]wayidle'

# Check wifi menu
wifi-menu

# Check bluetooth menu
rofi-bluetooth
```

If those work and Sway keybindings feel right, the new user is fully bootstrapped.
