{
  description = "a simple logger for nix";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = {
    self,
    nixpkgs,
    ...
  }: let
    supportedSystems = ["x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin"];
    forAllSystems = nixpkgs.lib.genAttrs supportedSystems;
    nixpkgsFor = forAllSystems (system: import nixpkgs {inherit system;});
  in rec {
    lib = import ./lib.nix;

    templates = {
      default = {
        path = ./examples;
        description = "A simple logger for nix";
      };
    };

    devShells = forAllSystems (
      system: let
        pkgs = nixpkgsFor.${system};
        shell = import ./tests/shell.nix {
          inherit pkgs;
          logger = self.lib;
        };
      in {
        default = shell;
      }
    );

    apps = forAllSystems (system: let
      pkgs = nixpkgsFor.${system};
      tests =
        (import ./tests {
          inherit pkgs;
          logger = self.lib;
        }).runAllTests;
    in {
      test = {
        type = "app";
        program = "${tests}/bin/run-all-tests";
      };
      default = self.apps.${system}.test;
    });
  };
}
