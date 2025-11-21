#!/usr/bin/env bash
set -euo pipefail

# Internal laptop display name in Sway (change if not eDP-1)
LAPTOP_OUTPUT="${LAPTOP_OUTPUT:-eDP-1}"

# Count active outputs other than the laptop panel
OTHER_COUNT=$(swaymsg -t get_outputs -r \
  | jq --arg name "$LAPTOP_OUTPUT" '[.[] | select(.active == true and .name != $name)] | length')

if [ "$OTHER_COUNT" -eq 0 ]; then
  # No external monitors: lock + suspend
  if command -v swaylock >/dev/null 2>&1; then
    swaylock -f -c 000000 &
    sleep 0.2
  fi

  systemctl suspend
fi
