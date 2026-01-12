# Core Feature

The **Core** feature provides the foundational building blocks for the EMS System (EduMigSoft). It encapsulates shared domain logic, base architectural components, and reusable UI elements that are used across other features.

## Architecture

This feature follows the standard **Feature-First + DDD (Domain-Driven Design)** architecture, divided into specialized subpackages:

| Package | Path | Responsibility |
|---------|------|----------------|
| **Core Shared** | [`core_shared/`](./core_shared/) | Shared domain entities, interfaces, value objects, and utils used by multiple features. |
| **Core Client** | [`core_client/`](./core_client/) | Infrastructure implementations for the client-side (HTTP clients, local storage, etc.). |
| **Core Server** | [`core_server/`](./core_server/) | Server-side implementations (if applicable) or backend compatibility layers. |
| **Core UI** | [`core_ui/`](./core_ui/) | Reusable UI components, widgets, and design system elements. |

## Getting Started

To use this feature in your specific feature package, depend on the appropriate subpackage in your `pubspec.yaml`:

```yaml
dependencies:
  core_shared:
    path: ../../packages/core/core_shared
  core_ui:
    path: ../../packages/core/core_ui
```

## Documentation

For more detailed information about direct implementation and contributing, please refer to the specific documentation within each subpackage.

- [Standard Package Structure](../../docs/adr/0005-standard-package-structure.md)
- [Flutter & Dart Rules](../../docs/rules/flutter_dart_rules.md)
