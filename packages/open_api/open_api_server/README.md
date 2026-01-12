# Open API Server

This package provides a Shelf router to serve OpenAPI documentation (Swagger UI) and the generated OpenAPI specification (JSON). It is a key component for exposing API documentation in the EMS System.

## Features

-   **Swagger UI**: Serves a static HTML file to visualize and interact with the API interface.
-   **OpenAPI Schemas**: Dynamically generates and serves the `openapi.json` specification using `OpenApiGenerator`.
-   **Seamless Integration**: Designed to integrate easily with `core_server` routes.

## Getting Started

Add the dependency to your `pubspec.yaml`:

```yaml
dependencies:
  open_api_server:
    path: ../open_api_server
```

## Usage

To use the OpenAPI server routes, mount the `OpenApiRoutes` class in your main application router.

```dart
import 'package:open_api_server/open_api_server.dart';
import 'package:shelf_router/shelf_router.dart';

final router = Router();

// Initialize the OpenApiRoutes
final openApiRoutes = OpenApiRoutes(
  backendBaseApi: 'http://localhost:8080', // Base URL of your API
  staticPath: 'assets', // Path to your Swagger UI static assets
);

// Mount the routes
router.mount(openApiRoutes.path, openApiRoutes.router);
```

## Structure

-   `lib/open_api_server.dart`: The main entry point exporting the package routes.
-   `lib/routes/open_api_routes.dart`: Implements the `Routes` class to handle Swagger UI and JSON spec requests.

## Dependencies

-   `shelf`: Web server middleware for Dart.
-   `shelf_router`: Routing logic for Shelf.
-   `core_server`: Core server utilities.
-   `open_api_shared`: Shared OpenAPI logic and generation.
