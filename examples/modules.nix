{lognix}: let
  log = lognix.lib;

  # Create module-specific loggers
  networkLogger = log.withPrefix "Network";
  securityLogger = log.withPrefix "Security";
  dbLogger = log.withPrefix "Database";
  apiLogger = log.withPrefix "API";

  # Simulated application with multiple modules
  simulateApp = {
    # Network module actions
    network = {
      connect = networkLogger.info "Establishing connection" {
        host = "example.com";
        port = 443;
      };

      timeout = networkLogger.warn "Connection timeout" {
        host = "api.example.com";
        timeout = "30s";
      };
    };

    # Security module actions
    security = {
      authAttempt = securityLogger.info "Authentication attempt" {
        user = "user123";
        method = "password";
      };

      accessDenied = securityLogger.error "Access denied" {
        user = "guest";
        resource = "/admin/settings";
        reason = "insufficient privileges";
      };
    };

    # Database module actions
    database = {
      query = dbLogger.debug "Executing query" {
        table = "users";
        filter = "age > 18";
      };

      slowQuery = dbLogger.warn "Slow query detected" {
        query = "SELECT * FROM large_table WHERE complex_condition";
        duration = "5.2s";
        threshold = "1.0s";
      };
    };

    # API module actions
    api = {
      request = apiLogger.info "Received API request" {
        method = "POST";
        endpoint = "/api/v1/users";
        client = "10.0.0.123";
      };

      rateLimit = apiLogger.warn "Rate limit exceeded" {
        client = "10.0.0.50";
        limit = "100 req/min";
        current = "105 req/min";
      };
    };
  };
in
  simulateApp
