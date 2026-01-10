# SPDX-License-Identifier: Apache-2.0
# libvhdi Package - Library and tools to access Virtual Hard Disk (VHD) image format
# Provides vhdimount (FUSE-based VHD mounter), vhdiinfo, and vhdiexport utilities.
#
# This file is structured for nixpkgs submission.
# When submitting to nixpkgs, it will be placed at:
# pkgs/by-name/li/libvhdi/package.nix

{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  pkg-config,
  fuse,
  fuse3,
  zlib,

  # Source parameters
  version ? "20240509",
  srcHash ? "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=",
}:

stdenv.mkDerivation {
  pname = "libvhdi";
  inherit version;

  src = fetchurl {
    url = "https://github.com/libyal/libvhdi/releases/download/${version}/libvhdi-alpha-${version}.tar.gz";
    hash = srcHash;
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    fuse # FUSE2 for vhdimount
    fuse3 # FUSE3 support
    zlib # Compression support
  ];

  configureFlags = [
    "--enable-shared"
    "--enable-static=no"
    "--enable-python=no"
    "--with-libfuse=yes"
    "--enable-multi-threading=yes"
    "--enable-wide-character-type"
  ];

  enableParallelBuilding = true;

  postInstall = ''
    # Verify the library and tools were built
    if [ ! -f "$out/lib/libvhdi.so" ]; then
      echo "Error: libvhdi.so not found after build" >&2
      exit 1
    fi

    if [ ! -f "$out/bin/vhdimount" ]; then
      echo "Error: vhdimount tool not found after build" >&2
      exit 1
    fi

    if [ ! -f "$out/bin/vhdiinfo" ]; then
      echo "Error: vhdiinfo tool not found after build" >&2
      exit 1
    fi

    echo "libvhdi tools installed:"
    ls -la "$out/bin/"
  '';

  meta = with lib; {
    description = "Library and tools to access the Virtual Hard Disk (VHD) image format";
    longDescription = ''
      libvhdi provides:
      - vhdiinfo: Display information about VHD/VHDX files
      - vhdimount: FUSE-based tool to mount VHD/VHDX as a filesystem
      - vhdiexport: Export VHD data to raw format

      Used by Xen Orchestra for backup restore and disk inspection operations.
      This package supports both VHD (Virtual Hard Disk) and VHDX (Virtual Hard Disk v2) formats.
    '';
    homepage = "https://github.com/libyal/libvhdi";
    license = licenses.lgpl3Plus;
    platforms = platforms.linux;
    maintainers = with maintainers; [
      # Add your GitHub username here when submitting to nixpkgs
    ];
  };
}
