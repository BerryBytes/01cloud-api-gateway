# 🧩 KrakenD Integration with CORS & Circuit Breaker

## Overview

This guide provides step-by-step instructions to integrate **CORS** and **Circuit Breaker** plugins into your KrakenD API Gateway. These features enhance **security**, **reliability**, and **control** over client behavior and backend stability.

---

## 🔐 Key Features

### ✅ CORS (Cross-Origin Resource Sharing)
The `krakend-cors` plugin enables you to:
- Control which frontends can call your APIs
- Restrict allowed methods, headers, and origins
- Prevent unauthorized cross-origin calls

### 💣 Circuit Breaker
The `gobreaker` plugin helps:
- Automatically halt calls to unstable services
- Prevent cascading failures by tripping the circuit
- Restore connection after recovery period
- Monitor backend health and performance

---

## 📦 Prerequisites

- KrakenD Community or Enterprise Edition installed
- Basic understanding of API request lifecycle
- Access to modify KrakenD configuration files

---

## 🚀 Configuration Example

Add the following snippets inside your `krakend.json` or equivalent configuration file or template.

### 🔧 CORS Configuration (Global Level)

```json
{
  "version": 3,
  "name": "KrakenD API Gateway",
  "port": 8080,
  "extra_config": {
    "github_com/devopsfaith/krakend-cors": {
      "allow_origins": [
        "http://localhost:3000",
        "https://console.staging.rajivgopalsingh.com.np"
      ],
      "allow_methods": [
        "GET",
        "HEAD", 
        "POST",
        "OPTIONS",
        "PUT",
        "DELETE"
      ],
      "allow_headers": [
        "Accept-Language",
        "Content-Type",
        "X-Api-Version",
        "X-Custom-Auth",
        "Authorization",
        "X-Email",
        "X-Circuit-Break"
      ],
      "expose_headers": [
        "Content-Length",
        "Content-Type"
      ],
      "max_age": "12h",
      "allow_credentials": false
    }
  }
}
```

### ⚡ Circuit Breaker Configuration (Backend Level)

```json
{
  "endpoints": [
    {
      "endpoint": "/api/v1/users",
      "method": "GET",
      "backend": [
        {
          "url_pattern": "/users",
          "host": ["https://api.example.com"],
          "extra_config": {
            "github.com/devopsfaith/krakend-circuitbreaker/gobreaker": {
              "interval": 60,
              "timeout": 10,
              "max_errors": 5,
              "log_status_change": true
            }
          }
        }
      ]
    }
  ]
}
```



Here's a complete `krakend.json` configuration combining both CORS and Circuit Breaker:

```json
{
  "version": 3,
  "name": "KrakenD API Gateway with CORS & Circuit Breaker",
  "port": 8080,
  "cache_ttl": "300s",
  "timeout": "3000ms",
  "extra_config": {
    "github_com/devopsfaith/krakend-cors": {
      "allow_origins": [
        "http://localhost:3000",
        "https://console.staging.rajivgopalsingh.com.np"
      ],
      "allow_methods": [
        "GET",
        "HEAD",
        "POST",
        "OPTIONS",
        "PUT",
        "DELETE"
      ],
      "allow_headers": [
        "Accept-Language",
        "Content-Type",
        "X-Api-Version",
        "X-Custom-Auth",
        "Authorization",
        "X-Email",
        "X-Circuit-Break"
      ],
      "expose_headers": [
        "Content-Length",
        "Content-Type"
      ],
      "max_age": "12h",
      "allow_credentials": false
    }
  },
  "endpoints": [
    {
      "endpoint": "/api/v1/users",
      "method": "GET",
      "output_encoding": "json",
      "backend": [
        {
          "url_pattern": "/users",
          "encoding": "json",
          "sd": "static",
          "method": "GET",
          "host": ["https://api.example.com"],
          "disable_host_sanitize": false,
          "extra_config": {
            "github.com/devopsfaith/krakend-circuitbreaker/gobreaker": {
              "interval": 60,
              "timeout": 10,
              "max_errors": 5,
              "log_status_change": true
            }
          }
        }
      ]
    },
    {
      "endpoint": "/api/v1/orders",
      "method": "POST",
      "output_encoding": "json",
      "backend": [
        {
          "url_pattern": "/orders",
          "encoding": "json",
          "sd": "static",
          "method": "POST",
          "host": ["https://orders.example.com"],
          "disable_host_sanitize": false,
          "extra_config": {
            "github.com/devopsfaith/krakend-circuitbreaker/gobreaker": {
              "interval": 30,
              "timeout": 5,
              "max_errors": 3,
              "log_status_change": true
            }
          }
        }
      ]
    }
  ]
}
```

---

## ⚙️ Configuration Parameters

### 🌐 CORS Parameters

| Parameter | Type | Description | Example |
|-----------|------|-------------|---------|
| `allow_origins` | Array | Allowed origins for cross-origin requests | `["http://localhost:3000"]` |
| `allow_methods` | Array | HTTP methods allowed | `["GET", "POST", "PUT"]` |
| `allow_headers` | Array | Headers that can be used during the request | `["Authorization", "Content-Type"]` |
| `expose_headers` | Array | Headers exposed to the browser | `["Content-Length"]` |
| `max_age` | String | How long preflight results can be cached | `"12h"` |
| `allow_credentials` | Boolean | Whether credentials are allowed | `false` |

### ⚡ Circuit Breaker Parameters

| Parameter | Type | Description | Default | Example |
|-----------|------|-------------|---------|---------|
| `interval` | Integer | Interval (seconds) to clear internal stats | 60 | `60` |
| `timeout` | Integer | Timeout (seconds) after which circuit opens | 10 | `10` |
| `max_errors` | Integer | Max consecutive errors before opening circuit | 5 | `5` |
| `log_status_change` | Boolean | Log when circuit changes state | false | `true` |

---

## 🎯 Circuit Breaker States

### 🟢 Closed State
- Normal operation
- Requests flow through normally
- Errors are counted

### 🟡 Open State
- Circuit is "open" (broken)
- All requests fail immediately
- No requests sent to backend

### 🔵 Half-Open State
- Testing if backend recovered
- Limited requests allowed through
- Circuit closes if requests succeed

## 🛠️ Best Practices

### CORS Security
- Only allow necessary origins
- Use HTTPS in production
- Avoid wildcard `*` for `allow_origins` when `allow_credentials: true`
- Regularly review and update allowed origins

### Circuit Breaker Tuning
- Start with conservative settings
- Monitor error rates and adjust `max_errors`
- Set appropriate `timeout` based on backend SLA
- Use different settings for different backend criticality

### Production Considerations
- Use environment variables for configuration
- Implement proper logging and monitoring
- Set up health checks for backends
- Consider rate limiting alongside circuit breaker

---

## 🚨 Troubleshooting

### Common CORS Issues
1. **Preflight requests failing**: Check `allow_methods` and `allow_headers`
2. **Credentials not working**: Ensure `allow_credentials: true` and specific origin
3. **Headers missing**: Add required headers to `expose_headers`

### Common Circuit Breaker Issues
1. **Circuit opens too quickly**: Increase `max_errors` or `timeout`
2. **Circuit doesn't open**: Check error counting logic
3. **No logging**: Enable `log_status_change: true`
---

## 🎉 Conclusion

With CORS and Circuit Breaker properly configured, your KrakenD API Gateway now provides:
- **Enhanced security** through controlled cross-origin access
- **Improved reliability** with automatic failure detection
- **Better user experience** through graceful degradation
- **Operational visibility** through comprehensive logging

Remember to monitor your configuration in production and adjust parameters based on your specific use case and traffic patterns.