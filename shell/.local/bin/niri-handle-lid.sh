#!/usr/bin/env bash
set -euo pipefail

LAPTOP_OUTPUT="${1:-${LAPTOP_OUTPUT:-eDP-1}}"

if ! command -v niri >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

OTHER_COUNT=$(niri msg --json outputs \
  | jq --arg name "$LAPTOP_OUTPUT" '[.[] | select(.name != $name)] | length')

if [ "$OTHER_COUNT" -eq 0 ]; then
  if command -v swaylock >/dev/null 2>&1; then
    swaylock -f -c 000000 -k &
    sleep 0.2
  fi

  systemctl suspend
fi
