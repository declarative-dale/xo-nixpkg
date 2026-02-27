<!-- SPDX-License-Identifier: Apache-2.0 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [v6.2.0] - 2026-02-27

### Changed
- Updated xen-orchestra-ce packaging to `6.2.0` and refreshed source/yarn hashes for reproducible builds.
- Refreshed flake inputs and lock state (including `nixpkgs`/`libvhdi`) and removed the legacy in-repo `libvhdi` package copy.
- Improved update automation to use `scripts/update.sh` and update both source and yarn cache hashes.
- Refactored repository layout for nixpkgs submission readiness (`default.nix` at repo root, helper tooling under `scripts/`).
- Refreshed README and docs to match current flake outputs and package structure.

### Fixed
- Added TypeScript compatibility patching for `xo-server-openmetrics` build path.
- Corrected stale package metadata comments and removed placeholder maintainer comment block.

## [v6.1.1] - 2026-01-10

This release updates Xen Orchestra packaging and refreshes libvhdi integration.

### Highlights
- Updated Xen Orchestra package to `6.1.1`.
- Updated `libvhdi` packaging to the latest upstream version.
- Added `AGENTS.md` guidance for LLM-assisted workflows.
- Included CI workflow examples for monitoring upstream XO release updates.

### Notable commits
- 6468ffa: updated libvhdi to latest version
- 91c0b79: updated to 6.1.1
- a131725: added Agents.md to assist with LLM tools

### Notes
- Verified `yarnOfflineCache.hash` after source bumps to `yarn.lock` changes.
