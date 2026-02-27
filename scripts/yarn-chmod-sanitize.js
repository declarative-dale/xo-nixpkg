// Preload via NODE_OPTIONS="--require <this file>".
//
// Some npm packages ship tarballs containing files with setuid/setgid bits (e.g.
// fuse-shared-library-linux). In Nix sandboxes (often mounted with nosuid),
// attempting to apply those bits via chmod can fail with EPERM, aborting
// `yarn install`.
//
// We sanitize chmod() calls to strip setuid/setgid bits while preserving normal
// executable permissions.

'use strict'

const fs = require('fs')

const S_ISUID = 0o4000
const S_ISGID = 0o2000

function sanitizeMode (mode) {
  if (typeof mode === 'number') {
    return mode & ~(S_ISUID | S_ISGID)
  }

  // Yarn/tar sometimes passes a string like '755' or '0755'.
  if (typeof mode === 'string') {
    const parsed = Number.parseInt(mode, 8)
    if (!Number.isNaN(parsed)) {
      return parsed & ~(S_ISUID | S_ISGID)
    }
  }

  return mode
}

function wrap (obj, name) {
  const original = obj[name]
  if (typeof original !== 'function') return

  obj[name] = function (...args) {
    if (args.length >= 2) {
      args[1] = sanitizeMode(args[1])
    }
    return original.apply(this, args)
  }
}

// Sync + callback APIs
wrap(fs, 'chmod')
wrap(fs, 'chmodSync')
wrap(fs, 'fchmod')
wrap(fs, 'fchmodSync')
wrap(fs, 'lchmod')
wrap(fs, 'lchmodSync')

// Promise API
if (fs.promises) {
  wrap(fs.promises, 'chmod')
  wrap(fs.promises, 'fchmod')
  wrap(fs.promises, 'lchmod')
}
