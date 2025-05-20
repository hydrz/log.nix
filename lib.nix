{config ? {}}: let
  defaultConfig = {
    # Default log level
    level = "debug";
    # Default log colors
    colors = true;
    # Default prefix
    prefix = "";
    # Default format: text or json
    format = "text";
    # Default template: #{level} #{prefix} #{message} #{value}
    template = null;
    # Whether logging is enabled (can be disabled globally)
    enabled = true;
    # Whether to show circular reference warnings in output
    showCircularWarning = false;
  };

  # Merge user config with default config
  cfg = defaultConfig // config;

  # Console colors - using ASCII escape characters (27 = ESC)
  esc = builtins.fromJSON ''"\u001b"'';
  colors = {
    reset = "${esc}[0m";
    debug = "${esc}[38;5;245m"; # Gray
    info = "${esc}[38;5;39m"; # Blue
    warn = "${esc}[38;5;214m"; # Yellow
    error = "${esc}[38;5;196m"; # Red
  };

  # Map log levels to numeric values for comparison
  levelValue = {
    debug = 0;
    info = 1;
    warn = 2;
    error = 3;
  };

  # Check if the current log should be output
  shouldLog = level: cfg.enabled && levelValue.${level} >= levelValue.${cfg.level};

  # Function to convert values to strings
  valueToString = value: let
    # Add recursive depth limit to avoid infinite recursion
    maxDepth = 3;

    # Internal recursive function with depth parameter
    toString' = depth: value:
      if depth > maxDepth
      then "..."
      else if builtins.isNull value
      then "null"
      else if builtins.isInt value || builtins.isFloat value
      then builtins.toString value
      else if builtins.isBool value
      then
        if value
        then "true"
        else "false"
      else if builtins.isString value
      then ''"${value}"''
      else if builtins.isList value
      then let
        items = builtins.map (item: toString' (depth + 1) item) value;
        itemsStr = builtins.concatStringsSep ", " items;
      in "[${itemsStr}]"
      else if builtins.isAttrs value
      then let
        # Filter out special attributes like __toString, __functor and functions
        isSpecialAttr = name: builtins.substring 0 2 name == "__" || builtins.isFunction value.${name};
        attrNames = builtins.filter (name: !isSpecialAttr name) (builtins.attrNames value);
        formatAttr = name: "${name}=${toString' (depth + 1) value.${name}}";
        attrs = builtins.map formatAttr attrNames;
        attrsStr = builtins.concatStringsSep ", " attrs;
      in "{${attrsStr}}"
      else if builtins.isFunction value
      then "<function>"
      else if builtins.isPath value
      then "${value}"
      else "<unknown>";
  in
    toString' 0 value;

  # Base log builder function
  makeLogger = level: message: value: let
    # Check if the level condition is met
    shouldRenderLog = shouldLog level;

    levelStr =
      if cfg.colors
      then "${colors.${level}}${level}${colors.reset}"
      else "[${level}]";
    prefixStr =
      if cfg.prefix != ""
      then "${cfg.prefix} "
      else "";

    # If value is not null, add its string representation
    valueStr =
      if value != null
      then " ${valueToString value}"
      else "";

    # If a custom template exists, use it
    textOutput =
      if cfg.template != null
      then
        builtins.replaceStrings
        ["#{level}" "#{prefix}" "#{message}" "#{value}"]
        [levelStr prefixStr message valueStr]
        cfg.template
      else "${levelStr} ${prefixStr}${message}${valueStr}";

    # JSON format output
    jsonOutput = builtins.toJSON {
      level = level;
      prefix =
        if cfg.prefix != ""
        then cfg.prefix
        else null;
      message = message;
      value = value;
    };
  in
    if !shouldRenderLog
    then ""
    else if cfg.format == "json"
    then jsonOutput
    else textOutput;

  # Create a log function with input/output capability
  _makeLogFunc = level: message: value:
    if shouldLog level
    then builtins.trace (makeLogger level message value) value
    else value;

  # Create a new logger instance with specified configuration
  makeLogger' = newConfig: import ./lib.nix {config = cfg // newConfig;};

  # Create a logger instance with a specific prefix
  withPrefix = prefix: makeLogger' {prefix = prefix;};

  # Simplified log function factory
  makeLoggerFunc = level: message:
    if builtins.isFunction message
    then value: _makeLogFunc level (message value) value
    else value: _makeLogFunc level message value;
in {
  # Export main logging functions
  # Two ways to call:
  # 1. logger.debug "message" value - logs the message and returns the value
  # 2. logger.debug "message" - returns a function that accepts a value and returns that value
  debug = makeLoggerFunc "debug";
  info = makeLoggerFunc "info";
  warn = makeLoggerFunc "warn";
  error = makeLoggerFunc "error";

  # Dynamically call log functions using string level
  log = level: message:
    if builtins.hasAttr level levelValue
    then makeLoggerFunc level message
    else
      value: let
        errorMsg = _makeLogFunc "error" "Invalid log level: ${level}" null;
      in
        value;

  # Configuration functions
  withConfig = makeLogger';
  withPrefix = withPrefix;

  # Export utility functions
  stringify = valueToString;

  # Helper functions to quickly disable/enable logging
  disable = makeLogger' {enabled = false;};
  enable = makeLogger' {enabled = true;};
}
