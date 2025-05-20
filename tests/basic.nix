{
  pkgs ? import <nixpkgs> {},
  logger,
}: let
  # Test all log levels
  testBasicLevels = {
    debug = logger.debug "Test debug log" {data = "debug data";};
    info = logger.info "Test info log" {data = "info data";};
    warn = logger.warn "Test warning log" {data = "warn data";};
    error = logger.error "Test error log" {data = "error data";};
  };

  # Test logs without values
  testNoValue = {
    debug = logger.debug "Debug message only, no data" null;
    info = logger.info "Info only, no data" null;
    warn = logger.warn "Warning only, no data" null;
    error = logger.error "Error only, no data" null;
  };

  # Test functional calling style
  makeData = label: {
    type = "Test data";
    label = label;
  };
  testFunctional = {
    debug = logger.debug (data: "Processing debug data: ${data.label}") (makeData "debug");
    info = logger.info (data: "Processing info data: ${data.label}") (makeData "info");
    warn = logger.warn (data: "Processing warning data: ${data.label}") (makeData "warn");
    error = logger.error (data: "Processing error data: ${data.label}") (makeData "error");
  };
in {
  inherit testBasicLevels testNoValue testFunctional;
}
