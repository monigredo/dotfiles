#!/usr/bin/env bash
set -euo pipefail

echo "[+] Updating system..."
sudo dnf update -y

echo "[+] Installing core CLI tools..."
sudo dnf install -y \
  git \
  zsh \
  fzf \
  ripgrep \
  fd-find \
  bat \
  tmux \
  htop \
  wl-clipboard \
  jq \
  dnf-plugins-core \
  podman \
  podman-docker \
  podman-compose \
  java-21-openjdk \
  java-21-openjdk-devel \
  flatpak \
  pipx

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


echo "[+] Remember to:"
echo "  - Install JetBrains Toolbox manually (browser/wget) and set up IntelliJ."
echo "  - Install SDKMAN:  curl -s \"https://get.sdkman.io\" | bash"
echo "  - Run:   files-to-prompt --markdown ~/.bashrc ~/.config/sway/config  | wl-copy"
echo "    when you want to paste configs into ChatGPT."
