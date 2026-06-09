#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
DEV_VERSIONS_FILE="$DOTFILES_DIR/config/dev-versions.sh"

NODE_PACKAGE_CANDIDATES=(nodejs)
NPM_PACKAGE_CANDIDATES=(npm)

if [ -f "$DEV_VERSIONS_FILE" ]; then
  # shellcheck source=/dev/null
  source "$DEV_VERSIONS_FILE"
else
  echo "[!] Missing $DEV_VERSIONS_FILE; using built-in Node defaults."
fi

package_available() {
  dnf -q list --available "$1" </dev/null >/dev/null 2>&1 ||
    dnf -q list --installed "$1" </dev/null >/dev/null 2>&1
}

record_node_warning() {
  local message="$1"

  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2
  echo "!! NODE SETUP VERSION FALLBACK" >&2
  echo "!! $message" >&2
  echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!" >&2

  if [ -n "${BOOTSTRAP_FALLBACK_LOG:-}" ]; then
    printf '%s\n' "$message" >> "$BOOTSTRAP_FALLBACK_LOG"
  fi
}

resolve_first_available_package() {
  local label="$1"
  shift

  local preferred="${1:-}"
  local candidate

  for candidate in "$@"; do
    if package_available "$candidate"; then
      if [ -n "$preferred" ] && [ "$candidate" != "$preferred" ]; then
        record_node_warning "$label: preferred package '$preferred' unavailable; using '$candidate'."
      fi
      printf '%s\n' "$candidate"
      return 0
    fi
  done

  record_node_warning "$label: no configured packages are available: $*."
  return 1
}

echo "[+] Ensuring Node.js and npm..."
if command -v node >/dev/null 2>&1 && command -v npm >/dev/null 2>&1; then
  echo "    Node.js and npm already installed."
else
  node_package="$(resolve_first_available_package "Node.js" "${NODE_PACKAGE_CANDIDATES[@]}")"
  npm_package="$(resolve_first_available_package "npm" "${NPM_PACKAGE_CANDIDATES[@]}")"
  echo "    Installing $node_package and $npm_package via dnf..."
  sudo dnf install -y "$node_package" "$npm_package"
fi

NPM_GLOBAL_PREFIX="$HOME/.local/npm-global"
NPM_GLOBAL_BIN="$NPM_GLOBAL_PREFIX/bin"
NPM_GLOBAL_BIN_ZSH='$HOME/.local/npm-global/bin'

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
ensure_path_line "$DOTFILES_DIR/shell/.config/zsh/10-path.zsh" "$NPM_GLOBAL_BIN_ZSH"
