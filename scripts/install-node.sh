#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "[+] Ensuring Node.js and npm..."
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  echo "    Node.js and npm already installed."
else
  echo "    Installing nodejs and npm via dnf..."
  sudo dnf install -y nodejs npm
fi

NPM_GLOBAL_PREFIX="$HOME/.local/npm-global"
NPM_GLOBAL_BIN="$NPM_GLOBAL_PREFIX/bin"

echo "[+] Configuring npm user-global prefix..."
mkdir -p "$NPM_GLOBAL_PREFIX"
npm config set prefix "$NPM_GLOBAL_PREFIX"

ensure_path_line() {
  local rc_file="$1"
  local bin_path="$2"

  [ -f "$rc_file" ] || return 0
  if grep -F "$bin_path" "$rc_file" >/dev/null 2>&1; then
    echo "    PATH already includes $bin_path in $(basename "$rc_file")"
  else
    echo "export PATH=\"$bin_path:\$PATH\"" >> "$rc_file"
    echo "    Added npm bin path to $(basename "$rc_file")."
  fi
}

echo "[+] Ensuring npm bin path is exported in shell configs..."
ensure_path_line "$DOTFILES_DIR/shell/.bashrc" "$NPM_GLOBAL_BIN"
ensure_path_line "$DOTFILES_DIR/shell/.zshrc" "$NPM_GLOBAL_BIN"
