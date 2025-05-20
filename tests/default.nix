{
  pkgs ? import <nixpkgs> {},
  logger,
}: let
  basicTests = import ./basic.nix {inherit pkgs logger;};
  configTests = import ./config.nix {inherit pkgs logger;};
  formatTests = import ./format.nix {inherit pkgs logger;};
in {
  allTests = {
    basic = basicTests;
    config = configTests;
    format = formatTests;
  };

  runAllTests = pkgs.writeShellScriptBin "run-all-tests" ''
    echo "======================================"
    echo "       log.nix Test Runner"
    echo "======================================"
  '';
}
