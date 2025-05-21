{
  description = "A simple, powerful, zero-dependency logging library for Nix";
  inputs = {};
  outputs = {self, ...}: {
    lib = import ./lib {};
  };
}
