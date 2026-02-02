# Changelog

All notable changes to tag_shared will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [0.1.0] - 2026-01-24

### Added
- Initial release
- Tag entity (pure domain)
- TagDetails entity (with BaseDetails)
- TagCreate and TagUpdate DTOs
- TagRepository interface with Result pattern
- Use cases: Create, GetAll, GetById, Update, Delete
- TagDetailsModel, TagCreateModel, TagUpdateModel (serialization)
- TagCreateValidator and TagUpdateValidator (Zard)
- TagConstants
