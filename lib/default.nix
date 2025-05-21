# Main entry point for the log.nix library
{...}: let
  internal = import ./internal {};

  # Default configuration
  defaultConfig = {
    level = "debug"; # Default log level: debug, info, warn, error
    prefix = ""; # Default prefix (empty)
    format = "text"; # Default format: text or json
    template = null; # Default template (uses built-in templates)
  };

  # Log level priority (lower number = higher priority)
  levelPriority = {
    debug = 0;
    info = 1;
    warn = 2;
    error = 3;
  };

  # Helper function to check if a log should be displayed based on level
  shouldLog = config: level:
    levelPriority.${level} >= levelPriority.${config.level};

  # Function to create a logger with a specific configuration
  makeLogger = config: level: message: value: let
    formattedMessage = internal.formatMessage {
      inherit level message value;
      prefix = config.prefix;
      format = config.format;
      template = config.template;
    };

    result =
      if shouldLog config level
      then builtins.trace formattedMessage value
      else value;
  in
    result;

  makeLoggerWithConfig = config: let
    mergedConfig = defaultConfig // config;
  in {
    debug = makeLogger mergedConfig "debug";
    info = makeLogger mergedConfig "info";
    warn = makeLogger mergedConfig "warn";
    error = makeLogger mergedConfig "error";

    withConfig = newConfig: makeLoggerWithConfig (mergedConfig // newConfig);
    withPrefix = prefix: makeLoggerWithConfig (mergedConfig // {inherit prefix;});
  };

  defaultLogger = makeLoggerWithConfig {};
in
  defaultLogger
  // {
    withConfig = makeLoggerWithConfig;
    withPrefix = prefix: makeLoggerWithConfig {inherit prefix;};
  }
