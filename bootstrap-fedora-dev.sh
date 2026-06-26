#!/usr/bin/env bash
set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "$0")" && pwd)"
DEV_VERSIONS_FILE="$DOTFILES_DIR/config/dev-versions.sh"
LEGACY_GITCONFIG_PATH="$HOME/.gitconfig"
DEFAULT_GIT_EMAIL="8849111+monigredo@users.noreply.github.com"

NODE_PACKAGE_CANDIDATES=(nodejs)
NPM_PACKAGE_CANDIDATES=(npm)
JAVA_PACKAGE_CANDIDATES=(java-21-openjdk java-latest-openjdk java-openjdk)
GO_PACKAGE_CANDIDATES=(golang)
PYTHON_DEV_PACKAGES=(python3-pip python3-devel python3-virtualenv python3-pytest python3-ruff uv)
SHELL_DEV_PACKAGES=(ShellCheck)
KOTLIN_SDKMAN_CANDIDATE=kotlin
VSCODE_PACKAGE=code
VSCODE_EXTENSIONS=()

if [ -f "$DEV_VERSIONS_FILE" ]; then
  # shellcheck source=/dev/null
  source "$DEV_VERSIONS_FILE"
else
  echo "[!] Missing $DEV_VERSIONS_FILE; using built-in bootstrap defaults."
fi

FALLBACK_WARNINGS=()
BOOTSTRAP_FALLBACK_LOG="$(mktemp)"
export BOOTSTRAP_FALLBACK_LOG

cleanup_bootstrap() {
  rm -f "$BOOTSTRAP_FALLBACK_LOG"
}
trap cleanup_bootstrap EXIT

record_fallback_warning() {
  local message="$1"

  echo >&2
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
  echo "!! BOOTSTRAP VERSION FALLBACK" >&2
  echo "!! $message" >&2
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
  echo >&2

  printf '%s\n' "$message" >> "$BOOTSTRAP_FALLBACK_LOG"
}

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

resolve_first_available_package() {
  local label="$1"
  shift

  local preferred="${1:-}"
  local candidate

  for candidate in "$@"; do
    if package_available "$candidate"; then
      if [ -n "$preferred" ] && [ "$candidate" != "$preferred" ]; then
        record_fallback_warning "$label: preferred package '$preferred' unavailable; using '$candidate'."
      fi
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  if [ -n "$preferred" ]; then
    record_fallback_warning "$label: none of the preferred packages are available: $*."
  fi
  return 1
}

install_available_packages() {
  local label="$1"
  shift

  local packages=()
  local pkg

  for pkg in "$@"; do
    if package_available "$pkg"; then
      packages+=("$pkg")
    else
      record_fallback_warning "$label: package '$pkg' is unavailable and will be skipped."
    fi
  done

  if [ "${#packages[@]}" -gt 0 ]; then
    sudo dnf install -y "${packages[@]}"
  else
    echo "    No available $label packages to install."
  fi
}

JAVA_PACKAGES=()

if java_package="$(resolve_first_available_package "Java runtime" "${JAVA_PACKAGE_CANDIDATES[@]}")"; then
  java_devel_package="${java_package}-devel"
  if package_available "$java_devel_package"; then
    JAVA_PACKAGES=("$java_package" "$java_devel_package")
  else
    JAVA_PACKAGES=("$java_package")
    record_fallback_warning "Java development package '$java_devel_package' unavailable; installing runtime only."
  fi
else
  echo "[!] No supported OpenJDK package set found in enabled repositories; skipping Java install."
fi

echo "[+] Installing core CLI, shared Wayland desktop, and Sway packages..."
sudo dnf install -y \
  "${CORE_PACKAGES[@]}" \
  "${JAVA_PACKAGES[@]}" \
  "${SHARED_WAYLAND_PACKAGES[@]}" \
  "${SWAY_PACKAGES[@]}"

ghostty_install_mode="install"

echo "[+] Checking Ghostty package availability..."

if ! package_available ghostty; then
  ghostty_install_mode="missing"
fi

if [ "$ghostty_install_mode" = "missing" ] && [ -t 0 ] && [ -r /dev/tty ]; then
  echo "[!] Ghostty is not available in the current enabled standard repositories."
  echo "    Fedora may need an extra source such as the scottames/ghostty COPR."
  echo "    COPR package sets are unofficial and can lag behind Fedora updates."
  echo "    Enable COPR scottames/ghostty and install Ghostty? [y/N]" > /dev/tty
  read -r enable_ghostty_copr < /dev/tty
  case "$enable_ghostty_copr" in
    [yY]|[yY][eE][sS])
      echo "[+] Enabling COPR repository for Ghostty..."
      sudo dnf copr enable -y scottames/ghostty
      ghostty_install_mode="copr"
      ;;
    *)
      ghostty_install_mode="skip"
      ;;
  esac
elif [ "$ghostty_install_mode" = "missing" ]; then
  echo "[!] Ghostty is not available in the current enabled standard repositories."
  echo "    Interactive terminal not available; skipping Ghostty package install."
  ghostty_install_mode="skip"
fi

if [ "$ghostty_install_mode" != "skip" ]; then
  echo "[+] Installing Ghostty..."
  sudo dnf install -y ghostty
  if [ "$ghostty_install_mode" = "copr" ]; then
    echo "    NOTE: Ghostty was installed from the unofficial scottames/ghostty COPR."
  fi
else
  echo "[+] Skipping Ghostty package install."
fi

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

echo "[+] Ensuring development workspace directory..."
mkdir -p "$HOME/code"

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

install_vscode_package() {
  if command -v "$VSCODE_PACKAGE" >/dev/null 2>&1; then
    echo "    VS Code command '$VSCODE_PACKAGE' already available."
    return 0
  fi

  echo "    Adding Microsoft VS Code repository..."
  sudo rpm --import https://packages.microsoft.com/keys/microsoft.asc
  printf '%s\n' \
    '[code]' \
    'name=Visual Studio Code' \
    'baseurl=https://packages.microsoft.com/yumrepos/vscode' \
    'enabled=1' \
    'autorefresh=1' \
    'type=rpm-md' \
    'gpgcheck=1' \
    'gpgkey=https://packages.microsoft.com/keys/microsoft.asc' |
    sudo tee /etc/yum.repos.d/vscode.repo >/dev/null

  echo "    Installing VS Code package '$VSCODE_PACKAGE'..."
  sudo dnf install -y "$VSCODE_PACKAGE"
}

install_sdkman_kotlin() {
  local sdkman_init="$HOME/.sdkman/bin/sdkman-init.sh"

  if [ ! -s "$sdkman_init" ]; then
    echo "    Installing SDKMAN without rewriting shell rc files..."
    curl -s "https://get.sdkman.io?ci=true&rcupdate=false" | bash
  fi

  if [ ! -s "$sdkman_init" ]; then
    record_fallback_warning "SDKMAN init script was not found after install; skipping Kotlin SDKMAN candidate '$KOTLIN_SDKMAN_CANDIDATE'."
    return 0
  fi

  set +u
  # shellcheck source=/dev/null
  source "$sdkman_init"
  set -u

  if command -v kotlin >/dev/null 2>&1; then
    echo "    Kotlin already available."
  else
    echo "    Installing Kotlin via SDKMAN candidate '$KOTLIN_SDKMAN_CANDIDATE'..."
    set +u
    if sdk install "$KOTLIN_SDKMAN_CANDIDATE"; then
      sdk_install_status=0
    else
      sdk_install_status=$?
    fi
    set -u

    if [ "$sdk_install_status" -ne 0 ]; then
      record_fallback_warning "SDKMAN failed to install Kotlin candidate '$KOTLIN_SDKMAN_CANDIDATE'."
    fi
  fi
}

install_vscode_extensions() {
  local extension

  if ! command -v "$VSCODE_PACKAGE" >/dev/null 2>&1; then
    record_fallback_warning "VS Code command '$VSCODE_PACKAGE' unavailable; skipping VS Code extension install."
    return 0
  fi

  if [ "${#VSCODE_EXTENSIONS[@]}" -eq 0 ]; then
    echo "    No VS Code extensions configured."
    return 0
  fi

  echo "    Installing VS Code extensions..."
  for extension in "${VSCODE_EXTENSIONS[@]}"; do
    if ! "$VSCODE_PACKAGE" --install-extension "$extension" --force; then
      record_fallback_warning "VS Code extension '$extension' failed to install."
    fi
  done
}

install_full_vscode_dev_stack() {
  echo "[+] Installing VS Code full dev stack..."
  "$DOTFILES_DIR/scripts/install-node.sh"

  if go_package="$(resolve_first_available_package "Go" "${GO_PACKAGE_CANDIDATES[@]}")"; then
    sudo dnf install -y "$go_package"
  fi

  echo "    Installing Python development packages..."
  install_available_packages "Python development" "${PYTHON_DEV_PACKAGES[@]}"

  echo "    Installing shell development packages..."
  install_available_packages "shell development" "${SHELL_DEV_PACKAGES[@]}"

  install_sdkman_kotlin
  install_vscode_extensions
}

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
  default_email="${current_email:-$DEFAULT_GIT_EMAIL}"

  echo "    Current git user.name : ${current_name:-<not set>}"
  echo "    Current git user.email: ${current_email:-<not set>}"
  echo

  read -r -p "    Enter git user.name  [${current_name:-skip}]: " git_name
  read -r -p "    Enter git user.email [$default_email]: " git_email

  git_name="${git_name:-$current_name}"
  git_email="${git_email:-$default_email}"

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

echo "[+] Optional: Obsidian setup..."
if [ -t 0 ]; then
  read -r -p "    Install Obsidian via Flatpak from Flathub? [y/N]: " install_obsidian
  case "$install_obsidian" in
    [yY]|[yY][eE][sS])
      if command -v flatpak >/dev/null 2>&1; then
        sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
        sudo flatpak install -y flathub md.obsidian.Obsidian
      else
        echo "    WARNING: flatpak is not available; cannot install Obsidian." >&2
      fi
      ;;
    *)
      echo "    Skipping Obsidian install."
      ;;
  esac
else
  echo "    Non-interactive shell detected; skipping Obsidian prompt."
fi

vscode_install_mode="skip"

echo "[+] Optional: VS Code setup..."
if [ -t 0 ]; then
  read -r -p "    Install VS Code + full pet-project dev stack? [y/N]: " install_vscode
  case "$install_vscode" in
    [yY]|[yY][eE][sS])
      vscode_install_mode="install"
      install_vscode_package
      install_full_vscode_dev_stack
      ;;
    *)
      echo "    Skipping VS Code install."
      ;;
  esac
else
  echo "    Non-interactive shell detected; skipping VS Code prompt."
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
ROFI_BT_DIR="$HOME/.local/share/rofi-bluetooth"
ROFI_BT_TARGET="$HOME/.local/bin/rofi-bluetooth"
mkdir -p "$HOME/.local/share"

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

echo "[+] Verifying helper scripts..."
for bin in run-swayidle run-niri-swayidle sway-handle-lid.sh niri-handle-lid.sh hypr-handle-lid.sh hypr-kblayout-waybar hypr-move-workspace-next-output wifi-menu obsidian-launch theme-toggle rofi-bluetooth; do
  if [ ! -x "$HOME/.local/bin/$bin" ]; then
    echo "    WARNING: $HOME/.local/bin/$bin is missing or not executable" >&2
  fi
done

echo "[+] Checking required desktop commands..."
required_cmds=(
  sway
  swayidle
  swaylock
  waybar
  rofi
  ghostty
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

if [ "$vscode_install_mode" = "install" ] && ! command -v "$VSCODE_PACKAGE" >/dev/null 2>&1; then
  echo "    WARNING: missing command: $VSCODE_PACKAGE" >&2
fi

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

if [ -s "$BOOTSTRAP_FALLBACK_LOG" ]; then
  while IFS= read -r warning; do
    [ -n "$warning" ] || continue
    FALLBACK_WARNINGS+=("$warning")
  done < "$BOOTSTRAP_FALLBACK_LOG"
fi

if [ "${#FALLBACK_WARNINGS[@]}" -gt 0 ]; then
  echo
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
  echo "!! Bootstrap completed with version/tooling fallbacks" >&2
  for warning in "${FALLBACK_WARNINGS[@]}"; do
    echo "!! - $warning" >&2
  done
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
  echo
fi

echo "[+] Remember to:"
echo "  - stow you dotfiles"
echo "  - Install JetBrains Toolbox manually (browser/wget) and set up IntelliJ."
echo "  - SDKMAN/Kotlin are installed automatically when you accept VS Code full dev stack."
echo "  - Run:   files-to-prompt --markdown ~/.zshrc ~/.config/sway/config  | wl-copy"
echo "    when you want to paste configs into ChatGPT."
