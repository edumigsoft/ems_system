# Contributing to Core Feature

Thank you for your interest in contributing to the **Core** feature of the EMS System! This document provides guidelines for contributing to this specific feature and its subpackages (`core_shared`, `core_client`, `core_server`, `core_ui`).

## General Workflow

1.  **Fork and Clone**: Fork the repository and clone it locally.
2.  **Branching**: Create a new branch for your feature or fix.
    *   Format: `feat/feature-name` or `fix/issue-description`.
3.  **Development**: Make your changes in the appropriate subpackage.
    *   **Domain Logic**: `core_shared/lib/src/domain`
    *   **Shared Utilities**: `core_shared/lib/src/utils`, `core_shared/lib/src/validators`
    *   **Client Infrastructure**: `core_client/lib/src`
    *   **Server Infrastructure**: `core_server/lib/src`
    *   **UI Components**: `core_ui/lib/ui`
    *   **MVVM Base**: `core_ui/core`
4.  **Testing**: Ensure all tests pass.
    *   Run tests in the specific subpackage you modified:
    ```bash
    cd core_shared && dart test
    cd core_client && dart test
    cd core_server && dart test
    cd core_ui && flutter test
    ```
5.  **Code Analysis**: Run static analysis to catch issues:
    ```bash
    dart analyze
    ```
6.  **Formatting**: Format your code before committing:
    ```bash
    dart format .
    ```
7.  **Documentation**: Update documentation if necessary (READMEs, Docstrings).
8.  **Commit**: Follow commit message conventions (see below).
9.  **Pull Request**: Submit a PR describing your changes.

## Development Standards

Seguimos padrões rigorosos de codificação e arquitetura:

### Key Rules

*   **Domain Purity**: Code in `core_shared/lib/src/domain` must depend ONLY on Dart SDK. No Flutter, no external libraries (unless strictly utility like `equatable` or `zard`).
*   **Result Pattern**: All error handling must use the `Result<T>` pattern. Never throw exceptions in domain or application layers.
*   **Documentation**: All public members must have `///` docstrings with clear descriptions.
*   **Immutability**: Prefer immutable data structures. Use `final` for all fields unless mutation is absolutely necessary.
*   **Type Safety**: Avoid `dynamic` types. Use explicit typing.

## Commit Message Conventions

Follow the [Conventional Commits](https://www.conventionalcommits.org/) specification:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, missing semicolons, etc.)
- `refactor`: Code refactoring
- `test`: Adding or updating tests
- `chore`: Maintenance tasks

**Examples:**
```
feat(core_shared): add Email value object
fix(core_client): handle network timeout errors
docs(core_ui): update BaseViewModel usage examples
```

## Testing Guidelines

- Write tests for all new features and bug fixes
- Maintain or improve code coverage
- Use meaningful test descriptions
- Follow AAA pattern (Arrange, Act, Assert)

**Running all tests:**
```bash
# From root directory
dart test core_shared
dart test core_client
dart test core_server
flutter test core_ui
```

## Documentation Guidelines

- Update README.md if adding new features
- Add inline documentation (`///`) for all public APIs
- Include usage examples for complex features
- Keep CHANGELOG.md updated following [Keep a Changelog](https://keepachangelog.com/en/1.0.0/)

## Code Review Process

All contributions require code review:

1. Submit PR with clear description of changes
2. Ensure all CI checks pass (if configured)
3. Address reviewer feedback
4. Wait for approval from at least one maintainer
5. Squash and merge once approved

## Reporting Issues

If you find a bug or have a feature request for the Core feature, please open an issue in the main repository using the appropriate template.

**Include:**
- Clear description of the issue/feature
- Steps to reproduce (for bugs)
- Expected vs actual behavior
- Environment details (Dart/Flutter version, OS)
