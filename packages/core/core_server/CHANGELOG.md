# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-01-12

### Added
- Initial package documentation (`README.md`).
- `SecurityService` interface now uses `Result<T>` pattern for error handling.
- `JWTSecurityService` implementation updated to support `Result<T>`.
- `generateTokens` helper function updated to return `Result<(String, String)>`.

### Changed
- Middleware `verificationJWT` and `authorization` updated to handle `Result` types internally.
