#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_dir/shell/.local/bin/niri-handle-lid.sh"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT

power_dir="$fixture/power"
state_dir="$fixture/state"
log_file="$fixture/calls.log"
mkdir -p "$power_dir" "$state_dir"
touch "$log_file"

write_ac_online() {
  rm -rf "$power_dir"
  mkdir -p "$power_dir/AC"
  printf '%s\n' "$1" >"$power_dir/AC/online"
}

set_mode() {
  printf '%s\n' "$1" >"$state_dir/mode"
}

set_caffeinate() {
  printf '%s\n' "$1" >"$state_dir/caffeinate"
}

run_handler() {
  NIRI_POWER_STATE_DIR="$state_dir" \
  NIRI_POWER_MODE_BIN="$repo_dir/shell/.local/bin/niri-power-mode" \
  POWER_SUPPLY_SYSFS_ROOT="$power_dir" \
  NIRI_POWER_EXTERNAL_DISPLAY_CMD="${NIRI_POWER_EXTERNAL_DISPLAY_CMD:-false}" \
  NIRI_POWER_LOCK_CMD="printf 'lock\n' >>'$log_file'" \
  NIRI_POWER_SUSPEND_CMD="printf 'suspend\n' >>'$log_file'" \
  NIRI_POWER_SKIP_WAYBAR_REFRESH=1 \
    "$script"
}

write_ac_online 1
set_mode home
set_caffeinate 0
: >"$log_file"
run_handler
diff -u <(printf 'lock\n') "$log_file"

write_ac_online 0
set_mode home
set_caffeinate 0
: >"$log_file"
run_handler
diff -u <(printf 'lock\nsuspend\n') "$log_file"

write_ac_online 1
set_mode travel
set_caffeinate 0
: >"$log_file"
run_handler
diff -u <(printf 'lock\nsuspend\n') "$log_file"

write_ac_online 0
set_mode travel
set_caffeinate 1
: >"$log_file"
run_handler
diff -u <(printf 'lock\n') "$log_file"

NIRI_POWER_EXTERNAL_DISPLAY_CMD=true
export NIRI_POWER_EXTERNAL_DISPLAY_CMD
write_ac_online 1
set_mode home
set_caffeinate 0
: >"$log_file"
run_handler
test ! -s "$log_file"
