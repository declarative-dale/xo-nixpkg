#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq common-updater-scripts

set -euo pipefail

latest_version=$(curl -fsSL "https://api.github.com/repos/libyal/libvhdi/tags?per_page=100" | jq -r '
  [ .[]
    | .name
    | select(test("^[0-9]{8}$"))
  ]
  | sort
  | last
')

if [ -z "$latest_version" ] || [ "$latest_version" = "null" ]; then
    echo "Failed to fetch latest version tag" >&2
    exit 1
fi

update-source-version libvhdi "$latest_version"

echo "Updated libvhdi to version $latest_version"
