ftpmd() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: ftpmd file_or_dir [more...]" >&2
    return 1
  fi
  files-to-prompt --markdown "$@" | wl-copy
  echo "Copied files-to-prompt output for: $*" >&2
}

c() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: c command [args...]" >&2
    return 1
  fi

  "$@" 2>&1 | tee >(wl-copy)
  return ${pipestatus[1]}
}

t() {
  local session="${1:-main}"

  if [ -n "${TMUX:-}" ]; then
    if ! tmux has-session -t="$session" 2>/dev/null; then
      tmux new-session -d -s "$session"
    fi
    tmux switch-client -t "$session"
  else
    tmux new-session -A -s "$session"
  fi
}
