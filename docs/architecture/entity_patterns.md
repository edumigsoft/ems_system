# Padrões de Entities

## Visão Geral

> [!NOTE]
> **Guia Prático de Implementação**
> 
> Este é um guia **prático e tático** ("como fazer") que implementa os conceitos arquiteturais definidos em [architecture_patterns.md](./architecture_patterns.md).
> 
> - Use este documento ao **implementar** features no dia a dia
> - Consulte `architecture_patterns.md` para entender as **decisões arquiteturais** e princípios

Este documento define as **regras práticas** para criação de entidades no EMS System, com exemplos de código, erros comuns e checklists.

---

## Regras Fundamentais

### 1. Entity - Domínio Puro

> [!IMPORTANT]
> **Entity NÃO tem `id`**
> 
> Entidades de domínio são 100% puras e representam apenas conceitos de negócio. O `id` é um detalhe de persistência e não deve fazer parte da Entity.

#### ✅ Correto

```dart
class Finance {
  final String name;
  final String code;

  Finance({
    required this.name,
    required this.code,
  });

  // Lógica de domínio
  bool get isValidCode => code.length >= 3 && code.length <= 10;
  String get displayName => '$code - $name';
}
```

#### ❌ Incorreto

```dart
class Finance {
  final String? id;        // ❌ Entity não deve ter id
  final String name;
  final String code;

  Map<String, dynamic> toJson() { ... }  // ❌ Sem serialização
}
```

**Características de Entity:**
- ✅ Apenas campos essenciais ao negócio
- ✅ Lógica de domínio (getters, métodos)
- ✅ `operator ==` e `hashCode` baseados em valor
- ❌ SEM `id`
- ❌ SEM `toJson`/`fromJson`
- ❌ SEM dependências externas

---

### 2. EntityDetails - Agregação Completa

> [!IMPORTANT]
> **Details implementa `BaseDetails`**
> 
> `EntityDetails` sempre implementa `BaseDetails` e contém TODOS os campos do `DriftTableMixinPostgres`, incluindo `createdAt` e `updatedAt` como **non-nullable**.

#### ✅ Correto

```dart
import 'package:core_shared/core_shared.dart';
import 'finance.dart';

class FinanceDetails implements BaseDetails {
  @override
  final String id;
  @override
  final bool isDeleted;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;   // ✅ Non-nullable
  @override
  final DateTime updatedAt;   // ✅ Non-nullable

  final Finance data;

  FinanceDetails({
    required this.id,
    this.isDeleted = false,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
    required String name,
    required String code,
  }) : data = Finance(name: name, code: code);

  // Getters de conveniência
  String get name => data.name;
  String get code => data.code;
}
```

#### ❌ Incorreto

```dart
class FinanceDetails {
  final String id;
  final DateTime? createdAt;  // ❌ Deve ser non-nullable
  final DateTime? updatedAt;  // ❌ Deve ser non-nullable
  
  // ❌ Não implementa BaseDetails
  // ❌ Falta campos deleted e isActive
}
```

**Características de EntityDetails:**
- ✅ Implementa `BaseDetails`
- ✅ `createdAt` e `updatedAt` são `DateTime` (não `DateTime?`)
- ✅ Compõe a Entity (campo `data`)
- ✅ Getters de conveniência para campos da Entity
- ❌ SEM serialização (responsabilidade de `*Model`)

---

### 3. DTOs - Create e Update

#### EntityCreate - DTO de Criação

> [!NOTE]
> **Create sem `id` e sem metadados**
> 
> DTOs de criação contêm apenas os campos necessários para criar uma nova entidade. O `id` é gerado pelo banco e metadados são automáticos.

##### ✅ Correto

```dart
class FinanceCreate {
  final String name;
  final String code;

  FinanceCreate({
    required this.name,
    required this.code,
  });

  bool get isValid => name.isNotEmpty && code.length >= 3;
}
```

##### ❌ Incorreto

```dart
class FinanceCreate {
  final String? id;              // ❌ Sem id (gerado pelo DB)
  final DateTime? createdAt;     // ❌ Sem metadados
  final String name;
  final String code;
  
  Map<String, dynamic> toJson() { ... }  // ❌ Sem serialização
}
```

---

#### EntityUpdate - DTO de Atualização

> [!NOTE]
> **Update com `id` required e campos opcionais**
> 
> DTOs de atualização sempre incluem `id` (obrigatório) e campos opcionais para atualização parcial. **DEVEM** incluir `isActive` e `isDeleted` para controle.

##### ✅ Correto

```dart
class FinanceUpdate {
  final String id;          // ✅ Obrigatório
  final String? name;       // ✅ Opcional
  final String? code;       // ✅ Opcional
  final bool? isActive;     // ✅ Incluir para ativação/desativação
  final bool? isDeleted;    // ✅ Incluir para soft delete

  FinanceUpdate({
    required this.id,
    this.name,
    this.code,
    this.isActive,
    this.isDeleted,
  });

  bool get hasChanges => 
    name != null || 
    code != null || 
    isActive != null || 
    isDeleted != null;
}
```

##### ❌ Incorreto

```dart
class FinanceUpdate {
  final String? id;              // ❌ id deve ser required
  final String name;             // ❌ Campos devem ser opcionais
  final DateTime? createdAt;     // ❌ createdAt é imutável
  final DateTime? updatedAt;     // ❌ updatedAt é auto-gerenciado
  // ❌ Falta isActive e deleted
}
```

**Campos de BaseDetails em Update:**

| Campo | Incluir? | Motivo |
|-------|----------|--------|
| `id` | ✅ **SIM** (required) | Identifica qual registro atualizar |
| `isActive`  | ✅ **SIM** (optional) | Permite ativar/desativar |
| `isDeleted` | ✅ **SIM** (optional) | Permite soft delete |
| `createdAt` | ❌ **NÃO** | Imutável - nunca muda |
| `updatedAt` | ❌ **NÃO** | Auto-atualizado pelo banco |

---

### 4. Models - Serialização

> [!NOTE]
> **Models isolam serialização**
> 
> Classes `*Model` são responsáveis exclusivas por serialização/deserialização JSON. Contêm as entidades/DTOs como campos e fornecem métodos `fromJson`, `toJson`, `toDomain` e `fromDomain`.

#### ✅ Correto

```dart
class FinanceDetailsModel {
  final FinanceDetails entity;

  FinanceDetailsModel(this.entity);

  factory FinanceDetailsModel.fromJson(Map<String, dynamic> json) {
    return FinanceDetailsModel(
      FinanceDetails(
        id: json['id'] as String,
        isDeleted: json['is_deleted'] as bool? ?? false,
        isActive: json['is_active'] as bool? ?? true,
        createdAt: DateTime.parse(json['created_at'] as String),
        updatedAt: DateTime.parse(json['updated_at'] as String),
        name: json['name'] as String,
        code: json['code'] as String,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': entity.id,
    'is_deleted': entity.isDeleted,
    'is_active': entity.isActive,
    'created_at': entity.createdAt.toIso8601String(),
    'updated_at': entity.updatedAt.toIso8601String(),
    'name': entity.name,
    'code': entity.code,
  };

  FinanceDetails toDomain() => entity;
  
  factory FinanceDetailsModel.fromDomain(FinanceDetails details) =>
      FinanceDetailsModel(details);
}
```

#### ❌ Incorreto

```dart
// ❌ Serialização na própria Entity
class FinanceDetails {
  final String id;
  final String name;
  
  Map<String, dynamic> toJson() { ... }  // ❌ Violação de Clean Architecture
  factory FinanceDetails.fromJson(...) { ... }
}
```

---

## Erros Comuns e Soluções

### Erro 1: Entity com `id`

❌ **Erro:**
```dart
class User {
  final String? id;  // ❌
  final String name;
}
```

✅ **Solução:**
```dart
// Entity pura
class User {
  final String name;
}

// Details com id
class UserDetails implements BaseDetails {
  @override
  final String id;
  final User data;
}
```

---

### Erro 2: `createdAt`/`updatedAt` nullable

❌ **Erro:**
```dart
class FinanceDetails implements BaseDetails {
  final DateTime? createdAt;  // ❌
  final DateTime? updatedAt;  // ❌
}
```

✅ **Solução:**
```dart
class FinanceDetails implements BaseDetails {
  @override
  final DateTime createdAt;   // ✅ Non-nullable
  @override
  final DateTime updatedAt;   // ✅ Non-nullable
  
  FinanceDetails({
    required this.createdAt,
    required this.updatedAt,
    // ...
  });
}
```

**Razão:** O `DriftTableMixinPostgres` define esses campos com `withDefault(CURRENT_TIMESTAMP)`, então sempre terão valor.

---

### Erro 3: Update sem campo `deleted`

❌ **Erro:**
```dart
class UserUpdate {
  final String id;
  final String? name;
  final bool? isActive;
  // ❌ Falta deleted
}
```

✅ **Solução:**
```dart
class UserUpdate {
  final String id;
  final String? name;
  final bool? isActive;
  final bool? isDeleted;  // ✅ Permite soft delete
}
```

**Padrões de soft delete:**
```dart
// Via Update
await repository.update(UserUpdate(id: userId, isDeleted: true));

// Ou método dedicado (mais semântico)
await repository.softDelete(userId);
await repository.restore(userId);
```

---

### Erro 4: Serialização em Entity/Details

❌ **Erro:**
```dart
class Finance {
  final String name;
  final String code;
  
  Map<String, dynamic> toJson() => {...};  // ❌ Violação
}
```

✅ **Solução:**
```dart
// Entity pura (sem serialização)
class Finance {
  final String name;
  final String code;
}

// Model para serialização
class FinanceDetailsModel {
  final FinanceDetails entity;
  
  Map<String, dynamic> toJson() => {...};  // ✅
  factory FinanceDetailsModel.fromJson(...) => {...};
}
```

---

### Erro 5: Details sem implementar BaseDetails

❌ **Erro:**
```dart
class FinanceDetails {  // ❌ Não implementa BaseDetails
  final String id;
  final String name;
}
```

✅ **Solução:**
```dart
class FinanceDetails implements BaseDetails {  // ✅
  @override
  final String id;
  @override
  final bool isDeleted;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;
  @override
  final DateTime updatedAt;
  
  final Finance data;
}
```

---

## Checklist para Nova Entity

Ao criar uma nova entidade, verifique:

### Entity
- [ ] Nome claro e descritivo (ex: `Finance`, não `FinanceEntity`)
- [ ] Apenas campos de negócio
- [ ] SEM `id`
- [ ] SEM `toJson`/`fromJson`
- [ ] Implementa `operator ==` e `hashCode`
- [ ] Lógica de domínio como getters/métodos

### EntityDetails
- [ ] Implementa `BaseDetails`
- [ ] `createdAt` e `updatedAt` são `DateTime` (non-nullable)
- [ ] Compõe a Entity (campo `data`)
- [ ] Getters de conveniência para campos da Entity
- [ ] SEM serialização

### EntityCreate
- [ ] Apenas campos necessários para criação
- [ ] SEM `id`
- [ ] SEM metadados (`createdAt`, `updatedAt`, etc.)
- [ ] Validação de negócio (getter `isValid`)

### EntityUpdate
- [ ] Campo `id` obrigatório
- [ ] Todos os outros campos opcionais
- [ ] Inclui `isActive` e `isDeleted`
- [ ] NÃO inclui `createdAt` ou `updatedAt`
- [ ] Getter `hasChanges`

### Models
- [ ] `*DetailsModel` para Details
- [ ] `*CreateModel` para Create
- [ ] `*UpdateModel` para Update
- [ ] Métodos `fromJson`, `toJson`, `toDomain`, `fromDomain`
- [ ] Nenhuma lógica de negócio

---

## Exemplos Completos

Ver exemplos completos em:
- [architecture_patterns.md](../architecture/architecture_patterns.md)
- [new_feature.md](./new_feature.md)

---

## Referências

- [Padrões Arquiteturais](../architecture/architecture_patterns.md)
- [ADR-0005: Standard Package Structure](../adr/0005-standard-package-structure.md)
- [ADR-0006: Sincronização BaseDetails](../adr/0006-base-details-sync.md)
- [Guia de Criação de Features](./new_feature.md)
