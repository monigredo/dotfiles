#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_dir/shell/.local/bin/niri-power-mode"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT

state_dir="$fixture/state"
power_dir="$fixture/power"
log_file="$fixture/calls.log"
mkdir -p "$state_dir" "$power_dir"
touch "$log_file"

run_mode() {
  NIRI_POWER_STATE_DIR="$state_dir" \
  POWER_SUPPLY_SYSFS_ROOT="$power_dir" \
  NIRI_POWER_EXTERNAL_DISPLAY_CMD="${NIRI_POWER_EXTERNAL_DISPLAY_CMD:-false}" \
  NIRI_POWER_LOCK_CMD="printf 'lock\n' >>'$log_file'" \
  NIRI_POWER_SUSPEND_CMD="printf 'suspend\n' >>'$log_file'" \
  NIRI_POWER_IDLE_RUNNER="printf 'idle %s\n' >>'$log_file'" \
  NIRI_POWER_SKIP_WAYBAR_REFRESH=1 \
    "$script" "$@"
}

write_ac_online() {
  rm -rf "$power_dir"
  mkdir -p "$power_dir/AC"
  printf '%s\n' "$1" >"$power_dir/AC/online"
}

assert_log() {
  local expected="$1"
  diff -u <(printf '%s' "$expected") "$log_file"
}

test "$(run_mode mode)" = "home"
test "$(run_mode caffeinate)" = "0"
test "$(run_mode idle-timeout)" = "7200"

: >"$log_file"
run_mode toggle-mode >/dev/null
test "$(run_mode mode)" = "travel"
test "$(run_mode idle-timeout)" = "300"
assert_log "idle 300
"

: >"$log_file"
run_mode toggle-mode >/dev/null
test "$(run_mode mode)" = "home"
assert_log "idle 7200
"

write_ac_online 1
: >"$log_file"
run_mode lid-close
assert_log "lock
"

write_ac_online 0
: >"$log_file"
run_mode lid-close
assert_log "lock
suspend
"

run_mode toggle-mode >/dev/null
write_ac_online 1
: >"$log_file"
run_mode lid-close
assert_log "lock
suspend
"

run_mode toggle-caffeinate >/dev/null
: >"$log_file"
run_mode lid-close
assert_log "lock
"

caffeinate_output="$(run_mode waybar-caffeinate)"
grep -Fq '"class":"caffeinate"' <<<"$caffeinate_output"

run_mode toggle-caffeinate >/dev/null
test -z "$(run_mode waybar-caffeinate)"

NIRI_POWER_EXTERNAL_DISPLAY_CMD=true
export NIRI_POWER_EXTERNAL_DISPLAY_CMD
: >"$log_file"
run_mode lid-close
test ! -s "$log_file"

monitor_output="$(run_mode waybar-monitor)"
grep -Fq '"class":"external-monitor"' <<<"$monitor_output"

NIRI_POWER_EXTERNAL_DISPLAY_CMD=false
export NIRI_POWER_EXTERNAL_DISPLAY_CMD
test -z "$(run_mode waybar-monitor)"
