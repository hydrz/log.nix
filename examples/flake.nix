{
  description = "Examples of using the logging library";
  inputs.lognix.url = github:hydrz/log.nix;

  outputs = {
    self,
    lognix,
    ...
  }: {
    # Basic examples to demonstrate logger usage
    examples = {
      # Basic usage examples
      basic = import ./basic.nix {inherit lognix;};

      # Advanced configuration examples
      advanced = import ./advanced.nix {inherit lognix;};

      # Module-specific logging examples
      modules = import ./modules.nix {inherit lognix;};

      # Format examples (text vs JSON)
      formats = import ./formats.nix {inherit lognix;};
    };
  };
}
