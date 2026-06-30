#!/usr/bin/env bash
set -euo pipefail

repo_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
script="$repo_dir/shell/.local/bin/battery-cycles"
fixture="$(mktemp -d)"
trap 'rm -rf "$fixture"' EXIT

mkdir -p "$fixture/BAT1"
cat >"$fixture/BAT1/uevent" <<'EOF'
POWER_SUPPLY_NAME=BAT1
POWER_SUPPLY_TYPE=Battery
POWER_SUPPLY_STATUS=Discharging
POWER_SUPPLY_PRESENT=1
POWER_SUPPLY_TECHNOLOGY=Li-ion
POWER_SUPPLY_CYCLE_COUNT=38
POWER_SUPPLY_VOLTAGE_MIN_DESIGN=15480000
POWER_SUPPLY_VOLTAGE_NOW=17296000
POWER_SUPPLY_CURRENT_NOW=402000
POWER_SUPPLY_CHARGE_FULL_DESIGN=3915000
POWER_SUPPLY_CHARGE_FULL=3956000
POWER_SUPPLY_CHARGE_NOW=3670000
POWER_SUPPLY_CAPACITY=93
POWER_SUPPLY_MODEL_NAME=FRANGWA
POWER_SUPPLY_MANUFACTURER=NVT
POWER_SUPPLY_SERIAL_NUMBER=016B
EOF

output="$(BATTERY_SYSFS_ROOT="$fixture" "$script")"

grep -Fqx "Battery: BAT1" <<<"$output"
grep -Fqx "Cycles: 38" <<<"$output"
grep -Fqx "Model: FRANGWA" <<<"$output"
grep -Fqx "Manufacturer: NVT" <<<"$output"
grep -Fqx "Capacity: 93%" <<<"$output"
grep -Fqx "Full charge: 3956000 uAh" <<<"$output"
grep -Fqx "Design full charge: 3915000 uAh" <<<"$output"
