# User-specific PATH entries.
typeset -U path PATH
path=(
  "$HOME/.local/bin"
  "$HOME/bin"
  "$HOME/.local/npm-global/bin"
  "$HOME/.opencode/bin"
  $path
)

export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
path+=(
  "$ANDROID_SDK_ROOT/platform-tools"
  "$ANDROID_SDK_ROOT/emulator"
)

export PATH
