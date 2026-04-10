#!/usr/bin/env bash
set -euo pipefail

# Remove existing targets in $HOME that will be replaced by stow, then restow packages.
# Usage: stow-clean-restow.sh [package...]

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TARGET="${TARGET:-$HOME}"

if [ "$#" -gt 0 ]; then
  PACKAGES=("$@")
else
  PACKAGES=(shell sway waybar alacritty tmux env hyprland)
fi

echo "[stow-clean] Target: $TARGET"
echo "[stow-clean] Packages: ${PACKAGES[*]}"

legacy_gitconfig="$TARGET/.gitconfig"
if [ -L "$legacy_gitconfig" ] && [ "$(readlink -f "$legacy_gitconfig")" = "$REPO_DIR/git/.gitconfig" ]; then
  echo "  [CLEAN] Removing legacy $legacy_gitconfig"
  rm -f "$legacy_gitconfig"
fi

find_symlink_ancestor() {
  local path="$1"
  local current="$path"

  while [ "$current" != "$TARGET" ] && [ "$current" != "/" ]; do
    if [ -L "$current" ]; then
      printf '%s\n' "$current"
      return 0
    fi
    current="$(dirname "$current")"
  done

  return 1
}

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

    if ancestor="$(find_symlink_ancestor "$dest")"; then
      echo "  [CLEAN] Removing symlink ancestor $ancestor"
      rm -f "$ancestor"
      continue
    fi

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
for bin in run-swayidle sway-handle-lid.sh hypr-handle-lid.sh hypr-kblayout-waybar hypr-move-workspace-next-output wifi-menu rofi-bluetooth; do
  if [ ! -x "$TARGET/.local/bin/$bin" ]; then
    echo "[stow-clean] WARNING: $TARGET/.local/bin/$bin is missing or not executable" >&2
  fi
done
