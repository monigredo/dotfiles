#!/usr/bin/env bash
set -euo pipefail

exec "${NIRI_POWER_MODE_BIN:-$HOME/.local/bin/niri-power-mode}" lid-close
