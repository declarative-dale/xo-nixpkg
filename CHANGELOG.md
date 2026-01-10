<!-- SPDX-License-Identifier: Apache-2.0 -->
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [1.0.0] - 2026-01-10

### Added
- Initial repository structure for nixpkgs submission
- Dual-mode package definitions supporting both flake inputs and traditional fetchers
- xen-orchestra-ce package with Yarn v1 deterministic builds
- libvhdi package with VHD/VHDX support
- Comprehensive documentation (README, nixpkgs submission guide, development guide, testing guide)
- Development flake with multiple build variants
- CI/CD workflow for automated testing
- VERSION-SYNC.md for tracking synchronization with NiXOA core

### Technical Details
- xen-orchestra-ce: Based on commit 9b6d1089f4b96ef07d7ddc25a943c466e8c7bb4b
- libvhdi: Version 20240509
- Yarn offline cache hash: sha256-3vt/oIJ3JF2+0lGftq1IKckKoWVA1qNZZsl/bhRQ4Eo=

### Notes
- Synced from NiXOA core v0.5
- Ready for future nixpkgs submission (pending hash updates for nixpkgs-test variants)
- Nixpkgs submission status: Not yet submitted

[Unreleased]: https://github.com/YOUR-USER/xen-orchestra-ce-nix/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/YOUR-USER/xen-orchestra-ce-nix/releases/tag/v1.0.0
