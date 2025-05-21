# Internal helper functions for log.nix
{...}: let
  # ANSI escape sequence for terminal colors
  esc = builtins.fromJSON ''"\u001b"'';

  # Terminal color definitions
  colors = {
    reset = "${esc}[0m";
    debug = "${esc}[37m"; # Gray
    info = "${esc}[32m"; # Green
    warn = "${esc}[33m"; # Yellow
    error = "${esc}[31m"; # Red
  };

  # Default templates for different formats
  defaultTemplates = prefix: {
    text =
      if prefix == ""
      then "[#{level}] #{message} #{value}"
      else "[#{level}][#{prefix}] #{message} #{value}";
    json = null; # JSON format doesn't use a template
  };

  # Helper function to conditionally add attributes
  optionalAttrs = cond: attrs:
    if cond
    then attrs
    else {};

  # Apply color to text based on log level
  applyColor = level: text: useColors:
    if useColors
    then "${colors.${level}}${text}${colors.reset}"
    else text;

  # ===== Pretty printing functions =====

  # Convert any Nix value to a readable string representation
  toPretty = {
    maxDepth ? 3,
    currentDepth ? 0,
  }: value:
    if currentDepth > maxDepth
    then "..."
    else if builtins.isAttrs value
    then
      prettyAttrs {
        maxDepth = maxDepth;
        currentDepth = currentDepth + 1;
      }
      value
    else if builtins.isList value
    then
      prettyList {
        maxDepth = maxDepth;
        currentDepth = currentDepth + 1;
      }
      value
    else if builtins.isString value
    then builtins.toJSON value # Use JSON to properly escape strings
    else if builtins.isInt value || builtins.isFloat value || builtins.isBool value
    then builtins.toString value
    else if value == null
    then "null"
    else if builtins.isFunction value
    then "<function>"
    else if builtins.isPath value
    then "<path:${toString value}>"
    else builtins.toString value;

  # Pretty format for attribute sets
  prettyAttrs = {
    maxDepth,
    currentDepth,
  }: attrs:
    if builtins.length (builtins.attrNames attrs) == 0
    then "{}"
    else let
      pairs = builtins.concatStringsSep ", " (
        builtins.attrValues (
          builtins.mapAttrs (name: value: "${name}: ${toPretty {inherit maxDepth currentDepth;} value}") attrs
        )
      );
    in "{ ${pairs} }";

  # Pretty format for lists
  prettyList = {
    maxDepth,
    currentDepth,
  }: list:
    if list == []
    then "[]"
    else "[ ${builtins.concatStringsSep ", " (map (toPretty {inherit maxDepth currentDepth;}) list)} ]";

  # ===== Template processing functions =====

  # Replace placeholders in template with actual values
  replaceTemplate = {
    template,
    level,
    prefix,
    message,
    value,
  }: let
    replacements = {
      "#{level}" = level;
      "#{prefix}" = prefix;
      "#{message}" = message;
      "#{value}" = toPretty {} value;
    };
    placeholders = builtins.attrNames replacements;
    values = map (p: replacements.${p}) placeholders;
  in
    builtins.replaceStrings placeholders values template;

  # ===== Log formatting functions =====

  # Format log output as text
  formatLogText = {
    level,
    message,
    value,
    prefix,
    template,
    useColors ? false,
  }: let
    # Get appropriate template
    tmpl =
      if template != null
      then template
      else (defaultTemplates prefix).text;

    # Format the log using the template
    formatted = replaceTemplate {
      template = tmpl;
      inherit level prefix message value;
    };
  in
    applyColor level formatted useColors;

  # Format log output as JSON
  formatLogJson = {
    level,
    message,
    value,
    prefix,
    ...
  }: let
    # Create JSON object with log details
    logObj =
      {
        inherit level message;
        value = value;
      }
      // optionalAttrs (prefix != "") {inherit prefix;};
  in
    builtins.toJSON logObj;
in {
  # Main formatting function
  formatMessage = {
    level,
    message,
    value,
    prefix,
    format,
    template,
    useColors ? false,
  }:
    if format == "json"
    then formatLogJson {inherit level message value prefix;}
    else formatLogText {inherit level message value prefix template useColors;};
}
