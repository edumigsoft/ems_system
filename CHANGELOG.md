# Changelog

## [1.0.0] - 2026-01-19

### Added
- Arquitetura multi-sistema para suportar múltiplos aplicativos (EMS, futuro SMS)
- Versionamento de aplicativos (`app_v1`, `server_v1`)
- Aplicativo de rascunhos de design (`apps/ems/app_design_draft`)
- Feature Open API (pacotes: `open_api_server`, `open_api_shared`)
- Feature Images (pacote: `images_ui`)
- Feature Localizations (pacotes: `localizations_server`, `localizations_shared`, `localizations_ui`)
- Design System (pacotes: `design_system_shared`, `design_system_ui`)

### Changed
- **[BREAKING]** Reestruturação completa de apps e servers por domínio
  - Apps movidos de `apps/app/` para `apps/ems/app_v1/`
  - Servers movidos de `servers/server/` para `servers/ems/server_v1/`
- Reorganização de packages para suportar feature compartilhadas
- Consolidação do padrão de 4 camadas (`_shared`, `_server`, `_client`, `_ui`)
- Core atualizado para versão 1.0.0
- Documentação completa de todas as features

### Fixed
- Inconsistências na estrutura de diretórios
- Documentação desatualizada nos READMEs



Todas as mudanças notáveis neste projeto serão documentadas neste arquivo.

O formato é baseado em [Keep a Changelog](https://keepachangelog.com/pt-BR/1.0.0/),
e este projeto adere ao [Semantic Versioning](https://semver.org/lang/pt-BR/).

## [Unreleased]

### Planejado
- Sistema de gestão de usuários
- Sistema de gestão de Aura (Tarefas)
- Sistema de gestão de projetos
- Sistema de gestão financeira
- Aplicativo Flutter
- Servidor Dart/Shelf

## [0.1.0] - 2026-01-04

### Adicionado
- Estrutura inicial do projeto monorepo
- Organização de packages (core, design_system, features)
- Configuração de apps (app Flutter)
- Configuração de servers (server Dart/Shelf)
- Documentação inicial (README.md, CHANGELOG.md, LICENSE.md, CONTRIBUTING.md)

[Unreleased]: https://github.com/edumigsoft/ems_system/compare/v0.1.0...HEAD
[0.1.0]: https://github.com/edumigsoft/ems_system/releases/tag/v0.1.0
