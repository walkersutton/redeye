#!/usr/bin/env zsh
set -euo pipefail

app_name="redeye"

killall "$app_name" >/dev/null 2>&1 || true
pkill -f "/${app_name}.app/Contents/MacOS/${app_name}" >/dev/null 2>&1 || true

printf 'Killed running %s instances.\n' "$app_name"
