# SPDX-License-Identifier: Apache-2.0
# Xen Orchestra Community Edition (XO-CE) — deterministic Yarn v1 build.
#
# Why this structure:
# - Xen Orchestra uses a Yarn v1 workspace monorepo.
# - Nixpkgs provides fetchYarnDeps + yarn{Config,Build}Hook for Yarn v1.
#   This lets us build fully offline (sandboxed) with a fixed-output yarn cache.
#
# Optional workaround:
# - Some npm tarballs contain files with setuid/setgid bits.
# - In Nix sandboxes, chmod() of those bits can fail (EPERM) due to nosuid.
# - enableChmodSanitizer makes Node strip those bits during yarn extraction.

{ lib
, stdenv
, fetchYarnDeps
, yarn
, yarnConfigHook
, yarnBuildHook
, writableTmpDirAsHomeHook
, nodejs_24
, esbuild
, git
, python3
, pkg-config
, makeWrapper
, libpng
, zlib
, fuse3

, xoSrc

# Enabled by default; disable if needed by passing `enableChmodSanitizer = false;`.
, enableChmodSanitizer ? true
, yarnChmodSanitize ? ./yarn-chmod-sanitize.js
, ...
}:

stdenv.mkDerivation rec {
  pname = "xen-orchestra-ce";
  version = "unstable-${builtins.substring 0 8 xoSrc.rev}";

  src = xoSrc;

  # Fixed-output offline mirror for Yarn.
  # Update the hash with: nix build .#xen-orchestra-ce (then replace with actual hash).
  yarnOfflineCache = fetchYarnDeps {
    yarnLock = "${src}/yarn.lock";
    hash = "sha256-3vt/oIJ3JF2+0lGftq1IKckKoWVA1qNZZsl/bhRQ4Eo=";
  };

  nativeBuildInputs = [
    writableTmpDirAsHomeHook

    # Yarn v1 and hooks
    yarn
    yarnConfigHook
    yarnBuildHook

    # Needed for executing package.json scripts
    nodejs_24
    esbuild

    # Some scripts expect git to exist (and it's cheap)
    git

    # Native addons
    python3
    pkg-config

    # Runtime entrypoint
    makeWrapper
  ];

  buildInputs = [
    fuse3
    zlib
    libpng
    stdenv.cc.cc.lib
  ];

  # Keep builds quiet/deterministic.
  HUSKY = "0";
  CI = "1";

  # Make sure Yarn does NOT drop devDependencies (vite/vue-tsc live there).
  # Leave NODE_ENV unset to avoid conflicts with build environment defaults.
  YARN_PRODUCTION = "false";
  NPM_CONFIG_PRODUCTION = "false";

  # If you hit `EPERM: operation not permitted, chmod ...` in sandbox,
  # enableChmodSanitizer will strip setuid/setgid bits during extraction.
  NODE_OPTIONS = lib.optionalString enableChmodSanitizer "--require ${yarnChmodSanitize}";

  # Flags for yarn install (and sometimes reused by build hooks).
  yarnInstallFlags = [
    "--offline"
    "--frozen-lockfile"
    "--non-interactive"
    "--ignore-engines"
    "--production=false"
  ];

  # Keep the old name too (some nixpkgs versions/hooks read yarnFlags).
  yarnFlags = yarnInstallFlags;

  # After yarnConfigHook has populated node_modules, patch bin shebangs thoroughly.
  # This fixes the common case where node_modules/.bin/* are symlinks to scripts
  # that still have "#!/usr/bin/env node" and fail as "not found" under /bin/sh.
  postConfigure = ''
    patchShebangs node_modules
  '';

  # Create real wrapper scripts for vite/vue-tsc that bypass /usr/bin/env.
  # In Nix sandboxes, node_modules/.bin shims with #!/usr/bin/env node fail (ENOENT)
  # because /usr/bin/env doesn't exist. These wrappers call ${nodejs_24}/bin/node directly.
  preBuild = ''
    set -euo pipefail

    # Find actual vite/vue-tsc entrypoints by following .bin shims (may be symlinks)
    vite_target="$(readlink -f node_modules/.bin/vite 2>/dev/null || true)"
    vue_tsc_target="$(readlink -f node_modules/.bin/vue-tsc 2>/dev/null || true)"

    if [ -z "$vite_target" ]; then
      echo "ERROR: Cannot find vite in node_modules/.bin" >&2
      exit 1
    fi
    if [ -z "$vue_tsc_target" ]; then
      echo "ERROR: Cannot find vue-tsc in node_modules/.bin" >&2
      exit 1
    fi

    # Create *real* executables inside the workspace package(s) so Turbo/Yarn scripts can always run them.
    mkToolWrappers() {
      local pkg="$1"
      [ -d "$pkg" ] || return 0

      mkdir -p "$pkg/node_modules/.bin"

      cat > "$pkg/node_modules/.bin/vite" <<'WRAPPER'
#!${stdenv.shell}
exec ${nodejs_24}/bin/node "VITE_TARGET" "$@"
WRAPPER
      sed -i 's|VITE_TARGET|'"$vite_target"'|g' "$pkg/node_modules/.bin/vite"
      chmod +x "$pkg/node_modules/.bin/vite"

      cat > "$pkg/node_modules/.bin/vue-tsc" <<'WRAPPER'
#!${stdenv.shell}
exec ${nodejs_24}/bin/node "VUE_TSC_TARGET" "$@"
WRAPPER
      sed -i 's|VUE_TSC_TARGET|'"$vue_tsc_target"'|g' "$pkg/node_modules/.bin/vue-tsc"
      chmod +x "$pkg/node_modules/.bin/vue-tsc"
    }

    # Create wrappers in all web packages
    mkToolWrappers "@xen-orchestra/web"
    mkToolWrappers "packages/xo-web"
    mkToolWrappers "xo-web"

    echo "Verifying build tools are now created:"
    echo "vite target: $vite_target"
    echo "vue-tsc target: $vue_tsc_target"
    ls -la "@xen-orchestra/web/node_modules/.bin/vite" || echo "vite wrapper missing"
    ls -la "@xen-orchestra/web/node_modules/.bin/vue-tsc" || echo "vue-tsc wrapper missing"
  '';

  # Build phase: run yarn with wrappers in place.
  # Use TURBO_CONCURRENCY=1 to prevent OOM during TypeScript compilation (serialize tasks).
  buildPhase = ''
    runHook preBuild
    TURBO_CONCURRENCY=1 yarn --offline run build
    runHook postBuild
  '';

  # Conditional patching: only patches if file exists and has expected pattern.
  # This makes updates to xoSrc.rev survive upstream fixes without breaking the build.
  postPatch = ''
    # Patch 1: SMB handler needs createReadStream
    if [ -f packages/xo-server/src/xo-mixins/storage/smb.js ] \
      && grep -q "const { join } = require('path')" packages/xo-server/src/xo-mixins/storage/smb.js; then
      substituteInPlace packages/xo-server/src/xo-mixins/storage/smb.js \
        --replace-fail "const { join } = require('path')" \
                       "const { join } = require('path'); const { createReadStream } = require('fs')"
    fi

    # Patch 2: Fix missing createReadStream import in FS module
    if [ -f @xen-orchestra/fs/src/index.js ] \
      && grep -q "const { asyncIterableToStream }" @xen-orchestra/fs/src/index.js \
      && ! grep -q "createReadStream" @xen-orchestra/fs/src/index.js; then
      substituteInPlace @xen-orchestra/fs/src/index.js \
        --replace-fail "const { asyncIterableToStream } = require('./_asyncIterableToStream')" \
                       "const { createReadStream } = require('node:fs');\nconst { asyncIterableToStream } = require('./_asyncIterableToStream')"
    fi

    # Patch 3: Create minimal .git directory so git rev-parse --short HEAD works.
    # XO's xo-server Babel config calls git to get the commit hash.
    # Flake sources are tarball checkouts without .git/, so create one with our pinned rev.
    if [ ! -e .git ]; then
      mkdir -p .git/objects .git/refs

      cat > .git/config <<'GITCONFIG'
[core]
    repositoryformatversion = 0
    filemode = true
    bare = false
    logallrefupdates = true
GITCONFIG

      # Detached HEAD with the pinned flake revision
      echo "${xoSrc.rev}" > .git/HEAD

      # Sanity check: verify git rev-parse works
      git rev-parse --short HEAD
    fi
  '';

  # yarnConfigHook runs the yarn install using the offline cache.
  # yarnBuildHook runs: yarn --offline build
  # Both happen automatically, no manual phases needed!

  installPhase = ''
    runHook preInstall

    mkdir -p $out/libexec/xen-orchestra
    mkdir -p $out/bin

    # Keep symlinks as symlinks (important for yarn workspaces).
    cp -a packages node_modules package.json yarn.lock $out/libexec/xen-orchestra/

    # Some revisions include these top-level workspace scopes.
    if [ -d @xen-orchestra ]; then cp -a @xen-orchestra $out/libexec/xen-orchestra/; fi
    if [ -d @vates ]; then cp -a @vates $out/libexec/xen-orchestra/; fi

    # Needed because many workspace packages symlink dev files like:
    #   .npmignore -> ../../scripts/npmignore
    #   .eslintrc.js -> ../../scripts/babel-eslintrc.js
    if [ -d scripts ]; then
      cp -a scripts $out/libexec/xen-orchestra/
    fi

    # Optional docs
    if [ -f README.md ]; then cp -a README.md $out/libexec/xen-orchestra/; fi
    if [ -f LICENSE ]; then cp -a LICENSE $out/libexec/xen-orchestra/; fi

    # Runtime entrypoint (using upstream's bin wrapper)
    makeWrapper ${nodejs_24}/bin/node $out/bin/xo-server \
      --chdir $out/libexec/xen-orchestra \
      --add-flags "packages/xo-server/bin/xo-server"

    runHook postInstall
  '';

  # Remove any remaining dangling symlinks that point to dev-only files we don't ship.
  # This ensures Nix's noBrokenSymlinks check passes.
  # Note: -xtype l matches broken symlinks only (not valid workspace links).
  preFixup = ''
    find "$out/libexec/xen-orchestra" -xtype l -print -delete || true
  '';

  meta = with lib; {
    description = "Xen Orchestra Community Edition (built from source)";
    homepage = "https://xen-orchestra.com";
    license = licenses.agpl3Only;
    platforms = platforms.linux;
    mainProgram = "xo-server";
  };
}
