#!/usr/bin/env bash
set -euo pipefail

# Remove existing targets in $HOME that will be replaced by stow, then restow packages.
# Usage: stow-clean-restow.sh [package...]

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${TARGET:-$HOME}"

if [ "$#" -gt 0 ]; then
  PACKAGES=("$@")
else
  PACKAGES=(shell sway waybar alacritty git env)
fi

echo "[stow-clean] Target: $TARGET"
echo "[stow-clean] Packages: ${PACKAGES[*]}"

for pkg in "${PACKAGES[@]}"; do
  PKG_PATH="$REPO_DIR/$pkg"
  if [ ! -d "$PKG_PATH" ]; then
    echo "  [WARN] Skipping missing package: $pkg" >&2
    continue
  fi

  while IFS= read -r -d '' path; do
    rel="${path#"$PKG_PATH"/}"
    [ -z "$rel" ] && continue
    dest="$TARGET/$rel"

    if [ -L "$dest" ] || [ -f "$dest" ]; then
      echo "  [CLEAN] Removing $dest"
      rm -f "$dest"
    elif [ -d "$dest" ]; then
      echo "  [WARN] Found directory at $dest; manual cleanup may be needed." >&2
    fi
  done < <(find "$PKG_PATH" -type f -print0 -o -type l -print0)
done

if ! command -v stow >/dev/null 2>&1; then
  echo "[stow-clean] ERROR: stow not installed; cannot proceed." >&2
  exit 1
fi

(cd "$REPO_DIR" && stow --target="$TARGET" --restow "${PACKAGES[@]}")

# Verify expected helper scripts are in place
for bin in run-swayidle sway-handle-lid.sh wifi-menu rofi-bluetooth; do
  if [ ! -x "$TARGET/.local/bin/$bin" ]; then
    echo "[stow-clean] WARNING: $TARGET/.local/bin/$bin is missing or not executable" >&2
  fi
done
