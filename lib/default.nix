# Main entry point for the log.nix library
{...}: let
  # Import internal utilities
  internal = import ./internal {};

  # ===== Configuration handling =====

  # Default configuration
  defaultConfig = {
    level = "debug"; # Default log level: debug, info, warn, error
    prefix = ""; # Default prefix (empty)
    format = "text"; # Default format: text or json
    color = true; # Use colors in text format
    template = null; # Default template (uses built-in templates)
  };

  # Log level priority (lower number = higher priority)
  levelPriority = {
    debug = 0;
    info = 1;
    warn = 2;
    error = 3;
  };

  # ===== Core logging functions =====

  # Check if a log should be displayed based on level
  shouldLog = config: level:
    levelPriority.${level} >= levelPriority.${config.level};

  # Create a logger function for a specific level
  makeLogger = config: level: message: value:
    if !shouldLog config level
    then value # Skip formatting entirely if we're not going to log
    else let
      formattedMessage = internal.formatMessage {
        inherit level message value;
        prefix = config.prefix;
        format = config.format;
        useColors = config.color;
        template = config.template;
      };
    in
      builtins.trace formattedMessage value;

  # ===== Logger factory functions =====

  # Create a logger with customized configuration
  makeLoggerWithConfig = config: let
    # Merge with default config
    mergedConfig = defaultConfig // config;

    # Create base logger object with standard log methods
    baseLogger = {
      debug = makeLogger mergedConfig "debug";
      info = makeLogger mergedConfig "info";
      warn = makeLogger mergedConfig "warn";
      error = makeLogger mergedConfig "error";
    };

    # Methods for creating derived loggers
    derivedLoggerFactory = {
      # Create a new logger with altered configuration
      withConfig = newConfig: makeLoggerWithConfig (mergedConfig // newConfig);

      # Shorthand for creating a logger with a new prefix
      withPrefix = prefix: makeLoggerWithConfig (mergedConfig // {inherit prefix;});
    };
  in
    # Combine the base logger with factory methods
    baseLogger // derivedLoggerFactory;

  # Create the default logger instance
  defaultLogger = makeLoggerWithConfig {};
in
  # Export the default logger with additional factory methods
  defaultLogger
  // {
    # Global factory methods (same as the instance methods, but at the top level)
    withConfig = makeLoggerWithConfig;
    withPrefix = prefix: makeLoggerWithConfig {inherit prefix;};
  }
