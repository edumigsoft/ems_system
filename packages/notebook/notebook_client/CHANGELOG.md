# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-24

### Added
- Initial implementation of `notebook_client` package
- `NotebookRepositoryImpl`: HTTP implementation of `NotebookRepository` interface
  - `create()`: Create new notebooks
  - `getById()`: Retrieve notebook by ID
  - `getAll()`: List notebooks with filtering (active status, search, project, parent, type, tags, overdue reminders)
  - `update()`: Update existing notebooks
  - `delete()`: Soft delete notebooks
  - `restore()`: Restore soft-deleted notebooks
- `DocumentReferenceRepositoryImpl`: HTTP implementation of `DocumentReferenceRepository` interface
  - `create()`: Create new document references
  - `getById()`: Retrieve document by ID
  - `getByNotebookId()`: List documents for a notebook with storage type filtering
  - `update()`: Update existing document references
  - `delete()`: Permanently delete document references
- `NotebookApiService`: Retrofit API service with type-safe HTTP methods
  - RESTful endpoints for notebooks (`/notebooks`)
  - Endpoint for notebook documents (`/notebooks/{id}/documents`)
- `DocumentReferenceApiService`: Retrofit API service for document operations
  - RESTful endpoints for documents (`/documents`)
- Comprehensive error handling with `DioException` conversion to user-friendly messages
- Result Pattern implementation (ADR-0001) for all repository methods
- Full documentation in README.md
- Code generation support with `build_runner`

### Technical Details
- Dependencies: `dio ^5.0.0`, `retrofit 4.9.1`, `notebook_shared`, `core_shared`, `core_client`
- Analysis: Using `analysis_options_dart.yaml` for pure Dart packages
- Architecture: Follows 4-variant package structure (ADR-0005)
- Error handling: Portuguese error messages for user-facing errors

### Documentation
- Comprehensive README with usage examples
- API endpoint reference table
- Query parameter documentation
- Error handling guide
- Architecture and dependency information

## [Unreleased]

### Planned
- Integration tests with mock server
- Retry logic for failed requests
- Caching layer for offline support
- Request/response logging utilities
- Authentication token handling integration
