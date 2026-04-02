# Contributing Guide

Thanks for your interest in contributing to 01cloud API Gateway.

## How to Report Bugs

1. Search existing issues first.
2. Open a new issue with:
   - Clear title and summary
   - Steps to reproduce
   - Expected vs actual behavior
   - Logs/error output
   - Environment details (OS, Docker/Kubernetes versions)

Use the Bug Report issue template.

## How to Suggest Features

1. Search existing issues/discussions.
2. Open a Feature Request issue with:
   - Problem statement
   - Proposed solution
   - Alternatives considered
   - Backward compatibility impact

Use the Feature Request issue template.

## Development Setup

### Prerequisites

- Docker and Docker Compose
- Helm 3 (optional for chart work)
- pre-commit (recommended)

### Local Setup

1. Clone the repository.
2. Install pre-commit:
   - `pre-commit install`
3. Run local checks:
   - `docker compose up` (or KrakenD check commands in README)
4. Validate generated config:
   - Ensure `tmp/out.json` is generated and valid.

## Branch Naming Convention

Use one of the following prefixes:

- `feat/<short-description>`
- `fix/<short-description>`
- `docs/<short-description>`
- `chore/<short-description>`
- `refactor/<short-description>`
- `test/<short-description>`
- `hotfix/<short-description>`

Example: `feat/add-rate-limit-template`

## Pull Request Process

1. Create a branch from `develop` (or `main` for urgent hotfixes).
2. Keep changes scoped and atomic.
3. Run lint/check workflows locally when possible.
4. Open a PR with:
   - What changed
   - Why it changed
   - How it was tested
   - Related issue (`Closes #123`)
5. Ensure CI passes.
6. Address review feedback.
7. Squash merge unless maintainers request otherwise.

## Coding Standards

- Follow existing YAML/Helm formatting style.
- Keep templates composable and environment-agnostic.
- Do not commit real secrets, tokens, or credentials.
- Prefer placeholders (e.g., `changeme`) and secret injection at runtime.
- Keep commits and PR titles aligned with conventional commit style.

## Commit Message Convention

Use conventional commits:

- `feat: ...`
- `fix: ...`
- `docs: ...`
- `chore: ...`
- `refactor: ...`
- `test: ...`
- `ci: ...`

