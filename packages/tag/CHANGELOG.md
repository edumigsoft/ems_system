# Changelog - Tag Feature

Todas as mudanças notáveis nesta feature serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Added
- Estrutura inicial da feature Tag
- Sistema de gerenciamento de tags globais
- CRUD completo de tags
- Suporte a cores customizadas
- Contador de uso de tags
- Widgets reutilizáveis (TagChip, TagSelector)
- API REST completa
- Integração com app_v1 e server_v1

### Changed
- Migração da entidade Tag de `project_core_shared` para `tag_shared`

### Technical
- Implementação seguindo padrão Entity + EntityDetails
- Result Pattern em todos os repositórios e use cases
- Validators com Zard
- Tabela Drift com DriftTableMixinPostgres
- UI com ResponsiveLayout e Design System

## Notas

Para mudanças específicas de cada pacote, consulte:
- [tag_shared/CHANGELOG.md](./tag_shared/CHANGELOG.md)
- [tag_client/CHANGELOG.md](./tag_client/CHANGELOG.md)
- [tag_server/CHANGELOG.md](./tag_server/CHANGELOG.md)
- [tag_ui/CHANGELOG.md](./tag_ui/CHANGELOG.md)
