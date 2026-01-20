# Repository Guidelines

## Project Structure & Module Organization
This repository packages Xen Orchestra CE and libvhdi for Nix and is structured for nixpkgs submission. Package definitions live in `xen-orchestra-ce/package.nix` and `libvhdi/package.nix`. Update helpers are in `xen-orchestra-ce/update.sh` and `libvhdi/update.sh`. Flake wiring and dev tooling are in `flake.nix`/`flake.lock`. Supporting docs are under `docs/`, with examples in `examples/`.

## Build, Test, and Development Commands
- `nix develop`: Enter the dev shell with tooling.
- `nix build .#xen-orchestra-ce` / `nix build .#libvhdi`: Build packages with flake inputs (development mode).
- `nix build .#xen-orchestra-ce-nixpkgs-test` / `nix build .#libvhdi-nixpkgs-test`: Nixpkgs-style build verification (update hashes first).
- `nix flake check`: Run flake checks.
- `./xen-orchestra-ce/update.sh` / `./libvhdi/update.sh`: Refresh upstream versions and hashes.

## Coding Style & Naming Conventions
- Nix files use 2-space indentation and nixpkgs-style attribute naming.
- Keep `package.nix` pure (no flake-specific logic); flake overrides belong in `flake.nix`.
- Use clear, scoped filenames: `xen-orchestra-ce/package.nix`, `libvhdi/package.nix`.

## Testing Guidelines
- Validate with `nix flake check` and a build of the target package.
- Smoke-test binaries after building:
  - `./result/bin/xo-server --help`
  - `./result/bin/vhdiinfo --version`

## Commit & Pull Request Guidelines
- Prefer short, descriptive commit messages (package scope first, then intent).
- PRs should describe version bumps, include new hashes, and link any upstream release or commit references.

## Sync & Submission Notes
- This repo is synced with NiXOA core; keep `VERSION-SYNC.md` updated when syncing changes.
- Ensure nixpkgs-test builds pass before proposing upstream submissions.
