# .zshrc

if [ -f /etc/zshrc ]; then
  . /etc/zshrc
fi

PROMPT='%1~%# '

for rc in "$HOME"/.config/zsh/*.zsh(.N); do
  . "$rc"
done
unset rc

for rc in "$HOME"/.zshrc.d/*(.N); do
  . "$rc"
done
unset rc

#THIS MUST BE AT THE END OF THE FILE FOR SDKMAN TO WORK!!!
export SDKMAN_DIR="$HOME/.sdkman"
if [[ -s "$HOME/.sdkman/bin/sdkman-init.sh" ]]; then
  source "$HOME/.sdkman/bin/sdkman-init.sh"
fi
