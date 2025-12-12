
npm_global_bin="$HOME/.local/npm-global/bin"
case ":$PATH:" in
  *":$npm_global_bin:"*) ;;
  *) PATH="$npm_global_bin:$PATH" ;;
esac

export PATH

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
[[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]] && source "$HOME/.sdkman/bin/sdkman-init.sh"

eval "$(direnv hook zsh)"
