# User-specific PATH entries.
export BUN_INSTALL="$HOME/.bun"
export PNPM_HOME="$HOME/.local/share/pnpm"

typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$PNPM_HOME"
  "$HOME/.local/npm-global/bin"
  "$HOME/.opencode/bin"
  "$BUN_INSTALL/bin"
  $path
)

export PATH
