{lognix}: let
  log = lognix.lib;
in {
  # Basic debug log
  debugExample = log.debug "Debug message" {
    detail = "This is a detailed debug message";
    value = 42;
  };

  # Basic info log
  infoExample = log.info "Processing configuration" {
    name = "my-service";
    port = 8080;
  };

  # Basic warning log
  warnExample = log.warn "Resource usage high" {
    cpu = "78%";
    memory = "3.5GB";
  };

  # Basic error log
  errorExample = log.error "Failed to connect" {
    service = "database";
    error = "Connection refused";
  };

  # Logging with string values
  stringExample = log.info "Simple string value" "Hello, world!";

  # Logging with list values
  listExample = log.info "List of items" ["item1" "item2" "item3"];

  # Logging with integer value
  numberExample = log.info "Server responded with" 200;
}
