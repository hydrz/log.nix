{
  pkgs ? import <nixpkgs> {},
  logger,
}: let
  baseLogger = logger;

  # Test text format and JSON format
  formatTest = {
    # Default text format
    textLogger = baseLogger.withConfig {format = "text";};
    # JSON format
    jsonLogger = baseLogger.withConfig {format = "json";};
  };

  # Test custom templates
  templateTest = {
    # Simple template
    simple = baseLogger.withConfig {
      template = "#{level} >> #{message} >> #{value}";
    };

    # Template with prefix
    withPrefix = baseLogger.withConfig {
      prefix = "System";
      template = "[#{prefix}] #{level}: #{message} #{value}";
    };

    # Fully custom template
    full = baseLogger.withConfig {
      prefix = "App";
      template = "L:#{level} P:#{prefix} M:#{message} V:#{value}";
    };
  };

  # Test formatting of complex data structures
  complexData = {
    nested = {
      config = {
        server = {
          host = "localhost";
          port = 8080;
        };
        database = {
          url = "postgres://user:pass@localhost/db";
          pool = 10;
        };
      };
      enabled = true;
      tags = ["production" "web" "v2"];
    };

    lists = [
      {
        id = 1;
        name = "Item 1";
      }
      {
        id = 2;
        name = "Item 2";
      }
      {
        id = 3;
        name = "Item 3";
      }
    ];

    mixed = {
      str = "string";
      num = 42;
      bool = true;
      null = null;
      list = [1 2 3];
      nested = {
        a = 1;
        b = 2;
      };
    };
  };
in {
  # Test different output formats
  testFormats = {
    text = formatTest.textLogger.info "Text format test" {
      user = "admin";
      id = 1234;
    };
    json = formatTest.jsonLogger.info "JSON format test" {
      user = "admin";
      id = 1234;
    };
  };

  # Test custom templates
  testTemplates = {
    simple = templateTest.simple.info "Simple template test" {test = "simple";};
    withPrefix = templateTest.withPrefix.warn "Template with prefix test" {test = "prefix";};
    full = templateTest.full.error "Full template test" {test = "full";};
  };

  # Test complex data structures
  testComplexData = {
    nested = baseLogger.info "Nested object test" complexData.nested;
    lists = baseLogger.info "List object test" complexData.lists;
    mixed = baseLogger.info "Mixed type test" complexData.mixed;
    json = formatTest.jsonLogger.info "JSON complex data test" complexData.mixed;
  };
}
