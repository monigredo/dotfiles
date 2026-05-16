ftpmd() {
  if [ "$#" -eq 0 ]; then
    echo "Usage: ftpmd file_or_dir [more...]" >&2
    return 1
  fi
  files-to-prompt --markdown "$@" | wl-copy
  echo "Copied files-to-prompt output for: $*" >&2
}
