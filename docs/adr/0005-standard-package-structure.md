# 5. Estrutura Padrão de Pacotes

Date: 2025-12-07  
Updated: 2025-12-31

## Status

Aceito

## Contexto

A falta de padronização na estrutura de diretórios dos pacotes dificulta a navegação e o entendimento do projeto por diferentes desenvolvedores. 

Com o crescimento do projeto e a adoção de princípios de **Clean Architecture** e **Domain-Driven Design (DDD)**, precisamos de uma estrutura mais robusta que:
- Separe claramente as responsabilidades (domain/data)
- Suporte casos de uso complexos
- Facilite testes isolados
- Permita crescimento sem refatorações grandes
- Seja compatível com as melhores práticas Dart/Flutter de 2024

## Decisão

Adotar uma estrutura de diretórios **híbrida feature-first com DDD** para pacotes Dart puros e pacotes Flutter UI, com suporte a variações documentadas.

### Estrutura para Pacotes Core (Dart Puro - Domain/Data)

```
lib/
  src/
    domain/              # Camada de domínio (core business logic)
      entities/          # Objetos de domínio com identidade
      repositories/      # Interfaces/contratos de repositórios
      use_cases/         # Casos de uso/regras de negócio
      value_objects/     # Objetos de valor imutáveis (opcional)
    data/                # Camada de dados (implementações)
      models/            # DTOs e modelos de dados
      repositories/      # Implementações concretas dos repositórios
      services/          # Serviços de dados
      data_sources/      # Fontes de dados (API, cache, etc)
    validators/          # Validações de domínio (Zard schemas)
    constants/           # Constantes de domínio
    extensions/          # Extensions específicas do domínio
    enums/              # Enumerações
```

### Estrutura para Pacotes Client (HTTP)

```
lib/
  src/
    repositories/        # Repositórios locais (HTTP via Dio/Retrofit)
    services/           # Serviços cliente
    api/                # Modelos e interfaces API (opcional)
```

### Estrutura para Pacotes UI (Flutter)

```
lib/
  ui/
    pages/              # Páginas/Telas
    view_models/        # ViewModels (MVVM pattern)
    widgets/            # Widgets reutilizáveis específicos da feature
    utils/              # Utilitários UI-specific (opcional)
```

### Estrutura Obrigatória para Pacotes Core

**TODOS** os pacotes core devem seguir a estrutura Domain/Data Separados:

```
lib/src/
  domain/              # Camada de domínio (regras de negócio)
    entities/
    repositories/      # Interfaces/contratos
    use_cases/
  data/                # Camada de dados (implementações)
    models/
    repositories/      # Implementações concretas
  validators/
  constants/
  extensions/
  enums/
```

> [!IMPORTANT]
> **Padrão Obrigatório**
> 
> Esta estrutura é **obrigatória** para todos os pacotes core, sem exceções. Pacotes existentes que não seguem este padrão devem ser refatorados.
> 
> **Justificativa:**
> - Separação clara entre Domain (regras de negócio) e Data (implementações)
> - Facilita crescimento futuro sem refatorações
> - Consistência em todo o monorepo
> - Suporte explícito a Clean Architecture

**Exemplos**: `auth_core`, `aura_core`, `user_core`, `project_core`

## Princípios Arquiteturais

Esta estrutura segue os princípios de:

1. **Clean Architecture**: Separação clara entre domain (regras de negócio) e data (detalhes de implementação)
2. **Domain-Driven Design**: Entidades, value objects e use cases refletem o domínio do negócio
3. **Dependency Rule**: Domain não depende de Data. Dependências apontam sempre para dentro
4. **Single Responsibility**: Cada pasta tem um propósito claro e único

## Features vs Sub-Features

O projeto suporta **dois padrões** de organização de features:

### Feature Simples

Estrutura direta com 4 pacotes no mesmo nível:

```
packages/auth/
├── README.md
├── CONTRIBUTING.md
├── CHANGELOG.md
├── auth_core/
├── auth_client/
├── auth_server/
└── auth_ui/
```

**Quando usar:**
- Feature coesa com domínio único
- Até ~10 entidades relacionadas
- Não há necessidade de versionamento independente de sub-domínios

**Exemplos:** `user`, `auth`

### Feature com Sub-Features

Estrutura hierárquica com domínio pai contendo múltiplas sub-features:

```
packages/project/                     # Domínio pai
├── README.md                         # Visão geral de TODAS as sub-features
├── CONTRIBUTING.md                   # ÚNICO para todo o domínio
├── CHANGELOG.md                      # Reúne as mudanças de todas as sub-features
├── projects/                     # Sub-feature 1
│   ├── README.md
│   ├── CHANGELOG.md
│   ├── projects_core/
│   ├── projects_client/
│   ├── projects_server/
│   └── projects_ui/
│
└── projects_task/                    # Sub-feature 2
    ├── README.md
    ├── CHANGELOG.md
    ├── projects_task_core/
    ├── projects_task_client/
    ├── projects_task_server/
    └── projects_task_ui/
```

**Quando usar:**
- Domínio amplo com sub-domínios relacionados mas distintos
- Mais de ~10 entidades ou múltiplas áreas de negócio
- Necessidade de versionamento independente de componentes

**Exemplos:** `project` (com `projects` e `projects_task`)

**Nomenclatura:** `{sub_feature}_{tipo}` (ex: `projects_core`, `projects_ui`)

> [!WARNING]
> **Caminhos Relativos em Sub-Features**
> 
> Sub-features têm profundidade extra, então os caminhos relativos mudam:
> ```yaml
> # Feature simples: packages/auth/auth_core/
> include: ../../../analysis_options_dart.yaml
> 
> # Sub-feature: packages/project/projects/projects_core/
> include: ../../../../analysis_options_dart.yaml  # ⚠️ Um nível a mais!
> ```

Para detalhes completos sobre Features vs Sub-Features, consulte [Hierarquia de Features](../analysis/features_hierarchy.md).


## Exemplos Práticos

### Exemplo 1: Pacote School Core

```
packages/school/
  ├── README.md                       # Visão geral da feature school
  ├── CONTRIBUTING.md                 # Guia de contribuição (Único arquivo)
  └── school_core/
      ├── lib/
      │   └── src/
      │       ├── domain/
      │       │   ├── entities/
      │       │   │   ├── school.dart                    # Entidade de domínio
      │       │   │   └── school_details.dart
      │       │   ├── repositories/
      │       │   │   └── school_repository.dart         # Interface/contrato
      │       │   └── use_cases/
      │       │       ├── create_school_use_case.dart
      │       │       ├── get_schools_use_case.dart
      │       │       ├── update_school_use_case.dart
      │       │       └── delete_school_use_case.dart
      │       ├── data/
      │       │   ├── models/
      │       │   │   └── school_model.dart              # DTO para serialização
      │       │   └── repositories/
      │       │       └── school_repository_impl.dart    # Implementação (se necessário)
      │       ├── validators/
      │       │   └── school_details_validator.dart    # Zard schema
      │       ├── constants/
      │       │   └── school_constants.dart
      │       └── extensions/
      │           └── school_extensions.dart
      ├── school_core.dart                     # Barrel export
      ├── pubspec.yaml
      ├── analysis_options.yaml
      ├── README.md                            # Específico do school_core
      └── CHANGELOG.md                         # Versionamento do core
```

### Exemplo 2: Pacote School Client

```
packages/school/school_client/
  ├── lib/
  │   └── src/
  │       ├── repositories/
  │       │   └── school_repository_client.dart    # Implementação HTTP
  │       └── services/
  │           └── school_api_service.dart          # Retrofit service
  ├── school_client.dart
  ├── pubspec.yaml
  ├── analysis_options.yaml
  ├── README.md                                # Específico do client
  └── CHANGELOG.md                             # Versionamento do client
```

> **Nota**: `CONTRIBUTING.md` NÃO está aqui, está em `packages/school/CONTRIBUTING.md`

### Exemplo 3: Pacote School UI

```
packages/school/school_ui/
  ├── lib/
  │   ├── ui/
  │   │   ├── pages/
  │   │   │   ├── school_page.dart
  │   │   │   └── school_details_page.dart
  │   │   ├── view_models/
  │   │   │   └── school_view_model.dart
  │   │   └── widgets/
  │   │       ├── school_card.dart
  │   │       └── school_list.dart
  │   ├── school_module.dart                   # AppModule
  │   └── school_ui.dart
  ├── pubspec.yaml
  ├── analysis_options.yaml
  ├── README.md                                # Específico do UI
  └── CHANGELOG.md                             # Versionamento do UI
```

## Plano de Migração

Para garantir consistência em todo o monorepo:

1. **Novos pacotes**: DEVEM usar obrigatoriamente a estrutura Domain/Data Separados
2. **Pacotes existentes fora do padrão**: DEVEM ser refatorados para seguir a estrutura obrigatória
   - Refatoração deve ser planejada e executada sistematicamente
   - Priorizar pacotes mais críticos ou com maior atividade de desenvolvimento
   - Criar issues para rastrear refatorações pendentes
3. **Sem exceções**: Não há justificativa para manter estruturas alternativas
   - Consistência é prioridade sobre conveniência temporária
   - Toda a equipe deve seguir o mesmo padrão

> [!WARNING]
> **Estruturas alternativas não são permitidas**
> 
> Pacotes que ainda não seguem este padrão devem ser documentados como **débito técnico** e incluídos no roadmap de refatoração.

## Arquivos de Documentação e Configuração

### Hierarquia de Documentação

Em um monorepo, a documentação deve seguir uma hierarquia clara:

#### Nível 1: Raiz da Feature (`packages/{{feature}}/`)

Arquivos **obrigatórios** na raiz de cada feature (ex: `packages/school/`):

- ✅ **README.md**: Visão geral da feature completa
  - Descrição da feature e seus módulos (_core, _client, _server, _ui)
  - Arquitetura geral da feature
  - Links para README de cada subpacote
  - Como executar testes da feature completa
  
- ✅ **CONTRIBUTING.md**: Guia de contribuição da feature
  - Como contribuir em qualquer pacote desta feature
  - Padrões específicos de código da feature
  - Convenções de commit
  - Como executar testes
  - **Nota**: Este arquivo É ÚNICO por feature, NÃO deve ser duplicado nos subpacotes

- ✅ **CHANGELOG.md**: Histórico agregado da feature
  - Documenta mudanças gerais que afetam múltiplos subpacotes
  - Seguir formato [Keep a Changelog](https://keepachangelog.com/)
  - Linkar para CHANGELOGs específicos dos subpacotes quando relevante

#### Nível 2: Pacotes Individuais (`packages/{{feature}}/{{feature}}_{{type}}/`)

Arquivos **obrigatórios** em cada subpacote (ex: `packages/school/school_core/`):

- ✅ **README.md**: Documentação específica do pacote
  - Objetivo e responsabilidade do pacote
  - Como usar/importar o pacote
  - Exemplos de código (se aplicável)
  - Dependências principais
  - API pública do pacote

- ✅ **CHANGELOG.md**: Histórico de mudanças do pacote
  - Seguir formato [Keep a Changelog](https://keepachangelog.com/)
  - Formato: `## [version] - YYYY-MM-DD`
  - Categorias: Added, Changed, Deprecated, Removed, Fixed, Security
  - Essencial para versionamento independente

- ✅ **pubspec.yaml**: Configuração do pacote Dart
  - Dependências
  - Metadados (name, version, description)
  - Configurações específicas do pacote

- ✅ **analysis_options.yaml**: Configurações de linting ⚠️ **REGRA OBRIGATÓRIA**
  - **Pacotes Dart** (_core, _server, _client): **DEVEM** importar `analysis_options_dart.yaml` da raiz:
    ```yaml
    include: ../../../analysis_options_dart.yaml
    ```
  - **Pacotes Flutter** (_ui): **DEVEM** importar `analysis_options_flutter.yaml` da raiz:
    ```yaml
    include: ../../../analysis_options_flutter.yaml
    ```
  - Podem adicionar customizações específicas do pacote abaixo da importação
  - **Nunca** duplicar regras que já estão nos arquivos da raiz
  - Isso garante consistência de linting em todo o monorepo

### Exemplo de Estrutura Completa

```
packages/school/
  ├── README.md                    # Visão geral da feature school
  ├── CONTRIBUTING.md              # Como contribuir (NÃO duplicar)
  ├── school_core/
  │   ├── README.md                # Específico do core
  │   ├── CHANGELOG.md             # Versões do core
  │   ├── pubspec.yaml
  │   ├── analysis_options.yaml
  │   └── lib/...
  ├── school_client/
  │   ├── README.md                # Específico do client
  │   ├── CHANGELOG.md             # Versões do client
  │   ├── pubspec.yaml
  │   ├── analysis_options.yaml
  │   └── lib/...
  ├── school_server/
  │   ├── README.md
  │   ├── CHANGELOG.md
  │   ├── pubspec.yaml
  │   ├── analysis_options.yaml
  │   └── lib/...
  └── school_ui/
      ├── README.md
      ├── CHANGELOG.md
      ├── pubspec.yaml
      ├── analysis_options.yaml
      └── lib/...
```

### Princípios

1. **Evitar Duplicação**: `CONTRIBUTING.md` existe APENAS no nível da feature
2. **Hierarquia Clara**: README no nível da feature aponta para READMEs dos subpacotes
3. **Versionamento Independente**: Cada subpacote tem seu CHANGELOG
4. **Configuração Por Pacote**: `pubspec.yaml` e `analysis_options.yaml` são específicos de cada subpacote

## Consequências

### Positivas

- ✅ Consistência em todo o monorepo
- ✅ Localização previsível de arquivos
- ✅ Facilita a criação de scripts de automação
- ✅ Suporte explícito a Clean Architecture e DDD
- ✅ Domain layer puro e testável isoladamente
- ✅ Facilita onboarding de novos desenvolvedores
- ✅ Estrutura escalável para crescimento futuro
- ✅ Separação clara facilita code review

### Negativas

- ⚠️ Mais diretórios podem intimidar iniciantes
- ⚠️ Pacotes pequenos podem parecer "over-engineered"
- ⚠️ Necessidade de educar time sobre quando usar cada variação

### Mitigação

- Documentar exemplos práticos (este ADR)
- Criar template/scaffold para novos pacotes
- Revisar estrutura em code reviews
- Permitir variações documentadas para casos simples

## Referências

- [Flutter Architecture Guide](https://docs.flutter.dev/app-architecture)
- [Clean Architecture - Robert C. Martin](https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html)
- [Domain-Driven Design](https://martinfowler.com/bliki/DomainDrivenDesign.html)
- [Padrões Arquiteturais](../analysis/architecture_patterns.md) - Detalhes sobre Entities/Details/DTOs
- [Hierarquia de Features](../analysis/features_hierarchy.md) - Features vs Sub-Features
- [Padrões de Entities](../rules/entity_patterns.md) - Regras práticas
- [ADR-0006: Sincronização BaseDetails](./0006-base-details-sync.md)
- `docs/rules/new_feature.md` - Guia de criação de features
- `docs/rules/flutter_dart_rules.md` - Regras Dart/Flutter

