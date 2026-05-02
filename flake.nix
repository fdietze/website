{
  description = "Zola site for felx.me";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        packages.default = pkgs.stdenvNoCC.mkDerivation {
          pname = "felx-me";
          version = "0.1.0";
          src = ./.;
          nativeBuildInputs = [
            pkgs.bash
            pkgs.zola
          ];

          buildPhase = ''
            runHook preBuild
            ${pkgs.bash}/bin/bash ./scripts/build-site.sh
            runHook postBuild
          '';

          installPhase = ''
            runHook preInstall
            cp -r public $out
            runHook postInstall
          '';
        };

        devShells.default = pkgs.mkShellNoCC {
          packages = with pkgs; [
            zola
            nil
            nixfmt-rfc-style
          ];
        };

        formatter = pkgs.nixfmt-rfc-style;
      });
}
