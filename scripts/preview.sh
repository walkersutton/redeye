#!/usr/bin/env zsh
set -euo pipefail

scheme="redeye"
app_path="build/Build/Products/Release/redeye.app"

scripts/kill.sh

xcodebuild -scheme "$scheme" \
	-configuration Release \
	-derivedDataPath build

open "$app_path"
