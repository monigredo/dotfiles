#!/usr/bin/env bash
set -euo pipefail

LAPTOP_OUTPUT="${1:-${LAPTOP_OUTPUT:-eDP-1}}"

if ! command -v hyprctl >/dev/null 2>&1 || ! command -v jq >/dev/null 2>&1; then
  exit 0
fi

OTHER_COUNT=$(hyprctl -j monitors \
  | jq --arg name "$LAPTOP_OUTPUT" '[.[] | select(.disabled != true and .name != $name)] | length')

if [ "$OTHER_COUNT" -eq 0 ]; then
  if command -v hyprlock >/dev/null 2>&1; then
    pidof hyprlock >/dev/null 2>&1 || hyprlock &
    sleep 0.2
  fi

  systemctl suspend
else
  hyprctl keyword monitor "$LAPTOP_OUTPUT, disable" >/dev/null 2>&1 || true
fi
