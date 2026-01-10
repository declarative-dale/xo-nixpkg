<!-- SPDX-License-Identifier: Apache-2.0 -->
# xen-orchestra-ce-nix

Nix packages for [Xen Orchestra Community Edition](https://xen-orchestra.com) and [libvhdi](https://github.com/libyal/libvhdi), structured for eventual submission to nixpkgs.

## Packages

- **xen-orchestra-ce**: Full web-based management interface for XCP-ng/XenServer
- **libvhdi**: Library and tools to access VHD/VHDX image formats

## Usage

### With Flakes

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    xo-ce-nix.url = "github:YOUR-USER/xen-orchestra-ce-nix";
  };

  outputs = { self, nixpkgs, xo-ce-nix }: {
    nixosConfigurations.myhost = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        {
          environment.systemPackages = [
            xo-ce-nix.packages.x86_64-linux.xen-orchestra-ce
            xo-ce-nix.packages.x86_64-linux.libvhdi
          ];
        }
      ];
    };
  };
}
```

### Traditional Nix

```bash
# Clone repository
git clone https://github.com/YOUR-USER/xen-orchestra-ce-nix.git
cd xen-orchestra-ce-nix

# Build packages
nix-build -A xen-orchestra-ce
nix-build -A libvhdi
```

## Development

```bash
# Enter development shell
nix develop

# Build packages with flake inputs (development mode)
nix build .#xen-orchestra-ce
nix build .#libvhdi

# Build packages with nixpkgs-style fetchers (submission test mode)
# Note: Requires updating source hashes first
nix build .#xen-orchestra-ce-nixpkgs-test
nix build .#libvhdi-nixpkgs-test

# Run all checks
nix flake check
```

## Nixpkgs Submission

These packages are structured for submission to nixpkgs. See [docs/nixpkgs-submission.md](docs/nixpkgs-submission.md) for the detailed submission process.

When submitted to nixpkgs, they will be located at:
- `pkgs/by-name/xe/xen-orchestra-ce/package.nix`
- `pkgs/by-name/li/libvhdi/package.nix`

**Current Status:** Not yet submitted

## Updating Source Versions

### Update xen-orchestra-ce to new commit

```bash
# Get latest commit hash
git ls-remote https://github.com/vatesfr/xen-orchestra.git master

# Update flake.nix xoSrc input with new commit hash
# Then update flake.lock
nix flake lock --update-input xoSrc

# Get hash for nixpkgs-style build
nix-prefetch-github vatesfr xen-orchestra --rev <new-commit-hash>

# Update xoSrcHash in flake.nix for nixpkgs-test variant

# Update yarn dependencies hash by building and using error message hash
nix build .#xen-orchestra-ce
# Copy the correct hash from error message to xen-orchestra-ce/default.nix
```

### Update libvhdi to new version

```bash
# Check for new releases
curl -s https://api.github.com/repos/libyal/libvhdi/releases/latest | jq -r '.tag_name'

# Update flake.nix libvhdiSrc input with new version
# Then update flake.lock
nix flake lock --update-input libvhdiSrc

# Get hash for nixpkgs-style build
nix-prefetch-url https://github.com/libyal/libvhdi/releases/download/<version>/libvhdi-alpha-<version>.tar.gz

# Update srcHash in flake.nix for nixpkgs-test variant
```

## Testing

```bash
# Run all flake checks
nix flake check

# Test xen-orchestra-ce
nix build .#xen-orchestra-ce
./result/bin/xo-server --help

# Test libvhdi
nix build .#libvhdi
./result/bin/vhdiinfo --version
./result/bin/vhdimount --version
```

## Architecture

This repository uses a **dual-mode** approach:

- **Development mode**: Packages accept flake inputs (`xoSrc`, `libvhdiSrc`)
- **Nixpkgs mode**: Packages accept traditional parameters (`xoSrcRev`/`xoSrcHash`, `version`/`srcHash`)

This allows:
1. Fast iteration during development using flake inputs
2. Testing exact nixpkgs submission behavior before creating PRs
3. Single source of truth (one `default.nix` per package)

## Relationship to NiXOA Core

This repository is synced with [NiXOA/core](https://github.com/YOUR-USER/NiXOA-core) using a **parallel sync** strategy:

- Core flake contains the production packages
- This repo is structured for nixpkgs submission
- Changes are manually synced between repositories
- See [VERSION-SYNC.md](VERSION-SYNC.md) for sync history

## License

Apache-2.0 - See [LICENSE](LICENSE)

## Related Projects

- [NiXOA](https://codeberg.org/NiXOA) - Full NixOS deployment system for Xen Orchestra
- [Xen Orchestra](https://github.com/vatesfr/xen-orchestra) - Upstream project
- [libvhdi](https://github.com/libyal/libvhdi) - Upstream library
- [libvhdi-nix](https://github.com/YOUR-USER/libvhdi-nix) - Standalone libvhdi package repo

## Maintainers

- Your Name (@your-github-username)
