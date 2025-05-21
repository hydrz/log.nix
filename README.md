# Log.nix

A simple, powerful, zero-dependency logging library for Nix, specially designed for Flake development and debugging.

[![Flake compatibility](https://img.shields.io/badge/Nix%20Flakes-compatible-success.svg)](https://nixos.wiki/wiki/Flakes)

## Table of Contents

- [Log.nix](#lognix)
  - [Table of Contents](#table-of-contents)
  - [Features](#features)
  - [Installation](#installation)
    - [As a Flake Input](#as-a-flake-input)
    - [Direct Import in Nix Files](#direct-import-in-nix-files)
  - [Basic Usage](#basic-usage)
  - [Advanced Usage](#advanced-usage)
    - [Different Log Levels](#different-log-levels)
    - [Custom Configuration](#custom-configuration)
    - [Using Specific Prefixes](#using-specific-prefixes)
    - [JSON Format Output](#json-format-output)
    - [Custom Templates](#custom-templates)
    - [Chaining Configuration](#chaining-configuration)
  - [Configuration Options](#configuration-options)
  - [Examples](#examples)
  - [Integration Patterns](#integration-patterns)
    - [Logging in NixOS Modules](#logging-in-nixos-modules)
    - [Debugging Flake Builds](#debugging-flake-builds)
  - [Contributing](#contributing)
  - [License](#license)

## Features

- **Easy to use**: Intuitive API suitable for various Nix expressions
- **Zero dependencies**: Uses only built-in Nix functions
- **Multiple log levels**: debug, info, warn, error - all with configurable visibility
- **Colorized output**: Enhanced readability with color-coded log levels
- **Multiple output formats**: text/json formats for both human and machine consumption
- **Custom formatting templates**: Customize output with variables like `#{level}`, `#{prefix}`, `#{message}`, `#{value}`
- **Log prefix support**: Easily distinguish logs from different modules or components
- **Fully configurable**: Customize every aspect to meet different needs
- **Lightweight implementation**: Does not affect build performance

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
    # Access the log library through lognix.lib
    # Example: using it in a package definition
    packages.x86_64-linux.myPackage = 
      let log = lognix.lib;
      in # ...
  };
}
```

### Direct Import in Nix Files

For non-flake usage, you can directly import the library in your Nix files:

```nix
let
  lognixSrc = fetchGit {
    url = "https://github.com/hydrz/log.nix.git";
    rev = "main"; # Or specify a particular commit/tag
  };
  log = import "${lognixSrc}/lib" {};
in
# Use log functions here
```

## Basic Usage

The library provides a simple API with log level functions that take a message and a value:

```nix
{ lognix, ... }:

let
  log = lognix.lib;
in
{
  result = log.info "Processing configuration" {
    name = "my-service";
    port = 8080;
  };
}
```

Each log function:
- Takes a message (string) and a value (any Nix type)
- Outputs the formatted log message to the console
- Returns the original value unchanged, making it perfect for use in pipelines

You can log any Nix value type:

```nix
log.info "Simple string value" "Hello, world!";  # String
log.info "List of items" ["item1" "item2"];      # List
log.info "Status code" 200;                      # Number 
log.info "Boolean flag" true;                    # Boolean
```

## Advanced Usage

### Different Log Levels

Log.nix provides four log levels with increasing priority:

```nix
log.debug "Detailed debug information" value;  # Lowest level - detailed debugging info
log.info "Normal information" value;           # General operational information
log.warn "Warning information" value;          # Potential issues that aren't errors
log.error "Error information" value;           # Highest level - critical issues
```

When you set a specific log level in configuration, only messages with that level or higher priority will be displayed:
- `level = "debug"` - Shows all logs (default)
- `level = "info"` - Shows info, warn, error (hides debug)
- `level = "warn"` - Shows warn, error (hides debug, info)
- `level = "error"` - Shows only error logs

### Custom Configuration

You can create a custom logger with tailored settings:

```nix
# Create a logger instance with custom configuration
let
  logger = log.withConfig {
    level = "warn";        # Show only warn and above levels
    prefix = "MyModule";   # Add prefix to all logs
    format = "text";       # Use text format (alternative is "json")
    color = true;          # Use color in text output (default)
    template = null;       # Use default template (can be customized)
  };
in
{
  # Use custom logger
  result = logger.warn "Configuration has issues" { error = "Invalid value" };
}
```

All configuration settings are optional - only specify the ones you want to customize. Any unspecified options will use their default values.

### Using Specific Prefixes

Prefixes help distinguish logs from different modules. You can create multiple logger instances with different prefixes:

```nix
# Create logger instances with different prefixes for different modules
let
  networkLogger = log.withPrefix "Network";
  securityLogger = log.withPrefix "Security";
in
{
  test = [
    (networkLogger.info "Network configuration complete" { interface = "eth0"; })
    (securityLogger.warn "Security issue detected" { issue = "weak-password"; })
  ];
}
```

Output example:
```
[info][Network] Network configuration complete { interface: "eth0" }
[warn][Security] Security issue detected { issue: "weak-password" }
```

### JSON Format Output

When integrating with other tools or services, JSON output can be useful:

```nix
let
  jsonLogger = log.withConfig { format = "json"; };
in
jsonLogger.info "System status" { cpu = 0.5; memory = 0.7; };
```

Output:
```json
{"level":"info","message":"System status","value":{"cpu":0.5,"memory":0.7}}
```

### Custom Templates

You can define your own output format using a template string with placeholders:

```nix
let
  templateLogger = log.withConfig {
    template = "<#{prefix}> #{level}: #{message} => #{value}";
  };
in
templateLogger.info "Processing request" { url = "/api/data"; };
```

Output:
```
<> info: Processing request => { url: "/api/data" }
```

Available template variables:
- `#{level}` - Log level (debug, info, warn, error)
- `#{prefix}` - Configured prefix for the logger
- `#{message}` - The log message
- `#{value}` - The formatted value being logged

### Chaining Configuration

You can build on existing logger instances:

```nix
let
  # Start with a base logger
  baseLogger = log.withConfig { level = "info"; };
  
  # Add a prefix
  moduleLogger = baseLogger.withPrefix "Auth";
  
  # Change format 
  jsonModuleLogger = moduleLogger.withConfig { format = "json"; };
in
{
  # Each derived logger inherits from its parent
  normalLog = baseLogger.info "Base logger" "Initial settings";
  prefixedLog = moduleLogger.warn "Module logger" "With prefix";
  jsonLog = jsonModuleLogger.error "JSON logger" "Complete config";
}
```

## Configuration Options

| Option   | Type    | Default | Description                                    |
| -------- | ------- | ------- | ---------------------------------------------- |
| level    | string  | "debug" | Log level (debug, info, warn, error)           |
| prefix   | string  | ""      | Log prefix for module/component identification |
| format   | string  | "text"  | Output format (text or json)                   |
| color    | boolean | true    | Use ANSI colors for text output                |
| template | string  | null    | Custom template (null uses built-in templates) |

Each configuration option can be set using the `withConfig` function.

## Examples

The `examples/` directory contains complete usage examples:

- [Basic usage](examples/basic.nix) - Simple logging examples with different data types
- [Advanced configuration](examples/advanced.nix) - Custom log levels and templates
- [Output formats](examples/formats.nix) - Text and JSON formatting examples
- [Module organization](examples/modules.nix) - Using prefixes for module-specific logging

You can run these examples with:

```bash
nix eval --file examples/basic.nix --arg lognix 'import ./. {}'
```

## Integration Patterns

### Logging in NixOS Modules

```nix
{ config, lib, ... }:

let
  log = import ./log.nix {};
  logger = log.withPrefix "MyModule";
in {
  options = {
    # Module options...
  };
  
  config = lib.mkIf config.services.myService.enable {
    # Log during module evaluation
    services.myService.port = 
      logger.info "Configuring service port" 8080;
  };
}
```

### Debugging Flake Builds

```nix
{
  inputs.lognix.url = "github:hydrz/log.nix";
  
  outputs = { self, nixpkgs, lognix }: 
    let
      log = lognix.lib;
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
    in {
      packages.${system}.default = 
        log.debug "Building package" (
          pkgs.stdenv.mkDerivation {
            name = "my-package";
            # ...derivation attributes...
          }
        );
    };
}
```

## Contributing

Contributions are welcome! Feel free to open issues or submit pull requests on GitHub.

- Report bugs or request features via [GitHub Issues](https://github.com/hydrz/log.nix/issues)
- Submit improvements through [Pull Requests](https://github.com/hydrz/log.nix/pulls)

## License

This project is licensed under the [MIT License](LICENSE).