# 01cloud API Gateway

> Flexible, environment-driven API gateway configuration for [KrakenD](https://www.krakend.io/), with  Kubernetes/Helm deployment assets and observability integrations.

[![Build](https://img.shields.io/github/actions/workflow/status/BerryBytes/01cloud-api-gateway/lint.yaml?branch=main&label=lint)](https://github.com/BerryBytes/01cloud-api-gateway/actions/workflows/lint.yaml)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue)](LICENSE)
[![Version](https://img.shields.io/badge/version-1.0.0-blue)](CHANGELOG.md)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen)](CONTRIBUTING.md)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Repository Structure](#repository-structure)
- [Prerequisites](#prerequisites)
- [Getting Started](#getting-started)
- [Usage](#usage)
  - [Validate KrakenD Config](#1-validate-krakend-config-with-docker)
  - [Run with Docker Compose](#2-run-with-docker-compose)
  - [Build Immutable Gateway Image](#3-build-immutable-gateway-image)
- [Configuration Guide](#configuration-guide)
  - [KrakenD Flexible Config](#krakend-flexible-config)
  - [Environment Variables](#environment-variables)
  - [Auth0 with KrakenD](#auth0-with-krakend)
  - [Security Notes](#security-notes)
  - [Tyk Gateway](#tyk-gateway)
- [Observability](#observability)
- [Contributing](#contributing)
- [Security](#security)
- [Changelog](#changelog)
- [License](#license)

---

## Overview

**01cloud API Gateway** provides a production-ready, template-driven configuration layer on top of KrakenD. It separates environment concerns (`dev` / `prod`) using KrakenD's Flexible Config system, enabling teams to maintain a single base template while composing environment-specific settings and partials at build or run time.

Kubernetes users get Helm charts for both the gateway itself and a full observability stack (Grafana, Loki, Prometheus). The repository also includes a Tyk deployment path for the 01cloud API WebSocket gateway.

---

## Features

- **Flexible KrakenD configuration** via templates, partials, and environment-specific settings
- **Separate `dev` and `prod` overlays** — share a common template, diverge only where needed
- **Docker & Docker Compose** workflows for rapid local validation and development
- **Helm charts** for gateway and observability stack (Grafana, Loki, Prometheus)
- **CI/CD pipelines** for linting and deployment checks (GitHub Actions)
- **Tyk gateway manifests** for the 01cloud API WebSocket gateway deployment

---

## Repository Structure

```
01cloud-api-gateway/
├── krakend.tmpl                    # Base KrakenD template (Flexible Config entry point)
├── config/
│   ├── common/
│   │   └── templates/              # Shared endpoint templates
│   ├── dev/
│   │   ├── partials/               # Dev-specific partial overrides
│   │   └── settings/               # Dev environment settings
│   └── prod/
│       ├── partials/               # Prod-specific partial overrides
│       └── settings/               # Prod environment settings
├── charts/
│   ├── api-gateway/                # Helm chart for the KrakenD gateway
│   └── observability/              # Helm chart for Grafana, Loki, Prometheus
├── tyk-gateway/                    # Tyk manifests for the 01cloud API WebSocket gateway
├── .github/
│   └── workflows/                  # CI/CD pipelines (lint, deploy checks)
├── docker-compose.yml
├── Dockerfile
├── CONTRIBUTING.md
├── SECURITY.md
├── CHANGELOG.md
└── LICENSE
```

---

## Prerequisites

| Tool | Version | Required |
|---|---|---|
| Docker | 24+ | ✅ Yes |
| Docker Compose | v2+ | ✅ Yes |
| kubectl | any recent | ⬜  (Kubernetes) |
| Helm | 3+ | ⬜  (Kubernetes) |

---

## Getting Started

Clone the repository:

```bash
git clone https://github.com/BerryBytes/01cloud-api-gateway.git
cd 01cloud-api-gateway
```

---

## Usage

### 1) Validate KrakenD Config with Docker

Run a syntax/semantic check against your config template without starting the gateway:

```bash
docker run \
  --rm -it \
  --user "$(id -u):$(id -g)" \
  -p "8081:8080" \
  -v "$PWD:/etc/krakend" \
  -e FC_ENABLE=1 \
  -e FC_SETTINGS=config/dev/settings/prod \
  -e FC_PARTIALS=config/dev/partials \
  -e FC_TEMPLATES=config/common/templates \
  -e FC_OUT=/etc/krakend/tmp/out.json \
  -e SERVICE_NAME="KrakenD API Gateway" \
  krakend:2.10.0 check -tdc krakend.tmpl
```

The rendered output is written to `tmp/out.json` for inspection.

### 2) Run with Docker Compose

Bring up the full local stack (gateway + any compose-defined dependencies):

```bash
docker compose up
```

### 3) Build Immutable Gateway Image

For production deployments, bake the rendered config into the image so no environment variables are required at runtime:

```bash
# Build for prod
docker build --build-arg ENV=prod -t mykrakend .

# Run the baked image
docker run -p 8080:8080 mykrakend run -dc krakend.json
```

> **Tip:** Tagging with a Git SHA (`-t mykrakend:$(git rev-parse --short HEAD)`) makes rollbacks straightforward.

---

## Configuration Guide

### KrakenD Flexible Config

This project uses KrakenD's [Flexible Configuration](https://www.krakend.io/docs/configuration/flexible-config/) system. The base template (`krakend.tmpl`) references partials and settings files that are resolved at startup.

### Environment Variables

Set these when running `krakend check` or `krakend run` locally:

| Variable | Description | Example |
|---|---|---|
| `FC_ENABLE` | Enable Flexible Config | `1` |
| `FC_SETTINGS` | Path to settings directory | `config/dev/settings/prod` |
| `FC_PARTIALS` | Path to partials directory | `config/dev/partials` |
| `FC_TEMPLATES` | Path to shared templates | `config/common/templates` |
| `FC_OUT` | Path to write rendered JSON output | `tmp/out.json` |
| `SERVICE_NAME` | Gateway service name label | `KrakenD API Gateway` |

Switch between environments by pointing `FC_SETTINGS` and `FC_PARTIALS` at the appropriate `config/dev/` or `config/prod/` directories.

### Auth0 with KrakenD

This repository already includes Auth0-ready validator partials for both environments:

- `config/dev/partials/auth0_validator.tmpl`
- `config/prod/partials/auth0_validator.tmpl`
- `config/dev/partials/auth0_audience.tmpl`
- `config/prod/partials/auth0_audience.tmpl`
- `config/dev/partials/auth0_jwk_url.tmpl`
- `config/prod/partials/auth0_jwk_url.tmpl`

The main template loads the validator for each endpoint through `krakend.tmpl`, so configuring Auth0 is mostly a matter of updating those partials with your tenant values.

1. Set the Auth0 API audience in `auth0_audience.tmpl`.
2. Set the JWKS endpoint in `auth0_jwk_url.tmpl`.
3. Update `auth0_validator.tmpl` if you want to change the auth header name, propagated claims, or debugging behavior.
4. Validate the rendered config with `krakend check -tdc krakend.tmpl`.

Example validator partial:

```json
"auth/validator": {
  "auth_header_name": "Authorization",
  "alg": "RS256",
  "audience": [
    "https://YOUR_AUTH0_DOMAIN/api/v2/"
  ],
  "jwk_url": "https://YOUR_AUTH0_DOMAIN/.well-known/jwks.json",
  "propagate_claims": [
    ["email", "x-email"]
  ],
  "operation_debug": false
}
```

Notes:

- If you keep `auth_header_name` as `X-Custom-Auth`, clients must send the bearer token in that header instead of the standard `Authorization` header.
- For custom Auth0 claims, use the full namespaced claim key in `propagate_claims`, for example `https://your-app.example/email`.
- Keep `operation_debug` disabled in production unless you are actively troubleshooting token validation.
- Make sure the chosen header is listed in the endpoint `input_headers` partials if you expect KrakenD to forward it upstream.

### Security Notes

- **Do not commit real secrets or credentials** to this repository.
- All sensitive values in config files should use placeholder strings (e.g., `changeme`).
- Inject real secrets at deploy time using one of:
  - **Kubernetes Secrets** (recommended for Helm-based deployments)
  - **CI/CD secrets** (GitHub Actions secrets, etc.)
  - **Environment variables** injected at container runtime
- Regularly rotate any credentials used by the gateway (upstream service tokens, TLS certs, etc.).

### Tyk Gateway

The `tyk-gateway/` directory contains Kubernetes manifests for deploying [Tyk](https://tyk.io/) as the WebSocket gateway for the 01cloud API.

**Before deploying:**

- Set `TYK_GW_SECRET` externally — never hardcode tokens in manifests.
- Review the manifests for your cluster's namespace and ingress configuration.

---

## Observability

The `charts/observability/` Helm chart deploys a pre-wired observability stack:

| Component | Purpose |
|---|---|
| **Prometheus** | Metrics scraping and storage |
| **Grafana** | Dashboards and visualization |
| **Loki** | Log aggregation |

KrakenD exposes a `/metrics` endpoint compatible with Prometheus scraping. Pre-built Grafana dashboards for KrakenD are included in the chart.

To install the observability stack:

```bash
helm upgrade --install observability charts/observability/ \
  --namespace monitoring \
  --create-namespace \
  -f charts/observability/values.yaml
```

---

## Contributing

Contributions are welcome! Please read [CONTRIBUTING.md](CONTRIBUTING.md) before opening a pull request.

Key points:
- Fork the repo and create a feature branch from `main`.
- Ensure `krakend check` passes on your changes.
- Add or update documentation as appropriate.
- Open a PR with a clear description of what you've changed and why.

---

## Security

Please do **not** open public GitHub issues for security vulnerabilities. Instead, follow the responsible disclosure process described in [SECURITY.md](SECURITY.md).

---

## Changelog

All notable changes are documented in [CHANGELOG.md](CHANGELOG.md), following [Keep a Changelog](https://keepachangelog.com/en/1.0.0/) conventions.

---

## License

This project is licensed under the **Apache License 2.0**. See [LICENSE](LICENSE) for the full text.
Project attribution notices are documented in [NOTICE](NOTICE).
