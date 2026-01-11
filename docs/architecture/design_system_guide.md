# Guia de Uso do Design System

## Visão Geral

O Design System é a **única fonte de verdade** para todos os elementos visuais do projeto. Todos os widgets e componentes devem usar exclusivamente tokens do Design System, nunca valores hardcoded.

> [!CAUTION]
> **Regras Fundamentais - Valores Hardcoded São PROIBIDOS**
> 
> O Design System é a única fonte de verdade. Todos os widgets e componentes devem usar exclusivamente tokens do Design System, nunca valores hardcoded.

### ❌ NUNCA Faça Isso

```dart
// ❌ Valores hardcoded
Text(
  'Título',
  style: TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.bold,
    color: Colors.blue,
  ),
)

// ❌ Spacing hardcoded
Padding(
  padding: const EdgeInsets.all(16.0),
  child: ...
)

// ❌ Cores hardcoded
Container(
  color: Color(0xFF123456),
  ...
)
```

### ✅ SEMPRE Faça Isso

```dart
// ✅ Usar TextTheme do Material 3
Text(
  'Título',
  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
    color: DSColors.textPrimary,
  ),
)

// ✅ Usar tokens de spacing
Padding(
  padding: DSPaddings.medium,
  child: ...
)

// ✅ Usar cores semânticas
Container(
  color: Theme.of(context).colorScheme.primary,
  ...
)
```

---

## Tipografia

> [!IMPORTANT]
> **Hierarquia de Texto - Use TextTheme do Material 3**
> 
> Use `Theme.of(context).textTheme` para todos os textos. Isso garante consistência e suporte a temas dinâmicos e acessibilidade.

| Uso | Token | Tamanho |
|-----|-------|---------|
| Títulos principais | `headlineLarge` | 32px |
| Títulos de seção | `headlineMedium` | 28px |
| Subtítulos | `headlineSmall` | 24px |
| Títulos de card | `titleLarge` | 22px |
| Títulos menores | `titleMedium` | 16px |
| Labels de campo | `titleSmall` | 14px |
| Corpo de texto | `bodyLarge` | 16px |
| Corpo padrão | `bodyMedium` | 14px |
| Corpo pequeno | `bodySmall` | 12px |
| Labels | `labelLarge` | 14px |
| Labels médios | `labelMedium` | 12px |
| Labels pequenos | `labelSmall` | 11px |

### Estilos Customizados

Para estilos específicos do projeto, use `DSTextStyles`:

```dart
// Cabeçalhos
DSTextStyles.headerTitle      // 18px, bold
DSTextStyles.headerSubtitle   // 14px, medium

// Labels
DSTextStyles.label            // 12px, regular
```

### Modificando Estilos

Use `copyWith` para ajustes:

```dart
Text(
  'Texto',
  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
    color: DSColors.textSecondary,
    fontWeight: FontWeight.w600,
  ),
)
```

---

## Spacing e Padding

### Tokens de Spacing

Use `DSSpacing` para valores numéricos:

```dart
DSSpacing.xxs    // 2px
DSSpacing.xs     // 4px
DSSpacing.sm     // 8px
DSSpacing.md     // 16px
DSSpacing.lg     // 20px
DSSpacing.xl     // 24px
DSSpacing.xxl    // 32px
DSSpacing.xxxl   // 40px
DSSpacing.xxxxl  // 48px
```

### Tokens de Padding

Use `DSPaddings` para `EdgeInsets` pré-configurados:

```dart
DSPaddings.none         // EdgeInsets.zero
DSPaddings.extraSmall   // EdgeInsets.all(8)
DSPaddings.small        // EdgeInsets.all(12)
DSPaddings.medium       // EdgeInsets.all(16)
DSPaddings.large        // EdgeInsets.all(24)
DSPaddings.extraLarge   // EdgeInsets.all(32)
```

### Exemplos de Uso

```dart
// Padding simétrico
Padding(
  padding: EdgeInsets.symmetric(
    horizontal: DSSpacing.md,
    vertical: DSSpacing.sm,
  ),
  child: ...
)

// Padding específico
Padding(
  padding: EdgeInsets.only(
    top: DSSpacing.lg,
    bottom: DSSpacing.md,
  ),
  child: ...
)

// Padding pré-configurado
Container(
  padding: DSPaddings.medium,
  child: ...
)
```

---

## Cores

> [!IMPORTANT]
> **Cores Semânticas - Material 3 ColorScheme**
> 
> **SEMPRE** use cores semânticas do `Theme.of(context).colorScheme`. Isso garante suporte automático a dark mode e temas customizados.

```dart
// Cores principais
Theme.of(context).colorScheme.primary
Theme.of(context).colorScheme.secondary
Theme.of(context).colorScheme.tertiary

// Superfícies
Theme.of(context).colorScheme.surface
Theme.of(context).colorScheme.surfaceContainer
Theme.of(context).colorScheme.surfaceContainerHighest

// Estados
Theme.of(context).colorScheme.error
Theme.of(context).colorScheme.onPrimary
Theme.of(context).colorScheme.onSurface
```

### Cores do Design System

Use `DSColors` para cores específicas do projeto:

```dart
// Texto
DSColors.textPrimary
DSColors.textSecondary
DSColors.textMuted

// Estados
DSColors.success
DSColors.warning
DSColors.error
DSColors.errorLight

// Bordas
DSColors.border
DSColors.borderLight

// Outros
DSColors.primarySubtle
```

### Cores com Opacidade

> [!TIP]
> **Material 3 - Método withValues**
> 
> No Material 3, use `withValues()` ao invés de `withOpacity()`.

```dart
// Material 3 - use withValues
Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)

// DSColors
DSColors.textPrimary.withValues(alpha: 0.7)
```

---

## Ícones

Use `DSIcons` para todos os ícones:

```dart
Icon(DSIcons.search)
Icon(DSIcons.person)
Icon(DSIcons.settings)
Icon(DSIcons.checkCircle)
```

---

## Border Radius

Use `DSRadius` para bordas arredondadas:

```dart
DSRadius.small   // BorderRadius.circular(8)
DSRadius.mediumLarge // BorderRadius.circular(12) - Navegação/Inputs
DSRadius.medium  // BorderRadius.circular(12) - DEPRECATED (Use mediumLarge ou input)
DSRadius.large   // BorderRadius.circular(16)
```

---

## Componentes do Design System

### Botões

```dart
DSButton(
  label: 'Salvar',
  onPressed: () {},
  icon: DSIcons.save,
)
```

### Cards

```dart
DSCard(
  child: ...
)
```

### Text Fields

```dart
DSTextField(
  label: 'Nome',
  prefixIcon: DSTextFieldPrefixIcon.person,
)
```

### Alerts

```dart
DSAlert.success(context, message: 'Sucesso!');
DSAlert.error(context, message: 'Erro!');
DSAlert.warning(context, message: 'Atenção!');
```

---

## Boas Práticas

### 1. Sempre Use Tokens Existentes

Antes de criar novos tokens, verifique se já existe um token adequado. Pequenas diferenças (1-2px) são aceitáveis para manter o Design System enxuto.

### 2. Evite Valores Mágicos

```dart
// ❌ Valor mágico
SizedBox(height: 17.5)

// ✅ Usar token
SizedBox(height: DSSpacing.md)
```

### 3. Consistência de Temas

Sempre use `Theme.of(context)` para garantir suporte a dark mode e temas customizados.

### 4. Acessibilidade

O uso de `TextTheme` garante que os textos escalam corretamente com as configurações de acessibilidade do usuário.

---

## Verificação de Qualidade

> [!NOTE]
> **Análise Estática - Garantia de Qualidade**
> 
> Execute regularmente `dart analyze` e `dart fix --apply` para garantir que o código esteja seguindo as regras do Design System.

### Análise Estática

```bash
# Verificar erros
dart analyze

# Aplicar correções automáticas
dart fix --apply
```

### Checklist de Revisão

- [ ] Nenhum `fontSize` hardcoded
- [ ] Nenhum `FontWeight` hardcoded sem `TextTheme`
- [ ] Nenhum `EdgeInsets` com valores numéricos diretos
- [ ] Nenhum `Color(0x...)` ou `Colors.*` sem contexto semântico
- [ ] Todos os ícones usam `DSIcons`
- [ ] Todos os componentes usam widgets do Design System quando disponível

---

## Migração de Código Legado

### Mapeamento de Valores Comuns

| Hardcoded | Token Recomendado |
|-----------|-------------------|
| `fontSize: 10` | `labelSmall` (11px) |
| `fontSize: 11` | `labelSmall` |
| `fontSize: 12` | `labelMedium` |
| `fontSize: 13` | `titleSmall` (14px) |
| `fontSize: 14` | `bodyMedium` |
| `fontSize: 16` | `titleMedium` |
| `fontSize: 18` | `DSTextStyles.headerTitle` |
| `fontSize: 24` | `headlineSmall` |
| `fontSize: 28` | `headlineMedium` |
| `EdgeInsets.all(8)` | `DSPaddings.extraSmall` |
| `EdgeInsets.all(16)` | `DSPaddings.medium` |
| `EdgeInsets.all(24)` | `DSPaddings.large` |

---

## Referências

- **Regras Flutter/Dart**: `docs/rules/flutter_dart_rules.md`
- **Estrutura de Pacotes**: `docs/adr/0005-standard-package-structure.md`
- **Código do Design System**: `packages/design_system/lib/`
  - Tokens definidos em: `packages/design_system/lib/src/tokens/`
  - Componentes em: `packages/design_system/lib/src/widgets/`
