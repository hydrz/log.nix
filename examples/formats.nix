{lognix}: let
  log = lognix.lib;

  # Text format (default)
  textLogger = log.withConfig {
    format = "text";
    prefix = "TextFormat";
  };

  # JSON format
  jsonLogger = log.withConfig {
    format = "json";
    prefix = "JsonFormat";
  };

  # Custom text template
  customTextLogger = log.withConfig {
    format = "text";
    prefix = "CustomText";
    template = "[#{level}] #{prefix} | #{message} | Data: #{value}";
  };

  # Example data to log
  sampleData = {
    user = {
      id = 1001;
      name = "John Doe";
      roles = ["admin" "developer"];
    };
    system = {
      uptime = "10d 4h 30m";
      load = [0.8 1.2 0.9];
    };
  };
in {
  # Default text format
  textExample = textLogger.info "System status report" sampleData;

  # JSON format
  jsonExample = jsonLogger.info "System status report" sampleData;

  # Custom text format
  customTextExample = customTextLogger.info "System status report" sampleData;

  # Complex nested structures
  complexStructure = {
    text = textLogger.debug "Complex structure" {
      nestedLists = [[1 2 3] [4 5 6]];
      nestedAttrs = {
        level1 = {
          level2 = {
            level3 = "deeply nested";
          };
        };
      };
      mixedTypes = [1 "string" true {key = "value";}];
    };

    json = jsonLogger.debug "Complex structure" {
      nestedLists = [[1 2 3] [4 5 6]];
      nestedAttrs = {
        level1 = {
          level2 = {
            level3 = "deeply nested";
          };
        };
      };
      mixedTypes = [1 "string" true {key = "value";}];
    };
  };
}
