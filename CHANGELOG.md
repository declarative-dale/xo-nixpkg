<!-- SPDX-License-Identifier: Apache-2.0 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.1.0] - 2026-02-27

### Changed
- Updated xen-orchestra-ce package to 6.2.0 with refreshed source and yarn offline cache hashes.
- Updated pinned `libvhdi` flake input to latest tracked revision.
- Refactored package layout for submission prep:
  - moved package definition to top-level `default.nix`
  - moved helper tools to `scripts/`
- Updated GitHub and Forgejo update workflows to operate on `default.nix` and use current repository paths.
- Refreshed README and docs to match the current flake outputs and package structure.

### Fixed
- Added TypeScript compatibility patching for `xo-server-openmetrics` build path.
- Corrected stale package metadata comments and removed placeholder maintainer comment block.

## [1.0.0] - 2026-01-10

### Added
- Initial repository structure for nixpkgs submission.
- xen-orchestra-ce package with Yarn v1 deterministic builds.
- libvhdi package integration.
- Documentation set (README, submission, development, testing).
- CI workflows for checks and package builds.
- VERSION-SYNC.md for core/standalone tracking.

[Unreleased]: https://codeberg.org/NiXOA/xen-orchestra-ce
[1.1.0]: https://codeberg.org/NiXOA/xen-orchestra-ce/releases/tag/v1.1.0
[1.0.0]: https://codeberg.org/NiXOA/xen-orchestra-ce/releases/tag/v1.0.0
