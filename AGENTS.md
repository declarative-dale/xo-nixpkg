# Repository Guidelines

## Project Structure & Module Organization
This repository packages Xen Orchestra CE and libvhdi for Nix and is structured for nixpkgs submission. The Xen Orchestra package definition lives in `default.nix`, helper scripts live under `scripts/` (`scripts/update.sh`, `scripts/yarn-chmod-sanitize.js`), and flake wiring is in `flake.nix`/`flake.lock`. Supporting docs are under `docs/`, with examples in `examples/`.

## Build, Test, and Development Commands
- `nix develop`: Enter the dev shell.
- `nix build .#xen-orchestra-ce`: Build Xen Orchestra CE.
- `nix build .#libvhdi`: Build libvhdi (from flake input).
- `nix flake check --all-systems --no-build`: Evaluate all declared outputs for both supported systems.
- `./scripts/update.sh`: Refresh Xen Orchestra version, source hash, and yarn offline cache hash in `default.nix`.
- `nix flake lock --update-input libvhdi`: Update the pinned libvhdi input.

## Coding Style & Naming Conventions
- Nix files use 2-space indentation and nixpkgs-style attribute naming.
- Keep `default.nix` pure and submission-oriented.
- Keep package logic in `default.nix` and auxiliary tooling under `scripts/`.

## Testing Guidelines
- Validate with `nix flake check --all-systems --no-build`.
- Build target packages before opening PRs.
- Smoke-test binaries after building:
  - `./result/bin/xo-server --help`
  - `./result/bin/vhdiinfo --version`

## Commit & Pull Request Guidelines
- Prefer short, descriptive commit messages (package scope first, then intent).
- PRs should describe version bumps, include updated hashes, and link relevant upstream commits.

## Sync & Submission Notes
- This repo is synced with NiXOA core; keep `VERSION-SYNC.md` current when syncing.
- Ensure docs and workflows match the current package layout before submission.
