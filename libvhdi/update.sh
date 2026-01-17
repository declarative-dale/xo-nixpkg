#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts

set -euo pipefail

latest_version=$(curl -s "https://api.github.com/repos/libyal/libvhdi/releases/latest" | jq -r '.tag_name')

if [ -z "$latest_version" ] || [ "$latest_version" = "null" ]; then
    echo "Failed to fetch latest version" >&2
    exit 1
fi

update-source-version libvhdi "$latest_version"

echo "Updated to version $latest_version"
