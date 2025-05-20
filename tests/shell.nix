{
  pkgs ? import <nixpkgs> {},
  logger,
}: let
  tests = import ./default.nix {inherit pkgs logger;};
in
  pkgs.mkShell {
    buildInputs = [
      tests.runAllTests
    ];

    shellHook = ''
      echo "======================================"
      echo "       log.nix Development Shell"
      echo "======================================"
    '';
  }
