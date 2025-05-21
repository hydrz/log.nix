# Internal helper functions for log.nix
{...}: let
  # Default templates for different formats
  defaultTemplates = prefix: {
    text =
      if prefix == ""
      then "[#{level}] #{message} #{value}"
      else "[#{level}][#{prefix}] #{message} #{value}";

    json = null; # JSON format doesn't use a template
  };

  # Replace placeholders in template
  replaceTemplate = {
    template,
    level,
    prefix,
    message,
    value,
  }: let
    # Replace functions for each placeholder
    replacements = {
      "#{level}" = level;
      "#{prefix}" = prefix;
      "#{message}" = message;
      "#{value}" = generators.toPretty {} value;
    };

    # Apply all replacements to the template
    replace = template: placeholder: replacement:
      builtins.replaceStrings [placeholder] [replacement] template;

    result =
      builtins.foldl'
      (template: placeholder:
        replace template placeholder replacements.${placeholder})
      template
      (builtins.attrNames replacements);
  in
    result;

  # Format log output based on config and log details
  formatLogText = {
    level,
    message,
    value,
    prefix,
    template,
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
    formatted;

  # Create JSON format log
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

    # Convert to JSON string
    json = builtins.toJSON logObj;
  in
    json;

  generators = {
    toPretty = {}: value:
      if builtins.isAttrs value
      then prettyAttrs value
      else if builtins.isList value
      then prettyList value
      else if builtins.isString value
      then builtins.toString value
      else if builtins.isInt value || builtins.isFloat value || builtins.isBool value
      then builtins.toString value
      else if value == null
      then "null"
      else builtins.toString value;
  };

  prettyAttrs = attrs: let
    names = builtins.attrNames attrs;
    values = map (n: generators.toPretty {} attrs.${n}) names;
    pairs =
      map (i: "${builtins.elemAt names i}: ${builtins.elemAt values i}")
      (builtins.genList (x: x) (builtins.length names));
  in "{ ${builtins.concatStringsSep ", " pairs} }";

  prettyList = list: "[ ${builtins.concatStringsSep ", " (map (generators.toPretty {}) list)} ]";

  optionalAttrs = cond: attrs:
    if cond
    then attrs
    else {};
in {
  # Main formatting function
  formatMessage = {
    level,
    message,
    value,
    prefix,
    format,
    template,
  }:
    if format == "json"
    then formatLogJson {inherit level message value prefix;}
    else formatLogText {inherit level message value prefix template;};
}
