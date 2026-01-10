# SPDX-License-Identifier: Apache-2.0
{
  description = "Xen Orchestra CE and libvhdi packages for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # Source inputs for development/testing
    xoSrc = {
      url = "github:vatesfr/xen-orchestra/9b6d1089f4b96ef07d7ddc25a943c466e8c7bb4b";
      flake = false;
    };

    libvhdiSrc = {
      url = "https://github.com/libyal/libvhdi/releases/download/20240509/libvhdi-alpha-20240509.tar.gz";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, xoSrc, libvhdiSrc }:
    let
      systems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in
    {
      packages = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          # Development versions using flake inputs
          xen-orchestra-ce = pkgs.callPackage ./xen-orchestra-ce {
            inherit xoSrc;
          };

          libvhdi = pkgs.callPackage ./libvhdi {
            inherit libvhdiSrc;
          };

          default = self.packages.${system}.xen-orchestra-ce;

          # Test versions using fetchFromGitHub/fetchurl (as they would work in nixpkgs)
          # These test the dual-mode functionality without flake inputs
          xen-orchestra-ce-nixpkgs-test = pkgs.callPackage ./xen-orchestra-ce {
            xoSrcRev = "9b6d1089f4b96ef07d7ddc25a943c466e8c7bb4b";
            # Note: This hash needs to be obtained via nix-prefetch-github
            xoSrcHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };

          libvhdi-nixpkgs-test = pkgs.callPackage ./libvhdi {
            version = "20240509";
            # Note: This hash needs to be obtained via nix-prefetch-url
            srcHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
          };
        }
      );

      devShells = forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            name = "xen-orchestra-ce-nix-dev";
            packages = with pkgs; [
              nix-prefetch-github
              nix-prefetch-url
              nixpkgs-fmt
              nixpkgs-review
              git
              jq
            ];
            shellHook = ''
              echo "xen-orchestra-ce-nix development shell"
              echo "========================================"
              echo ""
              echo "Available packages:"
              echo "  - xen-orchestra-ce         (development build with flake inputs)"
              echo "  - libvhdi                  (development build with flake inputs)"
              echo "  - xen-orchestra-ce-nixpkgs-test  (nixpkgs-style build)"
              echo "  - libvhdi-nixpkgs-test           (nixpkgs-style build)"
              echo ""
              echo "Useful commands:"
              echo "  nix build .#xen-orchestra-ce"
              echo "  nix build .#libvhdi"
              echo "  nix build .#xen-orchestra-ce-nixpkgs-test"
              echo "  nix build .#libvhdi-nixpkgs-test"
              echo "  nix flake check"
              echo ""
              echo "Update source hashes:"
              echo "  nix-prefetch-github vatesfr xen-orchestra --rev <commit-hash>"
              echo "  nix-prefetch-url https://github.com/libyal/libvhdi/releases/download/<version>/libvhdi-alpha-<version>.tar.gz"
            '';
          };
        }
      );

      # Checks for CI - ensure all package variants build successfully
      checks = forAllSystems (system: {
        xen-orchestra-ce-builds = self.packages.${system}.xen-orchestra-ce;
        libvhdi-builds = self.packages.${system}.libvhdi;
        # Note: nixpkgs-test variants commented out until hashes are updated
        # xen-orchestra-ce-nixpkgs = self.packages.${system}.xen-orchestra-ce-nixpkgs-test;
        # libvhdi-nixpkgs = self.packages.${system}.libvhdi-nixpkgs-test;
      });
    };
}
