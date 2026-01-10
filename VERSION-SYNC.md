<!-- SPDX-License-Identifier: Apache-2.0 -->
# Version Sync Tracking

This document tracks version synchronization between NiXOA core and this standalone package repository.

## Current Status

| Repository | Version | Last Sync | Core Version | Nixpkgs Status |
|------------|---------|-----------|--------------|----------------|
| xen-orchestra-ce-nix | v1.0.0 | 2026-01-10 | v0.5 | Not submitted |

## Sync History

### 2026-01-10: Initial Repository Structure (v1.0.0)
- Created standalone repository structure
- Synced packages from NiXOA core v0.5
- Restructured for nixpkgs submission:
  - Added dual-mode source handling (flake inputs OR fetchFromGitHub/fetchurl)
  - Added maintainers fields
  - Reorganized directory structure (xen-orchestra-ce/, libvhdi/ subdirectories)
  - Created comprehensive documentation
- Source versions:
  - xen-orchestra-ce: commit 9b6d1089f4b96ef07d7ddc25a943c466e8c7bb4b
  - libvhdi: version 20240509
  - Yarn cache: sha256-3vt/oIJ3JF2+0lGftq1IKckKoWVA1qNZZsl/bhRQ4Eo=

## Sync Procedure

### Core → Standalone (After Core Changes)

When changes are made in NiXOA core that should be reflected here:

1. **Review changes in core**
   ```bash
   cd /path/to/NiXOA/core
   git log --oneline pkgs/xen-orchestra-ce/
   git log --oneline pkgs/libvhdi/
   ```

2. **Compare with standalone**
   ```bash
   diff -u /path/to/NiXOA/core/pkgs/xen-orchestra-ce/default.nix xen-orchestra-ce/default.nix
   diff -u /path/to/NiXOA/core/pkgs/libvhdi/default.nix libvhdi/default.nix
   ```

3. **Merge changes manually**
   - Copy derivation logic updates
   - Preserve dual-mode structure (don't remove fetchFromGitHub/fetchurl)
   - Keep maintainers field
   - Test all build variants

4. **Update documentation**
   - Update CHANGELOG.md
   - Update this VERSION-SYNC.md

5. **Tag release**
   ```bash
   git tag -a v1.0.1 -m "Sync with NiXOA core: <describe changes>"
   git push origin v1.0.1
   ```

### Standalone → Core (After Standalone Improvements)

When improvements are made here that should go back to core:

1. **Review standalone changes**
   ```bash
   git log --oneline xen-orchestra-ce/
   git log --oneline libvhdi/
   ```

2. **Adapt for core's flake-input structure**
   - Remove dual-mode conditional logic
   - Use only flake inputs (xoSrc, libvhdiSrc)
   - Remove fetchFromGitHub/fetchurl imports

3. **Test in core NiXOA system**
   ```bash
   cd /path/to/NiXOA/system
   sudo nixos-rebuild test
   ```

4. **Update core CHANGELOG.md**

## Sync Checklist

When syncing from core to standalone:

- [ ] Compare default.nix files with diff
- [ ] Review git log for changes
- [ ] Update source revisions/versions if changed
- [ ] Update hashes (yarn deps, source) if needed
- [ ] Test flake-input builds (`nix build .#xen-orchestra-ce .#libvhdi`)
- [ ] Test nixpkgs-style builds (`nix build .#xen-orchestra-ce-nixpkgs-test .#libvhdi-nixpkgs-test`)
- [ ] Run flake check (`nix flake check`)
- [ ] Update CHANGELOG.md
- [ ] Update this VERSION-SYNC.md
- [ ] Commit and tag release
- [ ] Update nixpkgs PR if open

When syncing from standalone to core:

- [ ] Review standalone improvements
- [ ] Adapt for flake input structure (remove conditional logic)
- [ ] Test in core NiXOA system build
- [ ] Update core CHANGELOG.md
- [ ] Update this VERSION-SYNC.md

## Notes

- **Parallel Sync Strategy**: Core and standalone repos evolve independently
- **Manual Synchronization**: Changes are not automatically synced
- **Divergence is Acceptable**: Standalone can have nixpkgs-specific modifications
- **Version Independence**: Tags/versions are independent between repos
