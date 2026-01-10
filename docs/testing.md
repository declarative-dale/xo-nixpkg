<!-- SPDX-License-Identifier: Apache-2.0 -->
# Testing Guide

## Local Testing

### Build Tests

```bash
# Test all packages with flake check
nix flake check

# Build individual packages (flake-input mode)
nix build .#xen-orchestra-ce
nix build .#libvhdi

# Build nixpkgs-test variants (requires updated hashes)
nix build .#xen-orchestra-ce-nixpkgs-test
nix build .#libvhdi-nixpkgs-test
```

### Runtime Tests

#### xen-orchestra-ce

```bash
# Build package
nix build .#xen-orchestra-ce

# Test binary exists and executes
./result/bin/xo-server --help

# Expected: Usage information without errors

# Check version info
./result/bin/xo-server --version

# Test with minimal config (will fail without Redis, but tests binary works)
cat > test-config.toml <<EOF
[http]
listen = "localhost"
port = 8080
EOF

./result/bin/xo-server --config test-config.toml
# Expected: Error about Redis connection (binary is working)
```

#### libvhdi

```bash
# Build package
nix build .#libvhdi

# Test utilities
./result/bin/vhdiinfo --version
./result/bin/vhdimount --version
./result/bin/vhdiexport --version

# Test with actual VHD file (if available)
# ./result/bin/vhdiinfo /path/to/test.vhd
```

## Testing Matrix

| Test Type | xo-ce (flake) | xo-ce (nixpkgs) | libvhdi (flake) | libvhdi (nixpkgs) |
|-----------|---------------|------------------|-----------------|-------------------|
| Build | ✓ | ✓ | ✓ | ✓ |
| Binary execution | ✓ | ✓ | ✓ | ✓ |
| Help/version output | ✓ | ✓ | ✓ | ✓ |
| Flake check | ✓ | ✓ | ✓ | ✓ |
| No broken symlinks | ✓ | ✓ | ✓ | ✓ |

## Nixpkgs Review Testing

Before submitting to nixpkgs, use `nixpkgs-review` for comprehensive testing:

```bash
# Enter dev shell (includes nixpkgs-review)
nix develop

# Clone and prepare nixpkgs
git clone https://github.com/YOUR-USERNAME/nixpkgs
cd nixpkgs

# Copy packages as they would appear in nixpkgs
mkdir -p pkgs/by-name/xe/xen-orchestra-ce
mkdir -p pkgs/by-name/li/libvhdi

# Copy and adapt files (see nixpkgs-submission.md)
# Then test with nixpkgs-review

nixpkgs-review wip
```

## Integration Testing with NiXOA Core

Test that packages work with the full NiXOA system:

```bash
# In your NiXOA system configuration
# Add this repository as a flake input

{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    xo-ce-nix.url = "path:/home/nixos/projects/NiXOA/xen-orchestra-ce-nix";
    # ... other inputs
  };

  # Use packages from standalone repo
  environment.systemPackages = [
    xo-ce-nix.packages.x86_64-linux.xen-orchestra-ce
    xo-ce-nix.packages.x86_64-linux.libvhdi
  ];
}

# Rebuild and test
sudo nixos-rebuild test
```

## Regression Testing

### Checklist

Before each release, verify:

**xen-orchestra-ce**:
- [ ] Package builds successfully
- [ ] xo-server binary executes without errors
- [ ] xo-server --help shows usage information
- [ ] Package includes all required dependencies
- [ ] No broken symlinks in output (`find result -xtype l`)
- [ ] Yarn offline cache works (reproducible builds)
- [ ] Meta fields are complete and accurate
- [ ] License information is correct (AGPL-3.0-only)

**libvhdi**:
- [ ] Package builds successfully
- [ ] vhdiinfo binary works
- [ ] vhdimount binary works
- [ ] vhdiexport binary works
- [ ] Library file exists (`ls result/lib/libvhdi.so`)
- [ ] FUSE support enabled
- [ ] No broken symlinks in output
- [ ] Meta fields are complete and accurate
- [ ] License information is correct (LGPL-3.0-or-later)

**Both packages**:
- [ ] Flake check passes
- [ ] Nixpkgs-test variants build (if hashes updated)
- [ ] Documentation is up to date
- [ ] CHANGELOG.md reflects changes
- [ ] VERSION-SYNC.md is current

## Performance Testing

### Build Time

```bash
# Measure build time for xen-orchestra-ce
time nix build .#xen-orchestra-ce --rebuild

# Measure build time for libvhdi
time nix build .#libvhdi --rebuild
```

### Output Size

```bash
# Check package closure size
nix path-info -Sh ./result

# Check full dependency closure
nix path-info -rSh ./result | sort -h
```

## Automated Testing with CI

The repository includes GitHub Actions workflow (`.github/workflows/ci.yml`) that:

- Builds all package variants
- Runs flake checks
- Tests binary execution
- Can be extended with additional tests

### Running CI Locally

If you have `act` installed:

```bash
act -j build
```

## Common Test Failures

### Yarn Hash Mismatch

**Problem**: `hash mismatch in fixed-output derivation`

**Solution**:
```bash
nix build .#xen-orchestra-ce 2>&1 | grep "got:"
# Copy hash from "got:" line to xen-orchestra-ce/default.nix
```

### Source Hash Mismatch

**Problem**: `hash mismatch` for xoSrc or libvhdiSrc

**Solution**:
```bash
# For xen-orchestra-ce
nix-prefetch-github vatesfr xen-orchestra --rev <commit-hash>

# For libvhdi
nix-prefetch-url <tarball-url>

# Update hash in flake.nix
```

### Broken Symlinks

**Problem**: Build fails with `Symlink target does not exist`

**Solution**: Check the `preFixup` phase - it should remove broken symlinks:
```nix
preFixup = ''
  find "$out/libexec/xen-orchestra" -xtype l -print -delete || true
'';
```

### Missing Dependencies

**Problem**: Binary fails to execute or missing library errors

**Solution**: Check `buildInputs` and `nativeBuildInputs` - all required dependencies must be listed.

## Test Reports

When reporting test results (for PRs, issues, etc.), include:

```bash
# System information
nix-shell -p nix-info --run "nix-info -m"

# Build results
nix build .#xen-orchestra-ce
nix build .#libvhdi

# Flake check results
nix flake check

# Binary test results
./result/bin/xo-server --version
./result/bin/vhdiinfo --version

# Closure size
nix path-info -Sh ./result
```
