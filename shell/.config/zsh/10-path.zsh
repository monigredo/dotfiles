# User-specific PATH entries.
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.local/npm-global/bin"
  "$HOME/.opencode/bin"
  $path
)

export PATH
