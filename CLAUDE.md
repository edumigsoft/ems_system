# CLAUDE.md

Este arquivo fornece orientações para o Claude Code (claude.ai/code) ao trabalhar com código neste repositório.

## Visão Geral do Projeto

EMS System (EduMigSoft System) é um monorepo Flutter/Dart para gerenciar usuários, tarefas (Aura), projetos e finanças. A arquitetura usa uma estrutura de pacotes multi-variante consistente que permite compartilhamento de código entre aplicativos Flutter e servidores backend Dart/Shelf.

## Comandos Comuns

### Gerenciamento de Pacotes

```bash
# Instalar dependências para todos os pacotes
./scripts/pub_get_all.sh

# Limpar todos os pacotes (remove .dart_tool, artefatos de build)
./scripts/clean_all.sh

# Executar build_runner em todos os pacotes que o usam
./scripts/build_runner_all.sh

# Aplicar dart fix em todos os pacotes
./scripts/dart_fix_all.sh
```

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

### Executando o App de Demonstração

```bash
cd apps/app_design_draft
flutter pub get
flutter run
```

## Arquitetura de Alto Nível

### Padrão de Pacotes Multi-Variante

O monorepo usa uma **estrutura de pacotes com 4 variantes** onde cada pacote é dividido em camadas específicas de plataforma:

```
packages/{package_name}/
├── {package}_shared/    # Dart puro, zero dependências Flutter
├── {package}_ui/        # Widgets Flutter e componentes de UI
├── {package}_client/    # Lógica do lado do cliente (atualmente mínima)
└── {package}_server/    # Lógica do lado do servidor para backend Dart/Shelf
```

**Princípios Arquiteturais Principais:**

1. **Camada Compartilhada é Dart Puro**: Pacotes `*_shared` contêm ZERO dependências Flutter. Eles usam apenas `meta: ^1.17.0` e definem modelos de domínio, objetos de valor e configuração como Plain Old Dart Objects (PODOs).

2. **Direção de Dependências (Em Camadas)**:
   ```
   *_ui     → *_shared
   *_client → *_shared
   *_server → *_shared
   ```
   Sem dependências horizontais entre variantes.

3. **Configuração como Dados**: Conceitos de domínio como temas são representados como classes de dados serializáveis (não singletons), permitindo:
   - Transmissão via API entre backend e frontend
   - Persistência em bancos de dados ou armazenamento local
   - Padrões de UI dirigida por servidor
   - Configuração dinâmica sem alterações de código

### Arquitetura do Design System

O pacote `design_system` demonstra a implementação madura deste padrão:

**design_system_shared** (Dart Puro):
- `ColorValue`: Objeto de valor de cor agnóstico a framework (ARGB int32)
  - Suporta `fromHex()`, `fromARGB()`, `toHex()`, `toCSSRGBA()`
  - Serializável via `toMap()` / `fromMap()`

- `DSThemeConfig`: Classe de dados de configuração de tema imutável
  - Contém `seedColor`, `cardBackground`, `cardBorder`, configurações de tipografia
  - Suporta padrão `copyWith()` para variações
  - Pode ser enviado via API ou persistido

- Presets de Tema: Configurações estáticas (`DefaultPreset`, `BlueGrayPreset`, `AcquaPreset`, `LoloPreset`, `TealPreset`)

- Design Tokens: Constantes para espaçamento, raio, paddings, sombras
  ```dart
  DSSpacing.xs, DSSpacing.small, DSSpacing.medium
  DSRadius.small, DSRadius.medium, DSRadius.large
  DSPaddings.extraSmall, DSPaddings.medium
  ```

**design_system_ui** (Flutter):
- `DSTheme`: Converte `DSThemeConfig` para `ThemeData` do Material 3
  - `DSTheme.fromConfig(config, brightness)` → `ThemeData`
  - `DSTheme.forPreset(DSThemeEnum.lolo, brightness)` → `ThemeData`

- Extensões:
  - `ColorValue.toColor()` ↔ `Color.toColorValue()`
  - `context.dsTheme`, `context.dsColors`, `context.dsTextStyles`

- Componentes: `DSCard`, `DSInfoCard`, `DSActionCard`

**Exemplo de Fluxo de Dados**:
```
Backend (design_system_server)
  → Gera DSThemeConfig
  → Envia via API como JSON

App Flutter (design_system_ui)
  → Recebe JSON
  → Deserializa para DSThemeConfig (fromMap)
  → Converte para ThemeData via DSTheme.fromConfig()
  → Renderiza UI com tema
```

### Opções de Análise

O projeto usa duas configurações de análise:

- **`analysis_options_dart.yaml`**: Para pacotes Dart puro (`*_shared`, `*_client`, `*_server`)
  - Usa `package:lints/recommended.yaml`
  - Aplica tipagem estrita: `strict-casts`, `strict-inference`, `strict-raw-types`
  - Regras específicas de servidor/API: `avoid_dynamic_calls`, `cancel_subscriptions`, `close_sinks`

- **`analysis_options_flutter.yaml`**: Para pacotes Flutter (`*_ui`, apps)
  - Usa `package:flutter_lints/flutter.yaml`
  - Regras específicas do Flutter: `use_key_in_widget_constructors`, `avoid_unnecessary_containers`
  - Regras de performance: `prefer_const_constructors_in_immutables`

Ambos excluem arquivos gerados: `**/*.g.dart`, `**/*.freezed.dart`, `**/*.mocks.dart`

## Organização de Pacotes

**Pacotes Ativos:**
- `design_system/` - Design system com configurações de tema, valores de cor, constantes e componentes de UI
- `localizations/` - i18n com definições de strings agnósticas à plataforma e implementações Flutter/servidor

**Pacotes Esqueleto (prontos para implementação):**
- `core/` - Funcionalidade central compartilhada
- `images/` - Ativos de imagem e gerenciamento
- `open_api/` - Geração de código cliente/servidor de API

**Apps:**
- `apps/app_design_draft/` - App Flutter de demonstração mostrando o design system com troca dinâmica de tema

## Diretrizes de Desenvolvimento

### Adicionando Novos Pacotes

Siga o padrão de 4 variantes:

1. Criar estrutura de diretórios do pacote:
   ```
   packages/{feature}/
   ├── {feature}_shared/    # Apenas Dart puro
   ├── {feature}_ui/        # Widgets Flutter
   ├── {feature}_client/    # Lógica do cliente
   └── {feature}_server/    # Lógica do servidor
   ```

2. **Em `*_shared`**: Use apenas dependência `meta`. Defina:
   - Modelos de domínio como classes de dados imutáveis
   - Objetos de valor com serialização (`toMap`/`fromMap`)
   - Interfaces abstratas
   - Constantes e enums

3. **Em `*_ui`**: Dependa de `{feature}_shared`. Adicione:
   - Widgets Flutter
   - Extensões de tema
   - Lógica específica de UI

4. **Em `*_client`/`*_server`**: Dependa de `{feature}_shared` para implementações específicas de plataforma.

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

### Padrão de Objeto de Valor

Ao criar conceitos de domínio (cores, moedas, etc.), siga o padrão `ColorValue`:

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

## Estrutura do Projeto

```
ems_system/
├── apps/                    # Aplicações Flutter
│   └── app_design_draft/   # App de demonstração do design system
├── servers/                 # Servidores backend Dart/Shelf (planejado)
├── packages/               # Pacotes compartilhados
│   ├── core/              # Funcionalidade central (esqueleto)
│   ├── design_system/     # Design system (ativo)
│   ├── images/            # Ativos de imagem (esqueleto)
│   ├── localizations/     # i18n (ativo)
│   └── open_api/          # Definições de API (esqueleto)
├── scripts/               # Scripts de automação de desenvolvimento
├── docs/                  # Documentação
├── analysis_options_dart.yaml     # Linting para Dart puro
├── analysis_options_flutter.yaml  # Linting para Flutter
└── CONTRIBUTING.md        # Diretrizes de contribuição
```

## Arquivos Importantes

**Referência de Arquitetura:**
- `packages/design_system/design_system_shared/lib/src/theme/ds_theme_config.dart` - Modelo de configuração de tema
- `packages/design_system/design_system_ui/lib/theme/ds_theme.dart` - Provedor de tema Flutter
- `packages/design_system/design_system_shared/lib/src/colors/color_value.dart` - Padrão de objeto de valor

**Integração de Demonstração:**
- `apps/app_design_draft/lib/main.dart` - Implementação de troca de tema

<!-- OPENSPEC:START -->
# Instruções OpenSpec

Estas instruções são para assistentes de IA trabalhando neste projeto.

Sempre abra `@/openspec/AGENTS.md` quando a solicitação:
- Mencionar planejamento ou propostas (palavras como proposta, especificação, mudança, plano)
- Introduzir novas capacidades, mudanças disruptivas, mudanças arquiteturais ou grande trabalho de performance/segurança
- Parecer ambígua e você precisar da especificação autoritativa antes de codificar

Use `@/openspec/AGENTS.md` para aprender:
- Como criar e aplicar propostas de mudança
- Formato e convenções de especificação
- Estrutura e diretrizes do projeto

Mantenha este bloco gerenciado para que 'openspec update' possa atualizar as instruções.

<!-- OPENSPEC:END -->