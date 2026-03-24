{
  description = "Build Freeciv from local source";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;
    in {
      packages = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.freeciv.overrideAttrs (old: {
            pname = "freeciv";
            version = "source";
            src = self;

            nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [
              pkgs.autoreconfHook
              pkgs.python3
            ];

            preConfigure = (old.preConfigure or "") + ''
              mkdir -p build
              cd build
            '';

            configureScript = "../configure";

            configureFlags = (old.configureFlags or [ ]) ++ [
              "--enable-ack-legacy"
            ];

            postPatch = (old.postPatch or "") + ''
              patchShebangs gen_headers utility
            '';
          });
        });

      devShells = forAllSystems (system:
        let
          pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            inputsFrom = [ self.packages.${system}.default ];
          };
        });
    };
}
