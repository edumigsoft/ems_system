# CLAUDE.md

Este arquivo fornece orientações para o Claude Code (claude.ai/code) ao trabalhar com código neste repositório.

## Visão Geral do Projeto

EMS System (EduMigSoft System) é um monorepo Flutter/Dart multi-serviço para gerenciar usuários, tarefas (Aura), projetos e finanças. A arquitetura usa uma estrutura de pacotes multi-variante consistente que permite compartilhamento de código entre aplicativos Flutter e servidores backend Dart/Shelf.

**Versão Atual:** 1.1.0 (veja arquivo `VERSION`)

### Arquitetura Multi-Serviço

O sistema suporta múltiplos serviços independentes:
- **EMS (EduMigSoft)**: Sistema principal de gerenciamento educacional
  - App: `apps/ems/app_v1/` (produção) e `apps/ems/app_design_draft/` (demonstração)
  - Server: `servers/ems/server_v1/` (backend Dart/Shelf)

- **SMS (School Management System)**: Sistema de gerenciamento escolar
  - App: `apps/sms/app_v1/` (produção)
  - Server: `servers/sms/server_v1/` (backend Dart/Shelf)

Ambos compartilham:
- Pacotes comuns em `/packages`
- Infraestrutura de banco de dados PostgreSQL (`servers/containers/postgres/`)
- Configurações de análise e scripts de automação

## Comandos Comuns

### Testes e Análise

```bash
# Executar testes em um pacote específico
cd packages/design_system/design_system_ui
flutter test

# Executar análise em um pacote específico
cd packages/design_system/design_system_shared
dart analyze

# Formatar código
dart format .
```

### Executando Aplicações

```bash
# App de demonstração do design system
cd apps/ems/app_design_draft
flutter pub get
flutter run

# App EMS (produção)
cd apps/ems/app_v1
flutter pub get
flutter run

# App SMS (produção)
cd apps/sms/app_v1
flutter pub get
flutter run
```

### Infraestrutura e Docker

# Iniciar banco de dados PostgreSQL compartilhado
cd servers/containers/postgres
docker-compose up -d

# Executar servidor EMS
cd servers/ems/server_v1
dart run bin/server.dart

# Executar servidor SMS
cd servers/sms/server_v1
dart run bin/server.dart
```

**Nota:** Veja `servers/INFRASTRUCTURE.md` para detalhes completos sobre configuração Docker e infraestrutura.

## Arquitetura

> [!IMPORTANT]
> A documentação completa da arquitetura do sistema, incluindo padrões de pacotes, Clean Architecture, MVVM e fluxo de dados, foi movida para **[ARCHITECTURE.md](ARCHITECTURE.md)**.
>
> Consulte `ARCHITECTURE.md` para detalhes sobre:
> - Estrutura de Pacotes Multi-Variante (Shared, UI, Client, Server)
> - Clean Architecture & MVVM
> - Padrões de Design System e Validação
> - Injeção de Dependência e Fluxos de Dados

## Organização de Pacotes

### Pacotes Completos (4/4 variantes)
Estes pacotes implementam todas as 4 variantes (_shared, _ui, _client, _server):
- `auth/` - Sistema de autenticação e autorização
- `core/` - Funcionalidade central compartilhada (Result pattern, error handling, base repositories)
- `notebook/` - Gerenciamento de notas/cadernos
- `school/` - Gerenciamento escolar
- `tag/` - Sistema de tags/etiquetas
- `user/` - Gerenciamento de usuários

### Pacotes Parciais (implementação em andamento)
- `design_system/` (2/4) - Design system com configurações de tema, valores de cor e componentes
  - ✓ `design_system_shared`, `design_system_ui`
  - ⚠ `design_system_client`, `design_system_server` (diretórios existem, sem pubspec.yaml)

- `localizations/` (3/4) - Sistema de internacionalização (i18n)
  - ✓ `localizations_shared`, `localizations_ui`, `localizations_server`
  - ⚠ `localizations_client` (diretório existe, sem pubspec.yaml)

- `open_api/` (2/4) - Definições e geração de código de API
  - ✓ `open_api_shared`, `open_api_server`
  - ⚠ `open_api_client`, `open_api_ui` (diretórios existem, sem pubspec.yaml)

- `images/` (1/4) - Gerenciamento de ativos de imagem
  - ✓ `images_ui`
  - ⚠ Outras variantes (diretórios existem, sem pubspec.yaml)

### Aplicações
- `apps/ems/app_design_draft/` - App de demonstração do design system com troca dinâmica de tema
- `apps/ems/app_v1/` - Aplicação EMS em produção
- `apps/sms/app_v1/` - Aplicação SMS em produção

### Servidores Backend
- `servers/ems/server_v1/` - Servidor EMS (Dart/Shelf)
- `servers/sms/server_v1/` - Servidor SMS (Dart/Shelf)
- `servers/containers/postgres/` - Banco de dados PostgreSQL compartilhado (Docker)

## Diretrizes de Desenvolvimento

### Implementação de Novas Features

Para implementar uma nova feature, consulte os seguintes documentos obrigatórios:

1.  **[Regras de Features](docs/rules/new_feature.md)**: Template detalhado passo a passo.
2.  **[Arquitetura](ARCHITECTURE.md)**: Entenda a separação de camadas e responsabilidades.

**Resumo da Ordem de Implementação:**
1. `{feature}_shared` (Domínio)
2. `{feature}_client` (API Client)
3. `{feature}_server` (Backend)
4. `{feature}_ui` (Apresentação)

**Nota:** Valide cada pacote com `dart analyze` antes de prosseguir para o próximo.

### Padrões de Codificação

Do CONTRIBUTING.md:

- Siga as [Diretrizes Effective Dart](https://dart.dev/guides/language/effective-dart)
- Use formato Conventional Commits:
  - `feat:` - Nova funcionalidade
  - `fix:` - Correção de bug
  - `docs:` - Documentação
  - `refactor:` - Refatoração de código
  - `test:` - Testes
  - `chore:` - Manutenção

- Formate antes de fazer commit: `dart format`
- Execute análise: `dart analyze` ou `flutter analyze`
- Mantenha cobertura de testes acima de 80%
- Testes em `test/` devem espelhar a estrutura de `lib/`

### Trabalhando com Múltiplos Serviços

O projeto suporta múltiplos serviços (EMS, SMS) que compartilham pacotes:

**Ao adicionar features:**
- Determine se a feature é específica de um serviço ou compartilhada
- Features compartilhadas vão em `/packages`

**Ao modificar pacotes compartilhados:**
- Lembre-se que mudanças afetam TODOS os serviços (EMS e SMS)
- Execute testes em todos os apps afetados
- Verifique compatibilidade com todos os servidores

**Ao trabalhar com banco de dados:**
- PostgreSQL é compartilhado entre EMS e SMS
- Migrations devem considerar ambos os serviços
- Veja `servers/INFRASTRUCTURE.md` para detalhes

### Trabalhando com Design Tokens

Ao criar componentes de UI, use design tokens de `design_system_shared`:

```dart
// Use constantes de espaçamento
padding: EdgeInsets.all(DSSpacing.medium)

// Use constantes de raio
borderRadius: BorderRadius.circular(DSRadius.medium)

// Use presets de padding
padding: DSPaddings.medium
```

### Trabalhando com Temas

Para adicionar um novo preset de tema:

1. Defina em `design_system_shared/lib/src/theme/presets/`:
   ```dart
   class NewPreset {
     static final DSThemeConfig config = DSThemeConfig(
       seedColor: ColorValue.fromHex('#HEXCODE'),
       // ... outras configurações
     );
   }
   ```

2. Adicione ao `DSThemeEnum` em `design_system_shared`

3. Atualize `DSTheme.forPreset()` em `design_system_ui`



### Validação de Formulários

Consulte `ARCHITECTURE.md` para obter detalhes sobre o padrão **Dual Interface** (CoreValidator + FormValidationMixin) e exemplos de implementação.

## Estrutura do Projeto

```
ems_system/
├── VERSION                             # Versão atual (2.1.0)
├── CLAUDE.md                           # Este arquivo (instruções para Claude)
├── ARCHITECTURE.md                     # Documentação detalhada de arquitetura
├── CONTRIBUTING.md                     # Diretrizes de contribuição
├── README.md, CHANGELOG.md, LICENSE.md # Documentação padrão
│
├── apps/                               # Aplicações Flutter
│   ├── ems/
│   │   ├── app_design_draft/          # App de demonstração do design system
│   │   └── app_v1/                    # App EMS em produção
│   └── sms/
│       └── app_v1/                    # App SMS em produção
│
├── servers/                            # Servidores backend Dart/Shelf
│   ├── containers/
│   │   └── postgres/                  # Banco de dados PostgreSQL compartilhado
│   ├── ems/
│   │   ├── server_v1/                 # Servidor EMS em produção
│   │   └── container/                 # Docker setup para EMS
│   └── sms/
│       ├── server_v1/                 # Servidor SMS em produção
│       └── container/                 # Docker setup para SMS
│   └── INFRASTRUCTURE.md              # Documentação de infraestrutura Docker
│
├── packages/                          # Pacotes compartilhados (padrão 4 variantes)
│   ├── auth/                          # Autenticação (completo 4/4)
│   ├── core/                          # Funcionalidade central (completo 4/4)
│   ├── design_system/                 # Design system (parcial 2/4)
│   ├── images/                        # Gerenciamento de imagens (parcial 1/4)
│   ├── localizations/                 # i18n (parcial 3/4)
│   ├── notebook/                      # Notas/cadernos (completo 4/4)
│   ├── open_api/                      # Definições de API (parcial 2/4)
│   ├── project/                       # Projetos (estrutura hierárquica especial)
│   │   ├── project_core/              # Core de projetos (parcial 2/4)
│   │   ├── project/                   # Sub-feature (esqueleto)
│   │   └── task/                      # Sub-feature de tarefas (esqueleto)
│   ├── school/                        # Gerenciamento escolar (completo 4/4)
│   ├── tag/                           # Sistema de tags (completo 4/4)
│   ├── user/                          # Gerenciamento de usuários (completo 4/4)
│   └── zard_form/                     # DESCONTINUADO - Use FormValidationMixin (core_ui)
│
├── scripts/                           # Scripts de automação
│   ├── pub_get_all.sh                # Instalar dependências
│   ├── clean_all.sh                  # Limpar artefatos
│   ├── build_runner_all.sh           # Executar build_runner
│   ├── dart_fix_all.sh               # Aplicar dart fix
│   ├── check_documentation.sh        # Validar documentação
│   ├── validate_architecture.sh      # Validar arquitetura
│   └── generators/                   # Ferramentas de geração de código
│
├── docs/                              # Documentação detalhada
│   ├── core_package_analysis.md      # Análise do pacote core
│   ├── adr/                          # Architecture Decision Records
│   │   ├── 0001-result-pattern.md
│   │   ├── 0002-dio-error-handler.md
│   │   ├── 0003-base-repository.md
│   │   ├── 0004-form-validation-zard.md
│   │   ├── 0005-package-structure.md
│   │   └── 0006-base-details-sync.md
│   ├── architecture/                 # Guias de arquitetura
│   │   ├── architecture_patterns.md
│   │   ├── design_system_guide.md
│   │   ├── entity_patterns.md
│   │   └── features_hierarchy.md
│   └── rules/                        # Regras e convenções
│       ├── new_feature.md
│       └── flutter_dart_rules.md
│
├── openspec/                          # Sistema de especificações e propostas
│   ├── AGENTS.md                     # Instruções para agentes IA
│   ├── project.md                    # Especificação do projeto
│   ├── changes/                      # Propostas de mudança
│   └── specs/                        # Especificações detalhadas
│
├── analysis_options_dart.yaml         # Linting para Dart puro
├── analysis_options_flutter.yaml      # Linting para Flutter
├── devtools_options.yaml             # Configuração DevTools
└── pubspec.yaml                      # Workspace root (define todos os membros)
```

## Arquivos Importantes

**Documentação Principal:**
- `CLAUDE.md` - Este arquivo (instruções específicas para Claude Code)
- `ARCHITECTURE.md` - Documentação completa de arquitetura (37.5 KB, em português)
- `CONTRIBUTING.md` - Diretrizes de contribuição e padrões de código
- `VERSION` - Versão atual do sistema (2.1.0)
- `servers/INFRASTRUCTURE.md` - Documentação de infraestrutura Docker e PostgreSQL

**Architecture Decision Records (ADRs):**
- `docs/adr/0001-result-pattern.md` - Pattern Result para tratamento de erros
- `docs/adr/0002-dio-error-handler.md` - Mixin Dio error handler
- `docs/adr/0003-base-repository.md` - Padrão base repository
- `docs/adr/0004-form-validation-zard.md` - Validação de formulários com Zard
- `docs/adr/0005-package-structure.md` - Estrutura padrão de pacotes
- `docs/adr/0006-base-details-sync.md` - Sincronização base details

**Guias de Arquitetura:**
- `docs/architecture/architecture_patterns.md` - Padrões arquiteturais do sistema
- `docs/architecture/design_system_guide.md` - Guia do design system
- `docs/architecture/entity_patterns.md` - Padrões de entidades
- `docs/architecture/features_hierarchy.md` - Hierarquia de features

**Referências de Código (Design System):**
- `packages/design_system/design_system_shared/lib/src/theme/ds_theme_config.dart` - Configuração de tema
- `packages/design_system/design_system_ui/lib/theme/ds_theme.dart` - Provedor de tema Flutter
- `packages/design_system/design_system_shared/lib/src/colors/color_value.dart` - Padrão de objeto de valor

**Referências de Código (Core):**
- `packages/core/core_shared/lib/src/result/` - Implementação do Result pattern
- `packages/core/core_shared/lib/src/validators/` - CoreValidator para validação de domínio
- `packages/core/core_ui/lib/core/mixins/form_validation_mixin.dart` - FormValidationMixin para formulários Flutter
- `packages/core/core_client/lib/src/repositories/` - Base repositories

**Aplicações de Demonstração:**
- `apps/ems/app_design_draft/lib/main.dart` - Demo de troca dinâmica de tema
- `apps/ems/app_v1/` - App EMS em produção
- `apps/sms/app_v1/` - App SMS em produção

**Configuração de Workspace:**
- `pubspec.yaml` (root) - Define todos os pacotes membros do workspace
  - **Nota:** Alguns pacotes estão comentados (não ativos no workspace)
  - Veja o arquivo para detalhes sobre quais variantes estão ativas

## Architecture Decision Records (ADRs)

O projeto mantém registros de decisões arquiteturais importantes em `docs/adr/`. Estes documentos explicam o contexto, decisões e consequências de padrões adotados:

1. **ADR-0001: Result Pattern** (`docs/adr/0001-result-pattern.md`)
   - Pattern para tratamento de erros sem exceções
   - Implementação em `packages/core/core_shared/lib/src/result/`
   - Use `Result<T, E>` ao invés de `throw` em lógica de negócio

2. **ADR-0002: Dio Error Handler Mixin** (`docs/adr/0002-dio-error-handler.md`)
   - Mixin para tratamento consistente de erros HTTP
   - Converte exceções Dio em objetos Result

3. **ADR-0003: Base Repository Pattern** (`docs/adr/0003-base-repository.md`)
   - Padrão base para todos os repositórios
   - Implementação em `packages/core/core_client/lib/src/repositories/`
   - Todos os novos repositórios devem estender `BaseRepository`

4. **ADR-0004: Validação de Formulários - FormValidationMixin e Zard** (`docs/adr/0004-use-form-validation-mixin-and-zard.md`)
   - Padrão Dual Interface: CoreValidator (backend) + FormValidationMixin (UI)
   - Isolamento completo do Zard em camada de abstração
   - Schema compartilhado em `*_shared` serve UI e backend
   - Implementação em `packages/core/core_ui/lib/core/mixins/form_validation_mixin.dart`
   - Use FormValidationMixin para todos os formulários Flutter

5. **ADR-0005: Estrutura Padrão de Pacotes** (`docs/adr/0005-package-structure.md`)
   - Define o padrão de 4 variantes (_shared, _ui, _client, _server)
   - Regras de dependências entre variantes
   - **Leia antes de criar novos pacotes**

6. **ADR-0006: Base Details Sync** (`docs/adr/0006-base-details-sync.md`)
   - Padrão de sincronização entre listagens e detalhes
   - Evita inconsistências de estado

**Ao tomar decisões arquiteturais significativas**, considere criar um novo ADR seguindo o formato existente.

## Documentação Adicional

Para informações mais detalhadas sobre:
- **Arquitetura completa**: Consulte `ARCHITECTURE.md` (documentação de 37.5 KB em português)
- **Padrões de código**: Consulte ADRs em `docs/adr/` (listados acima)
- **Infraestrutura Docker**: Consulte `servers/INFRASTRUCTURE.md`
- **Propostas e especificações**: Consulte `openspec/AGENTS.md`
- **Regras de features**: Consulte `docs/rules/new_feature.md`
- **Padrões de entidades**: Consulte `docs/architecture/entity_patterns.md`
- **Hierarquia de features**: Consulte `docs/architecture/features_hierarchy.md`
