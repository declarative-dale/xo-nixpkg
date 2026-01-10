<!-- SPDX-License-Identifier: Apache-2.0 -->
# Nixpkgs Submission Guide

This guide outlines the process for submitting xen-orchestra-ce and libvhdi packages to nixpkgs.

## Prerequisites

Before submission, ensure:

1. **Packages build successfully**
   ```bash
   nix build .#xen-orchestra-ce-nixpkgs-test
   nix build .#libvhdi-nixpkgs-test
   ```

2. **Source hashes are current**
   ```bash
   # Get xen-orchestra-ce source hash
   nix-prefetch-github vatesfr xen-orchestra --rev <commit-hash>

   # Get libvhdi source hash
   nix-prefetch-url https://github.com/libyal/libvhdi/releases/download/<version>/libvhdi-alpha-<version>.tar.gz

   # Get yarn dependencies hash (build will fail with correct hash in error)
   nix build .#xen-orchestra-ce-nixpkgs-test 2>&1 | grep "got:"
   ```

3. **All tests pass**
   ```bash
   nix flake check
   nixpkgs-review wip  # In nixpkgs checkout
   ```

## Submission Process

### Step 1: Fork and Clone Nixpkgs

```bash
# Fork nixpkgs on GitHub first
git clone https://github.com/YOUR-USERNAME/nixpkgs.git
cd nixpkgs
git remote add upstream https://github.com/NixOS/nixpkgs.git
```

### Step 2: Create Package Directories

```bash
# For xen-orchestra-ce
mkdir -p pkgs/by-name/xe/xen-orchestra-ce

# For libvhdi
mkdir -p pkgs/by-name/li/libvhdi
```

### Step 3: Prepare Package Files

#### For xen-orchestra-ce

1. **Copy files**:
   ```bash
   cp xen-orchestra-ce/default.nix pkgs/by-name/xe/xen-orchestra-ce/package.nix
   cp xen-orchestra-ce/yarn-chmod-sanitize.js pkgs/by-name/xe/xen-orchestra-ce/
   ```

2. **Edit package.nix**:
   - Remove default parameter values (the `? "..."` parts)
   - Update to use actual commit hash and source hash
   - Update maintainers list with your GitHub username

   Example changes:
   ```nix
   # Current (with defaults):
   { lib, stdenv, fetchFromGitHub, ...
   , xoSrcRev ? "9b6d1089f4b96ef07d7ddc25a943c466e8c7bb4b"
   , xoSrcHash ? "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA="
   , ...
   }:
   stdenv.mkDerivation rec {
     pname = "xen-orchestra-ce";
     version = "unstable-${builtins.substring 0 8 xoSrcRev}";
     src = fetchFromGitHub {
       owner = "vatesfr";
       repo = "xen-orchestra";
       rev = xoSrcRev;
       hash = xoSrcHash;
     };
     ...
   }

   # For nixpkgs (remove defaults, hardcode values):
   { lib, stdenv, fetchFromGitHub, ...
   }:
   stdenv.mkDerivation rec {
     pname = "xen-orchestra-ce";
     version = "unstable-2026-01-10";  # Use actual date

     src = fetchFromGitHub {
       owner = "vatesfr";
       repo = "xen-orchestra";
       rev = "9b6d1089f4b96ef07d7ddc25a943c466e8c7bb4b";
       hash = "sha256-ACTUAL-HASH-HERE";
     };
     ...
     meta = with lib; {
       ...
       maintainers = with maintainers; [ your-github-username ];
     };
   }
   ```

   **Note**: The package is already in pure nixpkgs form - the flake.nix handles development mode by overriding `src`. You just need to remove the default parameters and hardcode the values.

#### For libvhdi

1. **Copy file**:
   ```bash
   cp libvhdi/default.nix pkgs/by-name/li/libvhdi/package.nix
   ```

2. **Edit package.nix**:
   - Remove default parameter values (the `? "..."` parts)
   - Update to use actual version and source hash
   - Update maintainers list

   The package is already in pure nixpkgs form - just remove the defaults and hardcode values.

### Step 4: Add Yourself to Maintainers List (if not already present)

Edit `maintainers/maintainer-list.nix`:

```nix
your-github-username = {
  email = "your.email@example.com";
  github = "your-github-username";
  githubId = 12345678;  # Get from: curl -s https://api.github.com/users/YOUR-USERNAME | jq .id
  name = "Your Full Name";
};
```

### Step 5: Test the Packages

```bash
# Test build
nix-build -A xen-orchestra-ce
nix-build -A libvhdi

# Use nixpkgs-review for comprehensive testing
nixpkgs-review wip
```

### Step 6: Create Commit and PR

```bash
# Create branch
git checkout -b add-xen-orchestra-packages

# Commit changes
git add pkgs/by-name/xe/xen-orchestra-ce/
git add pkgs/by-name/li/libvhdi/
git add maintainers/maintainer-list.nix  # If you added yourself
git commit -m "xen-orchestra-ce, libvhdi: init"

# Push to your fork
git push origin add-xen-orchestra-packages
```

Then create a Pull Request on GitHub following the nixpkgs PR template.

## PR Description Template

```markdown
### Description of Changes

Add xen-orchestra-ce and libvhdi packages.

- **xen-orchestra-ce**: Web-based management interface for XCP-ng/XenServer
- **libvhdi**: Library and tools to access VHD/VHDX image formats

Both packages are built from source using deterministic Nix builds.

### Things Done

- [ ] Built on platform(s): x86_64-linux
- [ ] Tested with `nixpkgs-review wip`
- [ ] All tests pass: `nix flake check`
- [ ] Added myself to maintainers list
- [ ] Followed pkgs/by-name conventions
- [ ] Added appropriate meta fields

### Package Details

**xen-orchestra-ce**:
- Source: GitHub vatesfr/xen-orchestra
- License: AGPL-3.0-only
- Build system: Yarn v1
- Commit: <commit-hash>

**libvhdi**:
- Source: GitHub libyal/libvhdi releases
- License: LGPL-3.0-or-later
- Build system: Autotools
- Version: 20240509
```

## Post-Submission

After submitting the PR:

1. **Respond to review feedback promptly**
2. **Update packages as needed**
3. **Keep this repository in sync** - update VERSION-SYNC.md when PR is merged

## References

- [Nixpkgs Contributing Guide](https://github.com/NixOS/nixpkgs/blob/master/CONTRIBUTING.md)
- [pkgs/by-name README](https://github.com/NixOS/nixpkgs/blob/master/pkgs/by-name/README.md)
- [Nixpkgs Manual - Quick Start](https://nixos.org/manual/nixpkgs/stable/#chap-quick-start)
