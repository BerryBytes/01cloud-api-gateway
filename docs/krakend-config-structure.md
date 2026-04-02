# Flexible Configuration Structure and Templating Logic

The flexible configuration structure and templating logic used in Krakend. Here's a detailed explanation of its contents:

## Configuration Structure

### Main Template (`krakend.tmpl`)
The krakend.tmpl file acts as the entry point for the configuration. It uses Go templating syntax to dynamically include partials for various configuration aspects such as CORS, monitoring, logging, and endpoint definitions.

Example:

```
{
  "$schema": "https://www.krakend.io/schema/v3.json",
  "version": 3,
  "name": "test-api-gateway",
  "timeout": "60s",
  "extra_config": {
    {{ include "cors_config_global.tmpl" }},
    {{ include "extra_config_monitoring.tmpl" }},
    {{ include "extra_config_logging.tmpl" }}
  },
  "endpoints": [{{ range $idx, $endpoint := .endpoints.endpoints }}{{if $idx}},{{end}}
    {
        "endpoint": "{{ $endpoint.endpoint }}",
        "method": "{{ $endpoint.method }}",
        "input_headers": {{ marshal $endpoint.input_headers }},
        "output_encoding": "{{ $endpoint.output_encoding }}",
        "extra_config": {
          {{ include "auth0_validator.tmpl" }}
        },
        "backend": [
          {
            "is_collection": {{ if eq $endpoint.is_collection "true" }}true{{ else }}false{{ end }},
            "encoding": "json",
            "host": [
              "{{ $endpoint.backend_host }}"
            ],
            "url_pattern": "{{ $endpoint.backend_url_pattern }}",
            "extra_config": {
              {{ include "rate_limit_backend.tmpl" }}
            }
          }
        ]
    }
    {{ end }},
    {{ template "endpoints.tmpl" . }}
  ]
}
```


This structure allows modularity and reusability, making it easier to manage complex configurations.

### Partials

Partials are smaller configuration files that define specific aspects of the Krakend setup. These are included dynamically in the main template using the {{ include "partial_name.tmpl" }} syntax.

List of Partials:

- **`cors_config_global.tmpl`**: Defines global CORS settings, including allowed origins, methods, headers, and other security configurations.

Example:
```
"security/cors": {
  "allow_origins": ["*"],
  "allow_methods": ["GET", "POST", "PUT", "DELETE"],
  "allow_headers": ["Authorization", "X-Custom-Auth"],
  "max_age": "12h",
  "debug": true
}
```

- **`extra_config_monitoring.tmpl`**:  Configures telemetry and metrics for Krakend, including Prometheus exporters.

Example:
```
"telemetry/metrics": {
  "collection_time": "60s",
  "listen_address": ":8090"
}
```

- **`extra_config_logging.tmpl`**: Configures logging settings, including log levels, formats, and output destinations.

Example:
```
"telemetry/logging": {
  "level": "DEBUG",
  "stdout": true,
  "format": "json"
}
```

- **`auth0_validator.tmpl`**:  Handles authentication and authorization logic using Auth0.

Example:
```
"auth/validator": {
  "alg": "RS256",
  "jwk_url": "https://example.com/.well-known/jwks.json"
}
```

- **`circuit_breaker.tmpl`**: Configures circuit breaker settings for backend services to handle failures gracefully.

Example:
```
"qos/circuit-breaker": {
  "interval": 60,
  "timeout": 10,
  "max_errors": 1
}
```
backend_host.tmpl: Specifies the backend host URL for Krakend to route requests.

Example:
```
"http://cloud-api.01cloud-staging.svc.cluster.local:8081"
```

### Endpoint Templates

Each endpoint is defined in a separate template file under config/templates/. These templates use partials to dynamically include configurations for headers, authentication, circuit breakers, and backend hosts.

Example: (`endpoint-login.tmpl`)
```
{
  "endpoint": "/login",
  "method": "POST",
  {{ include "auth0_input_headers.tmpl" }},
   "extra_config":{
  {{ include "auth0_validator.tmpl" }}
   },
  "backend": [
    {
      "host": [
        {{ include "backend_host.tmpl" }}
      ],
       "method": "POST",
      "url_pattern": "/user/login",
      "extra_config": {
          {{ include "circuit_breaker.tmpl" }}
      }
    }
  ]
}
```
This structure ensures that endpoint-specific configurations are modular and reusable.

---

## Templating Logic

### Dynamic Inclusion
The templating logic uses `{{ include "circuit_breaker.tmpl" }}` syntax to dynamically include partials. This ensures flexibility and scalability by allowing configuration changes without modifying the main template.

### Configuration Generation
To generate the final configuration file (`krakend.json`):
1. Use a templating tool or script to process the `.tmpl` files.
2. Ensure all partials and templates are correctly referenced and included.

---
### Benefits of Flexible Configuration Structure

- **`Modularity`**: Each configuration aspect is defined in a separate file, making it easier to update and maintain.

- **`Reusability`**: Common configurations (e.g., CORS, logging) can be reused across multiple endpoints.

- **`Scalability`**: The templating logic allows dynamic inclusion of configurations, making it easier to scale the setup as new endpoints or features are added.

- **`Ease of Management`**: Changes to partials automatically propagate to all templates, reducing the risk of inconsistencies.
---
## Summary
This document outlines the flexible configuration structure and templating logic for Krakend. By following these guidelines, you can simplify the management of complex setups and ensure scalability.



