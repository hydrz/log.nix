{
  description = "Examples of using the logging library";
  inputs.lognix.url = "github:hydrz/log.nix";
  # inputs.lognix.url = "../.";

  outputs = {
    self,
    lognix,
    ...
  }: let
  in {
    basic = import ./basic.nix {inherit lognix;};
    advanced = import ./advanced.nix {inherit lognix;};
    modules = import ./modules.nix {inherit lognix;};
    formats = import ./formats.nix {inherit lognix;};
  };
}
