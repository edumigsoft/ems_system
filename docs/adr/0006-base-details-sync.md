# 6. Sincronização BaseDetails ↔ DriftTableMixin

Data: 2025-12-31

## Status

Proposto

## Contexto

O sistema utiliza dois contratos relacionados em diferentes camadas:

1. **`DriftTableMixinPostgres`** (`core_server`) - Define campos base para todas as tabelas Drift
2. **`BaseDetails`** (`core_shared`) - Interface que todas as `*Details` implementam

Esses dois artefatos devem estar **sempre sincronizados**. Qualquer mudança nos campos do `DriftTableMixinPostgres` (adicionar, remover ou renomear) DEVE ser refletida em `BaseDetails`, caso contrário:

- Compilação pode falhar silenciosamente
- Tabelas Drift não mapeiam corretamente para `*Details`
- Erros de runtime ao deserializar dados do banco

### Problema Exemplo

```dart
// ❌ RISCO: Dessincronização

// core_server (FONTE DA VERDADE)
mixin DriftTableMixinPostgres {
  TextColumn get id = text()...;
  DateTimeColumn get createdAt = dateTime()...;
  DateTimeColumn get updatedAt = dateTime()...;
  BoolColumn get isDeleted = boolean()...;
  BoolColumn get isActive = boolean()...;
  IntColumn get version = integer()...;  // 🚨 Novo campo adicionado!
}

// core_shared (DESATUALIZADO)
abstract class BaseDetails {
  String get id;
  DateTime get createdAt;
  DateTime get updatedAt;
  bool get isDeleted;
  bool get isActive;
  // 🚨 Falta 'version'!
}
```

## Decisão

Adotamos as seguintes estratégias para garantir sincronização:

### 1. Fonte da Verdade

**`DriftTableMixinPostgres` é a fonte autoritativa.**

Qualquer mudança de campos base deve começar no mixin Drift em `core_server`, e então ser propagada para `BaseDetails` em `core_shared`.

### 2. Geração de Código (Fase 1 - Imediata)

Criar script Dart que gera `BaseDetails` automaticamente a partir do `DriftTableMixinPostgres`.

**Ferramenta:** `tools/generate_base_details.dart`

```dart
// tools/generate_base_details.dart
import 'dart:io';

void main() {
  final mixin = File('packages/core/core_server/lib/src/database/drift/drift_table_mixin.dart')
      .readAsStringSync();
  
  // Parse campos do mixin
  final fields = <String, String>{
    'id': 'String',
    'created_at': 'DateTime',
    'updated_at': 'DateTime',
    'is_deleted': 'bool',
    'is_active': 'bool',
  };
  
  // Gera BaseDetails
  final output = '''
// GENERATED CODE - DO NOT MODIFY BY HAND
// Generated from DriftTableMixinPostgres

abstract class BaseDetails {
${fields.entries.map((e) => '  ${e.value} get ${e.key};').join('\n')}
}
''';
  
  File('packages/core/core_shared/lib/src/commons/base_details.dart')
      .writeAsStringSync(output);
  
  print('✅ BaseDetails gerado com sucesso!');
}
```

**Uso:**
```bash
# Após alterar DriftTableMixinPostgres:
dart run tools/generate_base_details.dart
```

### 3. Validação CI/CD

Script de validação que falha o CI se `BaseDetails` e `DriftTableMixinPostgres` estiverem dessincronizados.

**Ferramenta:** `scripts/validate_base_details_sync.sh`

```bash
#!/bin/bash
# scripts/validate_base_details_sync.sh

echo "🔍 Validando sincronização BaseDetails ↔ DriftTableMixin..."

# Extrai campos do mixin
MIXIN_FIELDS=$(grep -E "^\s+(late final|.*Column get)" \
  packages/core/core_server/lib/src/database/drift/drift_table_mixin.dart \
  | sed 's/.*get \([a-zA-Z]*\).*/\1/' | sort)

# Extrai campos do BaseDetails
DETAILS_FIELDS=$(grep -E "^\s+.*get" \
  packages/core/core_shared/lib/src/commons/base_details.dart \
  | sed 's/.*get \([a-zA-Z]*\).*/\1/' | sort)

# Compara
DIFF=$(diff <(echo "$MIXIN_FIELDS") <(echo "$DETAILS_FIELDS"))

if [ -n "$DIFF" ]; then
  echo "❌ ERRO: BaseDetails está dessincronizado com DriftTableMixin!"
  echo ""
  echo "Diferenças encontradas:"
  echo "$DIFF"
  echo ""
  echo "Por favor, execute: dart run tools/generate_base_details.dart"
  exit 1
else
  echo "✅ BaseDetails está sincronizado!"
fi
```

**Integração no CI:**
```yaml
# .github/workflows/ci.yml
- name: Validate BaseDetails Sync
  run: ./scripts/validate_base_details_sync.sh
```

### 4. Proibição de Edição Manual

`BaseDetails` **NÃO deve ser editado manualmente**. Qualquer mudança necessária deve:

1. Ser feita em `DriftTableMixinPostgres`
2. Executar `dart run tools/generate_base_details.dart`
3. Commit incluir ambos os arquivos

### 5. Geração Avançada (Fase 2 - Futuro)

Criar package `core_generators` com custom builder para `build_runner`:

```dart
// core_generators/lib/src/base_details_generator.dart
class BaseDetailsGenerator extends Generator {
  @override
  Future<String> generate(LibraryReader library, BuildStep buildStep) async {
    // Parse DriftTableMixinPostgres
    // Gera BaseDetails sincronizado
  }
}
```

**Configuração:**
```yaml
# build.yaml
builders:
  base_details:
    import: "package:core_generators/builders.dart"
    builder_factories: ["baseDetailsBuilder"]
    build_extensions: {".dart": [".base_details.g.dart"]}
    auto_apply: dependents
```

**Uso:**
```bash
# Regenera automaticamente ao rodar:
dart run build_runner build
```

## Consequências

### Positivas

- ✅ **Impossível dessincronização**: Script garante que os dois sempre coincidem
- ✅ **Mudanças automáticas**: Alteração no mixin reflete automaticamente em BaseDetails
- ✅ **Erros capturados no CI**: Impossível fazer merge de código dessincronizado
- ✅ **Fonte única da verdade**: Clareza sobre qual arquivo é autoritativo
- ✅ **Menos erros humanos**: Eliminação de edição manual propensa a erros

### Negativas

- ❌ **Passo extra**: Developers precisam executar script após mudanças no mixin
- ❌ **Curva de aprendizado**: Novo workflow que equipe precisa aprender
- ❌ **Complexidade inicial**: Setup de ferramentas e CI

### Mitigação de Negativas

- Documentar claramente o processo em `CONTRIBUTING.md`
- Adicionar hook pre-commit que executa o script automaticamente
- Mensagens de erro claras quando validação falha
- Documentação visual (diagramas) do workflow

## Alternativas Consideradas

### Alternativa 1: Edição Manual Cuidadosa

**Rejeitada:** Propensa a erros humanos, sem garantia de sincronização.

### Alternativa 2: Herança ao invés de Interface

Fazer `BaseDetails` ser uma classe concreta que `*Details` herda.

**Rejeitada:** 
- Dart não suporta herança múltipla
- Prejudicaria composição com `Entity`
- Menos flexibilidade arquitetural

### Alternativa 3: Usar Apenas DriftTableMixin

Eliminar `BaseDetails` e usar apenas `DriftTableMixinPostgres`.

**Rejeitada:**
- Violaria Clean Architecture (core_shared não pode depender de Drift)
- Acoplamento de domínio com infraestrutura

## Implementação

### Fase 1 (Imediata)
- [x] Criar `tools/generate_base_details.dart`
- [ ] Criar `scripts/validate_base_details_sync.sh`
- [ ] Executar gerador inicial
- [ ] Integrar validação no CI
- [ ] Documentar processo em `CONTRIBUTING.md`

### Fase 2 (Futuro)
- [ ] Criar package `core_generators`
- [ ] Implementar `BaseDetailsGenerator` para build_runner
- [ ] Configurar `build.yaml`
- [ ] Migrar do script manual para geração automática

## Referências

- [ADR-0005: Standard Package Structure](./0005-standard-package-structure.md)
- [Padrões Arquiteturais](../architecture/architecture_patterns.md)
- [Padrões de Entities](../rules/entity_patterns.md)
- `packages/core/core_server/lib/src/database/drift/drift_table_mixin.dart`
- `packages/core/core_shared/lib/src/commons/base_details.dart`
