eval "$(direnv hook zsh)"

export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  . "$NVM_DIR/nvm.sh"
fi

if [ -s "$BUN_INSTALL/_bun" ]; then
  . "$BUN_INSTALL/_bun"
fi
