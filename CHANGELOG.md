# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Changed

- Renamed the KrakenD lint workflow to `lint.yaml` so README badges and workflow references resolve correctly
- Replaced placeholder maintainer/security contact values with GitHub-native reporting paths
- Simplified the Apache `NOTICE` file to project attribution text and documented it in the README
- Added `.codex/` to `.gitignore` to avoid committing local assistant workspace artifacts

## [1.0.0] - 2026-03-30

### Added

- Open-source governance files: Code of Conduct, Contributing, Security policy, changelog
- GitHub community health files: issue templates, PR template, and CODEOWNERS
- Apache License 2.0 in [LICENSE](LICENSE)

### Changed

- Rewrote README with setup, usage, configuration, and contribution guidance
- Expanded `.gitignore` for generated files, local env files, and editor artifacts
- Replaced hardcoded sample credentials with placeholders in observability/Tyk configs
