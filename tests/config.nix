{
  pkgs ? import <nixpkgs> {},
  logger,
}: let
  baseLogger = logger;

  logLevelTest = {
    debugLogger = baseLogger.withConfig {level = "debug";};
    infoLogger = baseLogger.withConfig {level = "info";};
    warnLogger = baseLogger.withConfig {level = "warn";};
    errorLogger = baseLogger.withConfig {level = "error";};
  };

  # Test all log levels
  testLogLevels = {
    debugLevel = {
      debug = logLevelTest.debugLogger.debug "Should be visible" {visible = true;};
      info = logLevelTest.debugLogger.info "Should be visible" {visible = true;};
      warn = logLevelTest.debugLogger.warn "Should be visible" {visible = true;};
      error = logLevelTest.debugLogger.error "Should be visible" {visible = true;};
    };

    infoLevel = {
      debug = logLevelTest.infoLogger.debug "Should not be visible" {visible = false;};
      info = logLevelTest.infoLogger.info "Should be visible" {visible = true;};
      warn = logLevelTest.infoLogger.warn "Should be visible" {visible = true;};
      error = logLevelTest.infoLogger.error "Should be visible" {visible = true;};
    };

    warnLevel = {
      debug = logLevelTest.warnLogger.debug "Should not be visible" {visible = false;};
      info = logLevelTest.warnLogger.info "Should not be visible" {visible = false;};
      warn = logLevelTest.warnLogger.warn "Should be visible" {visible = true;};
      error = logLevelTest.warnLogger.error "Should be visible" {visible = true;};
    };

    errorLevel = {
      debug = logLevelTest.errorLogger.debug "Should not be visible" {visible = false;};
      info = logLevelTest.errorLogger.info "Should not be visible" {visible = false;};
      warn = logLevelTest.errorLogger.warn "Should not be visible" {visible = false;};
      error = logLevelTest.errorLogger.error "Should be visible" {visible = true;};
    };
  };

  # Test color configuration
  colorTest = {
    withColor = baseLogger.withConfig {colors = true;};
    withoutColor = baseLogger.withConfig {colors = false;};
  };

  # Test prefix configuration
  prefixTest = {
    # Test prefix functionality
    moduleA = baseLogger.withPrefix "ModuleA";
    # Test prefix functionality with custom config
    moduleB = baseLogger.withConfig {prefix = "ModuleB";};
  };

  # Test enable/disable functionality
  enableTest = {
    enabled = baseLogger.enable;
    disabled = baseLogger.disable;
  };
in {
  inherit testLogLevels;

  testColors = {
    withColor = colorTest.withColor.info "Test with color" {test = "color";};
    withoutColor = colorTest.withoutColor.info "Test without color" {test = "no-color";};
  };

  testPrefix = {
    moduleA = prefixTest.moduleA.info "Log from module A" {module = "A";};
    moduleB = prefixTest.moduleB.info "Log from module B" {module = "B";};
  };

  testEnable = {
    enabled = enableTest.enabled.info "A log should be visible" {test = "enabled";};
    disabled = enableTest.disabled.info "A log should not be visible" {test = "disabled";};
  };
}
