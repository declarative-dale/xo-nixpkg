#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl jq nix-prefetch-github gnused

set -euo pipefail

# Xen Orchestra doesn't use git tags. Versions are indicated in commit messages
# like "feat: release 6.0.3". This script searches recent commits for version bumps.

cd "$(dirname "$0")"

echo "Searching for latest version commit in xen-orchestra..."

# Get recent commits and find the latest version bump
version_info=$(curl -s "https://api.github.com/repos/vatesfr/xen-orchestra/commits?per_page=100" | \
    jq -r '.[] | select(.commit.message | test("^feat: release [0-9]+\\.[0-9]+\\.[0-9]+")) | {sha: .sha, message: .commit.message} | @json' | \
    head -1)

if [ -z "$version_info" ] || [ "$version_info" = "null" ]; then
    echo "No version commit found in recent history" >&2
    exit 1
fi

commit_sha=$(echo "$version_info" | jq -r '.sha')
commit_msg=$(echo "$version_info" | jq -r '.message')
new_version=$(echo "$commit_msg" | sed -n 's/^feat: release \([0-9.]*\).*/\1/p')

echo "Found: $commit_msg"
echo "Version: $new_version"
echo "Commit: $commit_sha"

# Get the new source hash
echo "Fetching source hash..."
new_hash=$(nix-prefetch-github vatesfr xen-orchestra --rev "$commit_sha" | jq -r '.hash')

echo "New hash: $new_hash"

# Update package.nix
sed -i "s/version = \"[^\"]*\"/version = \"$new_version\"/" package.nix
sed -i "s/rev = \"[a-f0-9]*\"/rev = \"$commit_sha\"/" package.nix
sed -i "s|hash = \"sha256-[^\"]*\"|hash = \"$new_hash\"|" package.nix

echo ""
echo "Updated package.nix to version $new_version"
echo "Note: You may need to update yarnOfflineCache hash manually if yarn.lock changed"
echo ""
echo "To update yarn hash, run:"
echo "  nix build .#xen-orchestra-ce 2>&1 | grep 'got:'"
