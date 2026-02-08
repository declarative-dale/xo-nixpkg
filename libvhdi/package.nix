{
  lib,
  stdenv,
  fetchurl,
  autoreconfHook,
  pkg-config,
  fuse,
  fuse3,
  zlib,
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "libvhdi";
  version = "20251119";

  src = fetchurl {
    url = "https://github.com/libyal/libvhdi/releases/download/${finalAttrs.version}/libvhdi-alpha-${finalAttrs.version}.tar.gz";
    hash = "sha256-nv6+VKeubPi0kQOjoMN1U/PyLXUmMDplSutZ7KWMzsc=";
  };

  nativeBuildInputs = [
    autoreconfHook
    pkg-config
  ];

  buildInputs = [
    fuse
    fuse3
    zlib
  ];

  configureFlags = [
    "--enable-shared"
    "--disable-static"
    "--disable-python"
    "--with-libfuse"
    "--enable-multi-threading"
    "--enable-wide-character-type"
  ];

  enableParallelBuilding = true;

  doCheck = true;

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Library and tools to access the Virtual Hard Disk (VHD) image format";
    longDescription = ''
      libvhdi is a library to access the Virtual Hard Disk (VHD) and
      Virtual Hard Disk version 2 (VHDX) image formats.

      It provides the following tools:
      - vhdiinfo: shows information about VHD/VHDX files
      - vhdimount: FUSE-based tool to mount VHD/VHDX images
      - vhdiexport: exports VHD data to raw format
    '';
    homepage = "https://github.com/libyal/libvhdi";
    changelog = "https://github.com/libyal/libvhdi/releases/tag/${finalAttrs.version}";
    license = lib.licenses.lgpl3Plus;
    maintainers = with lib.maintainers; [
      # Add maintainer here
    ];
    platforms = lib.platforms.linux;
  };
})
