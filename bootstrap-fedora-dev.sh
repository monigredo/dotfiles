#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
LEGACY_GITCONFIG_PATH="$HOME/.gitconfig"

if [ -L "$LEGACY_GITCONFIG_PATH" ] && [ "$(readlink -f "$LEGACY_GITCONFIG_PATH")" = "$DOTFILES_DIR/git/.gitconfig" ]; then
  echo "[+] Removing legacy stowed ~/.gitconfig symlink..."
  rm -f "$LEGACY_GITCONFIG_PATH"
fi

echo "[+] Updating system..."
sudo dnf update -y

CORE_PACKAGES=(
  curl
  git
  gh
  zsh
  stow
  fzf
  ripgrep
  fd-find
  bat
  eza
  alacritty
  tmux
  htop
  wl-clipboard
  jq
  unzip
  dnf-plugins-core
  jetbrains-mono-fonts
  podman
  podman-docker
  podman-compose
  flatpak
  pipx
  direnv
)

SHARED_WAYLAND_PACKAGES=(
  waybar
  rofi-wayland
  grim
  slurp
  brightnessctl
  playerctl
  pavucontrol
  wireplumber
  nm-connection-editor
  mako
  lxqt-policykit
  xdg-desktop-portal
  xdg-desktop-portal-gtk
)

SWAY_PACKAGES=(
  sway
  swayidle
  swaylock
)

HYPRLAND_PACKAGES=(
  hyprland
  hypridle
  hyprlock
  qt6-qtwayland
  xdg-desktop-portal-hyprland
)

NIRI_PACKAGES=(
  niri
  xwayland-satellite
  xdg-desktop-portal-gnome
)

package_available() {
  dnf -q list --available "$1" </dev/null >/dev/null 2>&1 ||
    dnf -q list --installed "$1" </dev/null >/dev/null 2>&1
}

JAVA_PACKAGES=()

if package_available java-21-openjdk && package_available java-21-openjdk-devel; then
  JAVA_PACKAGES=(java-21-openjdk java-21-openjdk-devel)
elif package_available java-latest-openjdk && package_available java-latest-openjdk-devel; then
  JAVA_PACKAGES=(java-latest-openjdk java-latest-openjdk-devel)
elif package_available java-openjdk && package_available java-openjdk-devel; then
  JAVA_PACKAGES=(java-openjdk java-openjdk-devel)
else
  echo "[!] No supported OpenJDK package set found in enabled repositories; skipping Java install."
fi

echo "[+] Installing core CLI, shared Wayland desktop, and Sway packages..."
sudo dnf install -y \
  "${CORE_PACKAGES[@]}" \
  "${JAVA_PACKAGES[@]}" \
  "${SHARED_WAYLAND_PACKAGES[@]}" \
  "${SWAY_PACKAGES[@]}"

hyprland_install_mode="official"

if ! dnf -q list --available hyprland </dev/null >/dev/null 2>&1; then
  hyprland_install_mode="missing"
fi

echo "[+] Checking Hyprland package availability..."

if [ "$hyprland_install_mode" = "missing" ] && [ -t 0 ] && [ -r /dev/tty ]; then
  echo "[!] Hyprland packages are not available in the current enabled standard repositories."
  echo "    Fedora 43 currently needs an extra source such as the solopasha/hyprland COPR."
  echo "    COPR package sets can lag behind Fedora updates, so optional components like hyprland-qtutils may be unavailable."
  echo "    This is optional. You can skip Hyprland install and keep the Sway baseline only."
  echo "    Enable COPR solopasha/hyprland and install Hyprland packages? [y/N]" > /dev/tty
  read -r enable_hypr_copr < /dev/tty
  case "$enable_hypr_copr" in
    [yY]|[yY][eE][sS])
      echo "[+] Enabling COPR repository for Hyprland..."
      sudo dnf copr enable -y solopasha/hyprland
      hyprland_install_mode="copr"
      ;;
    *)
      hyprland_install_mode="skip"
      ;;
  esac
elif [ "$hyprland_install_mode" = "missing" ]; then
  echo "[!] Hyprland packages are not available in the current enabled standard repositories."
  echo "    Interactive terminal not available; skipping Hyprland package install."
  hyprland_install_mode="skip"
fi

if [ "$hyprland_install_mode" != "skip" ]; then
  echo "[+] Installing Hyprland session packages..."
  sudo dnf install -y "${HYPRLAND_PACKAGES[@]}"
  if [ "$hyprland_install_mode" = "copr" ]; then
    echo "    NOTE: Fedora 43 Hyprland support is currently COPR-based and may lag behind Fedora Qt updates."
    echo "    NOTE: Optional Hyprland packages such as hyprland-qtutils are not installed by bootstrap."
  fi
else
  echo "[+] Skipping Hyprland package install."
fi

niri_install_mode="install"

echo "[+] Checking Niri package availability..."

for pkg in "${NIRI_PACKAGES[@]}"; do
  if ! package_available "$pkg"; then
    echo "[!] Niri package '$pkg' is not available in the current enabled repositories."
    niri_install_mode="skip"
  fi
done

if [ "$niri_install_mode" = "install" ]; then
  echo "[+] Installing Niri session packages..."
  sudo dnf install -y "${NIRI_PACKAGES[@]}"
else
  echo "[+] Skipping Niri package install; required packages are unavailable."
fi

echo "[+] Installing dev fonts (JetBrains Mono + FiraCode Nerd Font)..."

# JetBrains Mono is installed via dnf above.
# Now install FiraCode Nerd Font into the user font dir.
FONTS_DIR="$HOME/.local/share/fonts"
mkdir -p "$FONTS_DIR"
cd "$FONTS_DIR"

if ! ls FiraCode*Nerd* >/dev/null 2>&1; then
  echo "    Downloading FiraCode Nerd Font..."
  tmpzip=$(mktemp)
  curl -L https://github.com/ryanoasis/nerd-fonts/releases/latest/download/FiraCode.zip -o "$tmpzip"
  unzip -o "$tmpzip" -d FiraCode-Nerd
  rm "$tmpzip"
else
  echo "    FiraCode Nerd Font already present, skipping download."
fi

echo "    Refreshing font cache..."
fc-cache -fv >/dev/null 2>&1 || true


echo "[+] Ensuring pipx path..."
pipx ensurepath || true

echo "[+] Installing files-to-prompt via pipx..."
pipx install files-to-prompt || true

echo "[+] Enabling rootless podman socket..."
systemctl --user enable --now podman.socket || true

echo "[+] Setting DOCKER_HOST export hint (add this to your shell rc manually if you want it global):"
echo "    export DOCKER_HOST=\"unix://\$XDG_RUNTIME_DIR/podman/podman.sock\""


echo "[+] Configuring global git defaults..."

# Create a global ignore file if it doesn't exist
if [ ! -f "$HOME/.gitignore_global" ]; then
  cat > "$HOME/.gitignore_global" << 'EOF'
# OS cruft
.DS_Store
Thumbs.db

# Editors / IDEs
*.swp
*~
.idea/
.vscode/

# Builds / deps
node_modules/
dist/
build/
target/
out/
EOF
  echo "    Created ~/.gitignore_global"
else
  echo "    ~/.gitignore_global already exists, leaving as-is."
fi

# Link git to use that global ignore
git config --global core.excludesfile "$HOME/.gitignore_global"

# Sensible defaults that are safe across users/clients
git config --global init.defaultBranch main
git config --global pull.rebase false
git config --global push.default simple
git config --global rerere.enabled true

# Editor: adjust if you prefer vim or code
if command -v nano >/dev/null 2>&1; then
  git config --global core.editor "nano"
fi

echo "    Git defaults configured (without user.name/user.email)."

echo "[+] Ensuring zsh is the default login shell..."
zsh_path="$(command -v zsh || true)"
if [ -n "$zsh_path" ]; then
  current_shell="$(getent passwd "$USER" | cut -d: -f7)"
  if [ "$current_shell" != "$zsh_path" ]; then
    if [ -t 0 ]; then
      read -r -p "    Change login shell for $USER from $current_shell to $zsh_path? [Y/n]: " change_shell
      case "$change_shell" in
        [nN]|[nN][oO])
          echo "    Leaving login shell unchanged."
          ;;
        *)
          if chsh -s "$zsh_path"; then
            echo "    Login shell changed to $zsh_path. Log out and back in for it to take effect."
          else
            echo "    WARNING: chsh failed; run: chsh -s $zsh_path" >&2
          fi
          ;;
      esac
    else
      echo "    Non-interactive shell detected; run later: chsh -s $zsh_path"
    fi
  else
    echo "    Login shell already set to $zsh_path."
  fi
else
  echo "    WARNING: zsh is not available after package install." >&2
fi

echo "[+] Configuring git identity (user.name / user.email)..."

# Only prompt if running interactively (has a TTY)
if [ -t 0 ]; then
  current_name="$(git config --global user.name 2>/dev/null || true)"
  current_email="$(git config --global user.email 2>/dev/null || true)"

  echo "    Current git user.name : ${current_name:-<not set>}"
  echo "    Current git user.email: ${current_email:-<not set>}"
  echo

  read -r -p "    Enter git user.name  [${current_name:-skip}]: " git_name
  read -r -p "    Enter git user.email [${current_email:-skip}]: " git_email

  git_name="${git_name:-$current_name}"
  git_email="${git_email:-$current_email}"

  if [ -n "$git_name" ]; then
    git config --global user.name "$git_name"
    echo "    Set git user.name  to: $git_name"
  else
    echo "    git user.name not changed."
  fi

  if [ -n "$git_email" ]; then
    git config --global user.email "$git_email"
    echo "    Set git user.email to: $git_email"
  else
    echo "    git user.email not changed."
  fi
else
  echo "    Non-interactive shell detected; skipping git identity prompts."
  echo "    You can set them later with:"
  echo "      git config --global user.name \"Your Name\""
  echo "      git config --global user.email \"you@example.com\""
fi

echo "[+] Optional: Node.js and npm setup..."
if [ -t 0 ]; then
  read -r -p "    Install Node.js + npm (for JS tooling / Codex CLI)? [y/N]: " install_node
  case "$install_node" in
    [yY]|[yY][eE][sS])
      "$DOTFILES_DIR/scripts/install-node.sh"
      ;;
    *)
      echo "    Skipping Node.js/npm install."
      ;;
  esac
else
  echo "    Non-interactive shell detected; skipping Node.js/npm prompt."
fi

echo "[+] Linking helper scripts into ~/.local/bin via stow..."
mkdir -p "$HOME/.local/bin"

for script in "$DOTFILES_DIR"/shell/.local/bin/*; do
  [ -f "$script" ] || continue
  target="$HOME/.local/bin/$(basename "$script")"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    echo "    Replacing existing $target with symlink from dotfiles."
    rm -f "$target"
  fi
done

if command -v stow >/dev/null 2>&1; then
  if ! (cd "$DOTFILES_DIR" && stow --target="$HOME" --restow shell); then
    echo "    WARNING: stow failed; check for conflicts in $HOME/.local/bin."
  fi
else
  echo "    WARNING: stow not found; skipping shell helper linking."
fi

echo "[+] Ensuring rofi-bluetooth helper..."
ROFI_BT_DIR="$HOME/code/rofi-bluetooth"
ROFI_BT_TARGET="$HOME/.local/bin/rofi-bluetooth"
mkdir -p "$HOME/code"

if [ -d "$ROFI_BT_DIR/.git" ]; then
  if ! git -C "$ROFI_BT_DIR" pull --ff-only; then
    echo "    WARNING: failed to update $ROFI_BT_DIR; continuing with existing clone."
  fi
else
  if ! git clone https://github.com/nickclyde/rofi-bluetooth.git "$ROFI_BT_DIR"; then
    echo "    WARNING: could not clone rofi-bluetooth; bluetooth menu will be missing."
    ROFI_BT_DIR=""
  fi
fi

if [ -n "${ROFI_BT_DIR:-}" ] && [ -f "$ROFI_BT_DIR/rofi-bluetooth" ]; then
  ln -sf "$ROFI_BT_DIR/rofi-bluetooth" "$ROFI_BT_TARGET"
  chmod +x "$ROFI_BT_TARGET"
fi

echo "[+] Checking required desktop commands..."
required_cmds=(
  sway
  swayidle
  swaylock
  waybar
  rofi
  alacritty
  grim
  slurp
  wl-copy
  brightnessctl
  playerctl
  wpctl
  pavucontrol
  nmtui
  nm-connection-editor
)

for cmd in "${required_cmds[@]}"; do
  if ! command -v "$cmd" >/dev/null 2>&1; then
    echo "    WARNING: missing command: $cmd" >&2
  fi
done

if [ "$hyprland_install_mode" != "skip" ]; then
  hyprland_required_cmds=(
    Hyprland
    hyprctl
    hypridle
    hyprlock
    mako
  )

  for cmd in "${hyprland_required_cmds[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "    WARNING: missing command: $cmd" >&2
    fi
  done

  required_files=(
    /usr/libexec/lxqt-policykit-agent
  )

  for path in "${required_files[@]}"; do
    if [ ! -x "$path" ]; then
      echo "    WARNING: missing executable: $path" >&2
    fi
  done
fi

if [ "$niri_install_mode" = "install" ]; then
  niri_required_cmds=(
    niri
    xwayland-satellite
  )

  for cmd in "${niri_required_cmds[@]}"; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
      echo "    WARNING: missing command: $cmd" >&2
    fi
  done

  if [ ! -f /usr/share/wayland-sessions/niri.desktop ]; then
    echo "    WARNING: missing Niri session file: /usr/share/wayland-sessions/niri.desktop" >&2
  fi
fi


echo "[+] Optional: Codex CLI binary install..."
if [ -t 0 ]; then
  read -r -p "    Install Codex CLI (binary, latest GitHub release)? [y/N]: " install_codex
  case "$install_codex" in
    [yY]|[yY][eE][sS])
      "$DOTFILES_DIR/scripts/install-codex-binary.sh"
      ;;
    *)
      echo "    Skipping Codex CLI install."
      ;;
  esac
else
  echo "    Non-interactive shell detected; skipping Codex CLI prompt."
fi

echo "[+] Remember to:"
echo "  - stow you dotfiles"
echo "  - Install JetBrains Toolbox manually (browser/wget) and set up IntelliJ."
echo "  - Install SDKMAN:  curl -s \"https://get.sdkman.io\" | bash"
echo "  - Run:   files-to-prompt --markdown ~/.zshrc ~/.config/sway/config  | wl-copy"
echo "    when you want to paste configs into ChatGPT."
