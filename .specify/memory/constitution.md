# **EMS System Constitution**

**Version:** 1.1.1 | **Ratified:** 2026-01-10 | **Last Amended:** 2026-01-11

## Core Principles

### I. Multi-Variant Architecture (NON-NEGOTIABLE)
Every package MUST follow the 4-variant structure: `{package}_shared`, `{package}_ui`, `{package}_client`, and `{package}_server`. This pattern enables:
- Code sharing between Flutter apps and Dart/Shelf backend servers
- Clear separation of concerns across platform boundaries
- Independent deployment of client and server components

**Rationale:** The multi-variant architecture is the foundation of the EMS System's ability to maintain a single codebase while serving multiple platforms (mobile, web, server). Breaking this pattern would compromise the entire monorepo structure.

### II. Shared Layer Purity (NON-NEGOTIABLE)
All `*_shared` packages MUST contain ZERO Flutter dependencies. Only `meta: ^1.17.0` and pure Dart dependencies are allowed. Domain models, value objects, and configuration MUST be Plain Old Dart Objects (PODOs) with serialization support (`toMap()`/`fromMap()`).

**Rationale:** Shared layers must be platform-agnostic to enable server-side usage. Flutter dependencies in shared code would prevent backend integration and violate the separation of concerns required for server-driven UI patterns.

### III. Test Coverage Minimum (NON-NEGOTIABLE)
Test coverage MUST be maintained above 80% for all packages. Tests MUST mirror the structure of `lib/` in `test/` directories. Unit tests are mandatory for all public APIs.

**Rationale:** Given the complexity of a multi-variant monorepo with user management, tasks, projects, and finance modules, high test coverage is essential to prevent regressions and ensure reliability across platform boundaries.

### IV. Code Quality Gates
Before any commit:
- `dart format` or `flutter format` MUST be executed
- `dart analyze` or `flutter analyze` MUST pass with zero errors
- Analysis options MUST be enforced:
  - `analysis_options_dart.yaml` for pure Dart packages (`*_shared`, `*_client`, `*_server`)
  - `analysis_options_flutter.yaml` for Flutter packages (`*_ui`, apps)

No horizontal dependencies between variants are allowed.

**Rationale:** Consistent code quality prevents technical debt accumulation and ensures maintainability across the large monorepo structure with multiple packages and teams.

### V. Package Independence
Each package variant MUST be:
- Independently testable without requiring sibling packages
- Deployable in isolation (for `*_server` and `*_client`)
- Documented with its own README, CHANGELOG, and CONTRIBUTING files

Dependencies MUST follow the layered pattern:
- `*_ui` → `*_shared`
- `*_client` → `*_shared`
- `*_server` → `*_shared`

**Rationale:** Package independence enables incremental development, isolated testing, and flexible deployment strategies. It prevents circular dependencies and maintains clear architectural boundaries.

### VI. Conventional Commits
All commits MUST follow [Conventional Commits](https://www.conventionalcommits.org/) format:
- `feat:` - New functionality
- `fix:` - Bug correction
- `docs:` - Documentation
- `refactor:` - Code refactoring
- `test:` - Tests
- `chore:` - Maintenance

**Rationale:** Conventional commits enable automated CHANGELOG generation, semantic versioning, and clear communication of change intent across the team.

### VII. Configuration as Data
Domain concepts (themes, settings, business rules) MUST be represented as serializable data classes, not singletons or static configurations. This enables:
- API transmission between backend and frontend
- Persistence in databases or local storage
- Server-driven UI patterns
- Dynamic configuration without code changes

**Rationale:** The EMS System's multi-platform nature requires configuration flexibility. Server-driven UI and dynamic theming are key architectural requirements that depend on configuration being treated as data.

### VIII. Security and Dependency Management (NEW)
- All external dependencies MUST be regularly checked for vulnerabilities using `pub audit`.
- Cryptographic operations SHOULD prefer actively maintained libraries (e.g., `bcrypt` over `argon2`).
- Sensitive keys and secrets MUST be stored in `.env` files and never committed to the repository.
- Refresh tokens and other sensitive data MUST be securely stored and validated.

**Rationale:** Proactive security measures and dependency hygiene are crucial for a system managing user data, authentication, and potentially financial information. Storing secrets securely prevents accidental exposure.

### IX. Naming and Modularity Clarity (EXPANDED)
- Package names SHOULD be unambiguous and reflect their core responsibility (e.g., renaming `auth_old` to `auth` or `authentication`).
- Use `DTO` suffix for data transfer objects instead of `Model` to align with best practices (`UserDTO` vs `UserModel`).
- The primary domain entity SHOULD reside in the `core` package, while repository interfaces SHOULD be located near the specific feature modules that use them.

**Rationale:** Clear and consistent naming reduces cognitive load and ambiguity. Using `DTO` clarifies the object's purpose. Placing entities and interfaces strategically promotes better separation of concerns and modularity.

### X. Architected Integration (NEW)
- The `*_shared` layer MUST contain DTOs and repository interfaces.
- The `*_client` layer MUST provide concrete implementations of the repositories defined in `*_shared`.
- Favor MVVM architecture (`ViewModel extends ChangeNotifier`) and constructor-based dependency injection using `get_it`.
- Avoid code generators like `json_serializable` or `freezed` for entities.

**Rationale:** Explicitly linking the constitution to preferred architectural patterns ensures consistency in implementation across all modules, promoting a unified and predictable codebase structure.

### XI. Environment-Specific Operations (NEW)
- Logging levels MUST be configurable per environment (development, staging, production) via a specific main entry point file.
- Errors during initialization MUST be captured and integrated with an auditing system for proactive monitoring.

**Rationale:** Environment-specific behavior (like logging verbosity) is essential for efficient debugging and stable production operation. Monitoring initialization errors helps identify systemic issues early.

## Development Workflow

### Code Review Requirements
- Minimum 1 approval required for all PRs
- CI/CD pipeline MUST pass
- Code coverage MUST NOT decrease
- All Constitution principles MUST be verified during review

### Branch Strategy
- Feature branches: `{###-feature-name}` (numbered sequentially)
- Follow specification-driven development via `.specify/` commands
- Each feature must have corresponding documentation in `specs/{###-feature}/`

### Pre-Commit Checklist
- [ ] Code follows Effective Dart Guidelines
- [ ] `dart format` executed
- [ ] `dart analyze` passes with zero errors
- [ ] All tests pass
- [ ] Test coverage ≥80%
- [ ] CHANGELOG.md updated
- [ ] Documentation updated (if public APIs changed)
- [ ] Multi-variant architecture maintained
- [ ] No Flutter dependencies in `*_shared` packages

## Technology Standards

### Language and Framework Requirements
- Dart SDK: `>=3.0.0`
- Flutter SDK: `>=3.0.0` (for `*_ui` packages and apps)
- Backend Framework: Dart Shelf (for `*_server` packages)

### Package Structure
All packages MUST follow this structure: