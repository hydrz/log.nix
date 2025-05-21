{ lognix }: let
  log = lognix.lib;
in {
  # Custom log level configuration
  levelExample = let
    # Only show warnings and errors
    warnLogger = log.withConfig {
      level = "warn";
    };
  in {
    # This won't be shown because debug < warn
    debug = warnLogger.debug "Debug message" {
      detail = "This message won't appear";
    };
    
    # This won't be shown because info < warn
    info = warnLogger.info "Info message" {
      detail = "This message won't appear";
    };
    
    # This will be shown
    warn = warnLogger.warn "Warning message" {
      detail = "This warning will be visible";
    };
    
    # This will be shown
    error = warnLogger.error "Error message" {
      detail = "This error will be visible";
    };
  };
  
  # Custom template example
  templateExample = let
    templateLogger = log.withConfig {
      template = "#{level} [#{prefix}] :: #{message} >> #{value}";
      prefix = "CustomTemplate";
    };
  in 
    templateLogger.info "Custom template example" {
      value1 = 100;
      value2 = "string value";
    };
  
  # Chaining configuration changes
  chainedConfigExample = let
    baseLogger = log.withConfig { level = "info"; };
    moduleLogger = baseLogger.withPrefix "Module1";
    submoduleLogger = moduleLogger.withConfig { format = "json"; };
  in {
    base = baseLogger.info "Base logger" { type = "info-only" };
    module = moduleLogger.info "Module logger" { type = "with-prefix" };
    submodule = submoduleLogger.info "Submodule logger" { type = "json-with-prefix" };
  };
}