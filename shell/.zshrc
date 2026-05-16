# .zshrc
PROMPT='%1~%# '

# Source global definitions
if [ -f /etc/zshrc ]; then
  . /etc/zshrc
fi

# User specific environment
case ":$PATH:" in
  *":$HOME/.local/bin:$HOME/bin:"*) ;;
  *) PATH="$HOME/.local/bin:$HOME/bin:$PATH" ;;
esac

npm_global_bin="$HOME/.local/npm-global/bin"
case ":$PATH:" in
  *":$npm_global_bin:"*) ;;
  *) PATH="$npm_global_bin:$PATH" ;;
esac

export PATH

# Uncomment the following line if you don't like systemctl's auto-paging feature:
# export SYSTEMD_PAGER=

# User specific aliases and functions
if [ -d ~/.zshrc.d ]; then
  for rc in ~/.zshrc.d/*(.N); do
    . "$rc"
  done
fi
unset rc

alias edsw="code ~/.config/sway/config"

alias ls='eza'
alias cat='bat'
alias ccat='/usr/bin/cat'
alias grep='rg'
alias chef='docker run -it -p 8080:80 ghcr.io/gchq/cyberchef:latest'

# files-to-prompt -> Markdown -> clipboard
ftpmd() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: ftpmd file_or_dir [more...]" >&2
    return 1
  fi
  files-to-prompt --markdown "$@" | wl-copy
  echo "Copied files-to-prompt output for: $*" >&2
}

eval "$(direnv hook zsh)"

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm

# opencode
export PATH="$HOME/.opencode/bin:$PATH"
export ANDROID_SDK_ROOT="$HOME/Android/Sdk"
export PATH="$PATH:$ANDROID_SDK_ROOT/platform-tools:$ANDROID_SDK_ROOT/emulator"

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi
