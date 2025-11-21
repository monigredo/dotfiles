#!/usr/bin/env bash
set -euo pipefail

ARCH="$(uname -m)"
case "$ARCH" in
  x86_64) ASSET_ARCH="x86_64-unknown-linux-musl" ;;
  aarch64) ASSET_ARCH="aarch64-unknown-linux-musl" ;;
  *)
    echo "Unsupported architecture: $ARCH" >&2
    exit 1
    ;;
esac

echo "[+] Installing Codex CLI (binary release)..."

TAG="$(curl -fsSL https://api.github.com/repos/openai/codex/releases/latest | jq -r '.tag_name')"
if [ -z "${TAG:-}" ] || [ "${TAG:-null}" = "null" ]; then
  echo "Failed to determine latest Codex release tag." >&2
  exit 1
fi

TMPDIR="$(mktemp -d)"
cleanup() {
  rm -rf "$TMPDIR"
}
trap cleanup EXIT

ASSET_URL="https://github.com/openai/codex/releases/download/${TAG}/codex-${ASSET_ARCH}.tar.gz"
echo "    Downloading ${ASSET_URL}..."
curl -fsSL -o "$TMPDIR/codex.tar.gz" "$ASSET_URL"

echo "    Extracting Codex archive..."
tar -xzf "$TMPDIR/codex.tar.gz" -C "$TMPDIR"

BIN_SOURCE=""
if [ -x "$TMPDIR/codex" ]; then
  BIN_SOURCE="$TMPDIR/codex"
elif [ -x "$TMPDIR/codex-${ASSET_ARCH}" ]; then
  BIN_SOURCE="$TMPDIR/codex-${ASSET_ARCH}"
else
  FOUND_BIN="$(find "$TMPDIR" -maxdepth 2 -type f -name codex -perm -111 | head -n 1 || true)"
  if [ -n "${FOUND_BIN:-}" ]; then
    BIN_SOURCE="$FOUND_BIN"
  fi
fi

if [ -z "$BIN_SOURCE" ]; then
  echo "Could not find codex binary in the downloaded archive." >&2
  exit 1
fi

mkdir -p "$HOME/.local/bin"
install -m 0755 "$BIN_SOURCE" "$HOME/.local/bin/codex"

if case ":$PATH:" in *":$HOME/.local/bin:"*) true ;; *) false ;; esac; then
  :
else
  echo "WARNING: $HOME/.local/bin is not in PATH. Add it to your shell config to use 'codex'."
fi

echo "Codex installed to $HOME/.local/bin/codex (release ${TAG})."
