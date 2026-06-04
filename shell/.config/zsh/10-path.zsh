# User-specific PATH entries.
export BUN_INSTALL="$HOME/.bun"

typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.local/npm-global/bin"
  "$HOME/.opencode/bin"
  "$BUN_INSTALL/bin"
  $path
)

export PATH
