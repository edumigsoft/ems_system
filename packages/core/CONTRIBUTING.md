# Contributing to Core Feature

Thank you for your interest in contributing to the **Core** feature of the EMS System! This document provides guidelines for contributing to this specific feature and its subpackages (`core_shared`, `core_client`, `core_ui`, etc.).

## General Workflow

1.  **Fork and Clone**: Fork the repository and clone it locally.
2.  **Branching**: Create a new branch for your feature or fix.
    *   Format: `feat/feature-name` or `fix/issue-description`.
3.  **Development**: Make your changes in the appropriate subpackage.
    *   **Domain Logic**: `core_shared/lib/src/domain`
    *   **UI Components**: `core_ui/lib/ui`
    *   **Infrastructure**: `core_client/lib/src`
4.  **Testing**: Ensure all tests pass.
    *   Run tests in the specific subpackage you modified: `flutter test` or `dart test`.
5.  **Documentation**: Update documentation if necessary (READMEs, Docstrings).
6.  **Pull Request**: Submit a PR describing your changes.

## Development Standards

We follow strict coding and architectural standards. Please review them before contributing:

*   **Architecture**: [Standard Package Structure](../../docs/adr/0005-standard-package-structure.md)
*   **Code Style**: [Flutter & Dart Rules](../../docs/rules/flutter_dart_rules.md)

### Key Rules

*   **Domain Purity**: Code in `core_shared/domain` must depend ONLY on Dart SDK. No Flutter, no external libraries (unless strictly utility like `equatable` or `zard`).
*   **Result Pattern**: All references to error handling must use the `Result<T>` pattern.
*   **Documentation**: All public members must have `///` docstrings.

## Scripts

Useful scripts located in `scripts/`:

- `scripts/check_documentation.sh`: Verifies documentation coverage.
- `scripts/validate_architecture.sh`: Checks if the package structure follows ADR-0005.

## Reporting Issues

If you find a bug or have a feature request for the Core feature, please open an issue in the main repository using the appropriate template.
