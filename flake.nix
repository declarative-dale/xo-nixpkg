{
  description = "Xen Orchestra CE and libvhdi packages for NixOS";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    in
    {
      packages = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          xen-orchestra-ce = pkgs.callPackage ./xen-orchestra-ce/package.nix { };
          libvhdi = pkgs.callPackage ./libvhdi/package.nix { };
          default = self.packages.${system}.xen-orchestra-ce;
        }
      );

      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        {
          default = pkgs.mkShell {
            name = "xen-orchestra-ce-dev";
            packages = with pkgs; [
              nix-prefetch-github
              nix-prefetch
              nixfmt
              nix-update
              git
              jq
            ];
            shellHook = ''
              echo "Xen Orchestra CE development shell"
              echo ""
              echo "Build packages:"
              echo "  nix build .#xen-orchestra-ce"
              echo "  nix build .#libvhdi"
              echo ""
              echo "Update source hashes:"
              echo "  nix-prefetch-github vatesfr xen-orchestra --rev v<version>"
              echo "  nix-prefetch-url https://github.com/libyal/libvhdi/releases/download/<version>/libvhdi-alpha-<version>.tar.gz"
            '';
          };
        }
      );

      checks = forAllSystems (system: {
        xen-orchestra-ce = self.packages.${system}.xen-orchestra-ce;
        libvhdi = self.packages.${system}.libvhdi;
      });
    };
}
