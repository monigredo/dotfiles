if [ -r /usr/share/fzf/shell/key-bindings.zsh ]; then
  zmodload() {
    return 1
  }

  setopt() {
    local -a args

    while (( $# )); do
      if [[ $1 == [-+]o && ${2-} == zle ]]; then
        shift 2
      else
        args+=("$1")
        shift
      fi
    done

    builtin setopt "$args[@]"
  }

  . /usr/share/fzf/shell/key-bindings.zsh

  unfunction setopt zmodload
fi
