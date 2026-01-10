<!-- SPDX-License-Identifier: Apache-2.0 -->
# Development Guide

## Setup

```bash
# Clone repository
git clone https://github.com/YOUR-USER/xen-orchestra-ce-nix.git
cd xen-orchestra-ce-nix

# Enter development shell
nix develop
```

## Building Packages

### Development Builds (using flake inputs)

```bash
# Build xen-orchestra-ce with flake input
nix build .#xen-orchestra-ce

# Build libvhdi with flake input
nix build .#libvhdi

# Test binaries
./result/bin/xo-server --help
./result/bin/vhdiinfo --version
```

### Nixpkgs-Test Builds (using fetchFromGitHub/fetchurl)

These test the packages as they would work in nixpkgs:

```bash
# Note: Requires updating hashes first (see "Updating Sources" below)
nix build .#xen-orchestra-ce-nixpkgs-test
nix build .#libvhdi-nixpkgs-test
```

## Updating Sources

### Update xen-orchestra-ce to New Commit

1. **Get new commit hash**:
   ```bash
   git ls-remote https://github.com/vatesfr/xen-orchestra.git master
   ```

2. **Update flake.nix**:
   ```nix
   xoSrc = {
     url = "github:vatesfr/xen-orchestra/<NEW-COMMIT-HASH>";
     flake = false;
   };
   ```

3. **Update flake.lock**:
   ```bash
   nix flake lock --update-input xoSrc
   ```

4. **Get hash for nixpkgs-test build**:
   ```bash
   nix-prefetch-github vatesfr xen-orchestra --rev <NEW-COMMIT-HASH>
   # Copy the "hash" value (not "sha256")
   ```

5. **Update flake.nix nixpkgs-test variant**:
   ```nix
   xen-orchestra-ce-nixpkgs-test = pkgs.callPackage ./xen-orchestra-ce {
     xoSrcRev = "<NEW-COMMIT-HASH>";
     xoSrcHash = "sha256-<NEW-HASH>";
   };
   ```

6. **Update yarn dependencies hash**:
   ```bash
   # Build will fail with correct hash in error message
   nix build .#xen-orchestra-ce 2>&1 | grep "got:"
   # Copy the hash from "got:" line
   ```

7. **Update xen-orchestra-ce/default.nix**:
   ```nix
   yarnOfflineCache = fetchYarnDeps {
     yarnLock = "${src}/yarn.lock";
     hash = "sha256-<NEW-YARN-HASH>";
   };
   ```

8. **Test both build variants**:
   ```bash
   nix build .#xen-orchestra-ce
   nix build .#xen-orchestra-ce-nixpkgs-test
   ```

### Update libvhdi to New Version

1. **Check for new releases**:
   ```bash
   curl -s https://api.github.com/repos/libyal/libvhdi/releases/latest | jq -r '.tag_name'
   ```

2. **Update flake.nix**:
   ```nix
   libvhdiSrc = {
     url = "https://github.com/libyal/libvhdi/releases/download/<VERSION>/libvhdi-alpha-<VERSION>.tar.gz";
     flake = false;
   };
   ```

3. **Update flake.lock**:
   ```bash
   nix flake lock --update-input libvhdiSrc
   ```

4. **Get hash for nixpkgs-test build**:
   ```bash
   nix-prefetch-url https://github.com/libyal/libvhdi/releases/download/<VERSION>/libvhdi-alpha-<VERSION>.tar.gz
   ```

5. **Update flake.nix nixpkgs-test variant**:
   ```nix
   libvhdi-nixpkgs-test = pkgs.callPackage ./libvhdi {
     version = "<VERSION>";
     srcHash = "sha256-<NEW-HASH>";
   };
   ```

6. **Test both build variants**:
   ```bash
   nix build .#libvhdi
   nix build .#libvhdi-nixpkgs-test
   ```

## Testing

### Quick Tests

```bash
# Run all flake checks
nix flake check

# Build all packages
nix build .#xen-orchestra-ce
nix build .#libvhdi

# Test binaries
./result/bin/xo-server --help
```

### Comprehensive Tests

See [testing.md](testing.md) for detailed testing procedures.

## Syncing with NiXOA Core

This repository maintains a parallel sync with NiXOA core. Changes are manually synchronized.

### Sync from Core to Standalone

1. **Review core changes**:
   ```bash
   cd /path/to/NiXOA/core
   git log --oneline pkgs/xen-orchestra-ce/
   git log --oneline pkgs/libvhdi/
   ```

2. **Compare files**:
   ```bash
   diff -u /path/to/NiXOA/core/pkgs/xen-orchestra-ce/default.nix \
           /path/to/xen-orchestra-ce-nix/xen-orchestra-ce/default.nix
   ```

3. **Merge changes**:
   - Copy derivation logic updates
   - **Preserve dual-mode structure** (don't remove conditionals)
   - Keep `fetchFromGitHub`/`fetchurl` imports
   - Maintain maintainers field

4. **Test all variants**:
   ```bash
   nix build .#xen-orchestra-ce
   nix build .#xen-orchestra-ce-nixpkgs-test
   nix flake check
   ```

5. **Update documentation**:
   - Update CHANGELOG.md
   - Update VERSION-SYNC.md
   - Tag release

### Sync from Standalone to Core

When improvements here should go back to core:

1. **Review standalone changes**
2. **Adapt for core's structure**:
   - Remove dual-mode conditionals
   - Use only flake inputs
   - Remove `fetchFromGitHub`/`fetchurl` logic

3. **Test in core NiXOA system**
4. **Update core documentation**

See [VERSION-SYNC.md](../VERSION-SYNC.md) for detailed sync procedures.

## Development Workflow

### Making Changes

1. Create a branch:
   ```bash
   git checkout -b feature/my-improvement
   ```

2. Make changes to packages
3. Test changes:
   ```bash
   nix build .#xen-orchestra-ce
   nix build .#xen-orchestra-ce-nixpkgs-test
   nix flake check
   ```

4. Update documentation
5. Commit and push

### Release Process

1. Update CHANGELOG.md
2. Update VERSION-SYNC.md if syncing with core
3. Commit changes
4. Tag release:
   ```bash
   git tag -a v1.0.1 -m "Release v1.0.1: <summary>"
   git push origin v1.0.1
   ```

## Troubleshooting

### Build Failures

**Yarn hash mismatch**:
```bash
# Get correct hash from error message
nix build .#xen-orchestra-ce 2>&1 | grep "got:"
# Update hash in xen-orchestra-ce/default.nix
```

**Source hash mismatch**:
```bash
# For xen-orchestra-ce
nix-prefetch-github vatesfr xen-orchestra --rev <commit>

# For libvhdi
nix-prefetch-url <tarball-url>
```

### Flake Lock Issues

```bash
# Update all inputs
nix flake update

# Update specific input
nix flake lock --update-input xoSrc
nix flake lock --update-input libvhdiSrc
```

## Tips

- Use `nix develop` for a shell with all development tools
- Use `nixpkgs-review` before submitting to nixpkgs
- Always test both flake-input and nixpkgs-test variants
- Keep VERSION-SYNC.md updated when syncing with core
- Document all breaking changes in CHANGELOG.md
