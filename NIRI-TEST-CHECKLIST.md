# Niri Test Checklist

Use this checklist to test the additive Niri session on a fresh Fedora user without disturbing an existing primary user.

## 1. Create a dedicated test user

From an existing admin account:

```bash
sudo dnf install -y zsh
sudo useradd -m -s /usr/bin/zsh niri_test
sudo passwd niri_test
sudo usermod -aG wheel niri_test
```

Log out, then log in as `niri_test`.

## 2. Install minimal prerequisites

As `niri_test`:

```bash
sudo dnf install -y git stow
```

## 3. Clone the repo

If cloning from the local checkout on this machine:

```bash
cd ~
git clone /home/user3/dotfiles ~/dotfiles
cd ~/dotfiles
git checkout wayland-experiments
```

If cloning from GitHub instead:

```bash
cd ~
git clone <your-dotfiles-remote-url> ~/dotfiles
cd ~/dotfiles
git checkout wayland-experiments
```

## 4. Run bootstrap

```bash
cd ~/dotfiles
./bootstrap-fedora-dev.sh
```

During bootstrap:

- Say `yes` to Niri if prompted.
- Hyprland is optional for this test.

## 5. Stow the configs

```bash
cd ~/dotfiles
stow shell sway waybar ghostty tmux env hyprland niri
```

## 6. Log out and choose Niri in GDM

At the Fedora login screen:

- choose `Niri`
- log in as `niri_test`

## 7. In-session checks

Run:

```bash
ps aux | grep '[n]iri'
ps aux | grep '[s]wayidle'
ls -l ~/.config/niri/config.kdl ~/.config/waybar-niri/config ~/.config/waybar-niri/style.css
wifi-menu
rofi-bluetooth
```

## 8. Manual checks inside Niri

- Waybar appears.
- `Super+Return` opens Ghostty + tmux.
- `Super+Shift+Return` opens plain Ghostty.
- `Super+Space` opens rofi.
- `Ctrl+Super+Q` locks the screen.
- `Super+Shift+X` toggles Caffeinate mode and shows/hides its Waybar indicator.
- The Waybar Home/Travel module toggles between Home and Travel mode.
- `Super+Shift+4` screenshot flow works.
- An X11 app launches if available.
- Home mode on AC power locks but does not suspend on lid close.
- Travel mode locks and suspends on lid close.
- Caffeinate mode locks but does not suspend on lid close.
- External monitor lid close does not lock or suspend.

## 9. If something fails

Record:

- which step failed
- any terminal output
- whether failure happened during bootstrap, stow, GDM login, or inside the Niri session
