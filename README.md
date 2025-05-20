# Log.nix

A simple, powerful, zero-dependency logging library for Nix, specially designed for Flake development and debugging.

## Features

- Easy to use: Intuitive API suitable for various Nix expressions
- Zero dependencies: Uses only built-in Nix functions
- Multiple log levels: debug, info, warn, error
- Colored output support: Makes logs clearer and more intuitive

- Multiple output formats: text/json formats
- Custom formatting templates: Customize output with variables like `#{timestamp}`, `#{level}`, etc.
- Log prefix support: Easily distinguish logs from different modules
- Fully configurable: Customize every aspect to meet different needs
- Lightweight implementation: Does not affect build performance

## Installation

### As a Flake Input

Add to your `flake.nix` file:

```nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    lognix.url = "github:hydrz/log.nix";
  };
  
  outputs = { self, nixpkgs, lognix, ... }: {
    # Access log library using lognix.lib
  };
}
```

## Basic Usage

```nix
{ lognix, ... }:

let
  logger = lognix.lib;
in
{
  result = logger.info "Processing configuration" {
    name = "my-service";
    port = 8080;
  };
}
```

## Advanced Usage

### Different Log Levels

```nix
logger.debug "Detailed debug information" value;  # Detailed logs for development
logger.info "Normal information" value;           # General information
logger.warn "Warning information" value;          # Warning messages
logger.error "Error information" value;           # Error messages
```

### Custom Configuration

```nix
# Create a logger instance with custom configuration
let
  customLogger = logger.withConfig {
    level = "warn";        # Show only warn and above levels
    colors = true;         # Use colored output
    prefix = "MyModule";   # Add prefix
    format = "text";       # Use text format (alternative is "json")
    template = null;       # Use default template (can be customized)
    enabled = true;        # Enable logging
  };
in
{
  # Use custom logger
  result = customLogger.warn "Configuration has issues" { error = "Invalid value" };
}
```

### Using Specific Prefixes

```nix
# Create logger instances with different prefixes for different modules
let
  networkLogger = logger.withPrefix "Network";
  securityLogger = logger.withPrefix "Security";
in
{
  test = [
    (networkLogger.info "Network configuration complete" { interface = "eth0"; })
    (securityLogger.warn "Security issue detected" { issue = "weak-password"; })
  ];
}
```

### JSON Format Output

```nix
let
  jsonLogger = logger.withConfig { format = "json"; };
in
jsonLogger.info "System status" { cpu = 0.5; memory = 0.7; };
# Output: {"level":"info","message":"System status","value":{"cpu":0.5,"memory":0.7}}
```

### Custom Templates

```nix
let
  templateLogger = logger.withConfig {
    template = "<#{prefix}> #{level}: #{message} => #{value}";
  };
in
templateLogger.info "Processing request" { url = "/api/data"; };
```

## Configuration Options

| Option   | Type   | Default | Description                          |
| -------- | ------ | ------- | ------------------------------------ |
| level    | string | "debug" | Log level (debug, info, warn, error) |
| colors   | bool   | true    | Whether to enable colored output     |
| prefix   | string | ""      | Log prefix                           |
| format   | string | "text"  | Output format (text or json)         |
| template | string | null    | Custom template                      |
| enabled  | bool   | true    | Whether logging is enabled           |