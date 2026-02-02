# Changelog

All notable changes to notebook_shared will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-24

### Added
- Initial release following Clean Architecture patterns
- **Entities (Pure Domain)**:
  - `Notebook` entity - Pure domain representation without persistence fields
  - `DocumentReference` entity - Pure domain for document references
- **EntityDetails (BaseDetails Implementation)**:
  - `NotebookDetails` - Implements `BaseDetails` with `createdAt`/`updatedAt` as non-nullable `DateTime`
  - `DocumentReferenceDetails` - Complete aggregation with metadata
- **DTOs (Data Transfer Objects)**:
  - `NotebookCreate` - Creation DTO without `id`
  - `NotebookUpdate` - Update DTO with required `id` and optional fields (includes `isActive` and `isDeleted`)
  - `DocumentReferenceCreate` - Creation DTO with path validation
  - `DocumentReferenceUpdate` - Update DTO with state control fields
- **Enums**:
  - `NotebookType` - quick, organized, reminder
  - `DocumentStorageType` - server, local, url
- **Business Logic**:
  - Reminder validation and overdue checking
  - Document type detection (PDF, image, document)
  - File size formatting
  - Path/URL validation based on storage type
  - Hierarchical notebook support (parent/child)
  - Tag management
  - Project association

### Architecture
- Follows entity patterns from `docs/architecture/entity_patterns.md`
- Implements BaseDetails synchronization (ADR-0006)
- Clean separation: Entity (pure) → EntityDetails (with metadata) → DTOs (operations)
- No serialization in entities/details (responsibility of Models layer)
- Dependency: `core_shared` for `BaseDetails` interface
