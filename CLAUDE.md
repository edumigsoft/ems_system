# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

EMS System (EduMigSoft System) is a Flutter/Dart monorepo for managing users, tasks (Aura), projects, and finances. The architecture uses a consistent multi-variant package structure that enables code sharing between Flutter apps and Dart/Shelf backend servers.

## Common Commands

### Package Management

```bash
# Install dependencies for all packages
./scripts/pub_get_all.sh

# Clean all packages (removes .dart_tool, build artifacts)
./scripts/clean_all.sh

# Run build_runner on all packages that use it
./scripts/build_runner_all.sh

# Apply dart fix to all packages
./scripts/dart_fix_all.sh
```

### Testing & Analysis

```bash
# Run tests in a specific package
cd packages/design_system/design_system_ui
flutter test

# Run analysis on a specific package
cd packages/design_system/design_system_shared
dart analyze

# Format code
dart format .
```

### Running the Demo App

```bash
cd apps/app_design_draft
flutter pub get
flutter run
```

## High-Level Architecture

### Multi-Variant Package Pattern

The monorepo uses a **4-variant package structure** where each package is split into platform-specific layers:

```
packages/{package_name}/
├── {package}_shared/    # Pure Dart, zero Flutter dependencies
├── {package}_ui/        # Flutter widgets and UI components
├── {package}_client/    # Client-side logic (currently minimal)
└── {package}_server/    # Server-side logic for Dart/Shelf backend
```

**Key Architectural Principles:**

1. **Shared Layer is Pure Dart**: `*_shared` packages contain ZERO Flutter dependencies. They use only `meta: ^1.17.0` and define domain models, value objects, and configuration as Plain Old Dart Objects (PODOs).

2. **Dependency Direction (Layered)**:
   ```
   *_ui     → *_shared
   *_client → *_shared
   *_server → *_shared
   ```
   No horizontal dependencies between variants.

3. **Configuration as Data**: Domain concepts like themes are represented as serializable data classes (not singletons), enabling:
   - API transmission between backend and frontend
   - Persistence in databases or local storage
   - Server-driven UI patterns
   - Dynamic configuration without code changes

### Design System Architecture

The `design_system` package demonstrates the mature implementation of this pattern:

**design_system_shared** (Pure Dart):
- `ColorValue`: Framework-agnostic color value object (ARGB int32)
  - Supports `fromHex()`, `fromARGB()`, `toHex()`, `toCSSRGBA()`
  - Serializable via `toMap()` / `fromMap()`

- `DSThemeConfig`: Immutable theme configuration data class
  - Contains `seedColor`, `cardBackground`, `cardBorder`, typography settings
  - Supports `copyWith()` pattern for variations
  - Can be sent via API or persisted

- Theme Presets: Static configurations (`DefaultPreset`, `BlueGrayPreset`, `AcquaPreset`, `LoloPreset`, `TealPreset`)

- Design Tokens: Constants for spacing, radius, paddings, shadows
  ```dart
  DSSpacing.xs, DSSpacing.small, DSSpacing.medium
  DSRadius.small, DSRadius.medium, DSRadius.large
  DSPaddings.extraSmall, DSPaddings.medium
  ```

**design_system_ui** (Flutter):
- `DSTheme`: Converts `DSThemeConfig` to Material 3 `ThemeData`
  - `DSTheme.fromConfig(config, brightness)` → `ThemeData`
  - `DSTheme.forPreset(DSThemeEnum.lolo, brightness)` → `ThemeData`

- Extensions:
  - `ColorValue.toColor()` ↔ `Color.toColorValue()`
  - `context.dsTheme`, `context.dsColors`, `context.dsTextStyles`

- Components: `DSCard`, `DSInfoCard`, `DSActionCard`

**Data Flow Example**:
```
Backend (design_system_server)
  → Generates DSThemeConfig
  → Sends via API as JSON

Flutter App (design_system_ui)
  → Receives JSON
  → Deserializes to DSThemeConfig (fromMap)
  → Converts to ThemeData via DSTheme.fromConfig()
  → Renders UI with theme
```

### Analysis Options

The project uses two analysis configurations:

- **`analysis_options_dart.yaml`**: For pure Dart packages (`*_shared`, `*_client`, `*_server`)
  - Uses `package:lints/recommended.yaml`
  - Enforces strict typing: `strict-casts`, `strict-inference`, `strict-raw-types`
  - Server/API specific rules: `avoid_dynamic_calls`, `cancel_subscriptions`, `close_sinks`

- **`analysis_options_flutter.yaml`**: For Flutter packages (`*_ui`, apps)
  - Uses `package:flutter_lints/flutter.yaml`
  - Flutter-specific rules: `use_key_in_widget_constructors`, `avoid_unnecessary_containers`
  - Performance rules: `prefer_const_constructors_in_immutables`

Both exclude generated files: `**/*.g.dart`, `**/*.freezed.dart`, `**/*.mocks.dart`

## Package Organization

**Active Packages:**
- `design_system/` - Design system with theme configs, color values, constants, and UI components
- `localizations/` - i18n with platform-agnostic string definitions and Flutter/server implementations

**Skeleton Packages (ready for implementation):**
- `core/` - Shared core functionality
- `images/` - Image assets and management
- `open_api/` - API client/server code generation

**Apps:**
- `apps/app_design_draft/` - Demo Flutter app showcasing design system with dynamic theme switching

## Development Guidelines

### Adding New Packages

Follow the 4-variant pattern:

1. Create package directory structure:
   ```
   packages/{feature}/
   ├── {feature}_shared/    # Pure Dart only
   ├── {feature}_ui/        # Flutter widgets
   ├── {feature}_client/    # Client logic
   └── {feature}_server/    # Server logic
   ```

2. **In `*_shared`**: Only use `meta` dependency. Define:
   - Domain models as immutable data classes
   - Value objects with serialization (`toMap`/`fromMap`)
   - Abstract interfaces
   - Constants and enums

3. **In `*_ui`**: Depend on `{feature}_shared`. Add:
   - Flutter widgets
   - Theme extensions
   - UI-specific logic

4. **In `*_client`/`*_server`**: Depend on `{feature}_shared` for platform-specific implementations.

### Coding Standards

From CONTRIBUTING.md:

- Follow [Effective Dart Guidelines](https://dart.dev/guides/language/effective-dart)
- Use Conventional Commits format:
  - `feat:` - New functionality
  - `fix:` - Bug correction
  - `docs:` - Documentation
  - `refactor:` - Code refactoring
  - `test:` - Tests
  - `chore:` - Maintenance

- Format before committing: `dart format`
- Run analysis: `dart analyze` or `flutter analyze`
- Maintain test coverage above 80%
- Tests in `test/` should mirror `lib/` structure

### Working with Design Tokens

When creating UI components, use design tokens from `design_system_shared`:

```dart
// Use spacing constants
padding: EdgeInsets.all(DSSpacing.medium)

// Use radius constants
borderRadius: BorderRadius.circular(DSRadius.medium)

// Use padding presets
padding: DSPaddings.medium
```

### Working with Themes

To add a new theme preset:

1. Define in `design_system_shared/lib/src/theme/presets/`:
   ```dart
   class NewPreset {
     static final DSThemeConfig config = DSThemeConfig(
       seedColor: ColorValue.fromHex('#HEXCODE'),
       // ... other settings
     );
   }
   ```

2. Add to `DSThemeEnum` in `design_system_shared`

3. Update `DSTheme.forPreset()` in `design_system_ui`

### Value Object Pattern

When creating domain concepts (colors, currencies, etc.), follow the `ColorValue` pattern:

```dart
class YourValue {
  final int _value;
  const YourValue._(this._value);

  // Factory constructors
  factory YourValue.fromX(...) => ...;

  // Serialization
  Map<String, dynamic> toMap() => {...};
  factory YourValue.fromMap(Map<String, dynamic> map) => ...;

  // Equality
  @override
  bool operator ==(Object other) => ...;

  @override
  int get hashCode => _value.hashCode;

  // Utilities
  YourValue copyWith(...) => ...;
}
```

## Project Structure

```
ems_system/
├── apps/                    # Flutter applications
│   └── app_design_draft/   # Design system demo app
├── servers/                 # Dart/Shelf backend servers (planned)
├── packages/               # Shared packages
│   ├── core/              # Core functionality (skeleton)
│   ├── design_system/     # Design system (active)
│   ├── images/            # Image assets (skeleton)
│   ├── localizations/     # i18n (active)
│   └── open_api/          # API definitions (skeleton)
├── scripts/               # Development automation scripts
├── docs/                  # Documentation
├── containers/            # Docker configurations
├── analysis_options_dart.yaml     # Linting for pure Dart
├── analysis_options_flutter.yaml  # Linting for Flutter
└── CONTRIBUTING.md        # Contribution guidelines
```

## Important Files

**Architecture Reference:**
- `packages/design_system/design_system_shared/lib/src/theme/ds_theme_config.dart` - Theme configuration model
- `packages/design_system/design_system_ui/lib/theme/ds_theme.dart` - Flutter theme provider
- `packages/design_system/design_system_shared/lib/src/colors/color_value.dart` - Value object pattern

**Demo Integration:**
- `apps/app_design_draft/lib/main.dart` - Theme switching implementation
