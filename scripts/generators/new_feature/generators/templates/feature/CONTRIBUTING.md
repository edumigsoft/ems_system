# Guia de Contribuição - {{FEATURE_TITLE}}

Obrigado por contribuir com a feature **{{FEATURE_NAME}}** do School Manager System!

## 📋 Antes de Começar

1. Leia a [documentação de arquitetura]({{REL_PATH}}docs/v_0_2_0.md)
2. Familiarize-se com [ADR-0005: Estrutura de Pacotes]({{REL_PATH}}docs/adr/0005-standard-package-structure.md)
3. Revise [Regras Flutter/Dart]({{REL_PATH}}docs/rules/flutter_dart_rules.md)

## 🌳 Workflow de Desenvolvimento

### 1. Criar Branch

```bash
git checkout -b feature/{{FEATURE_NAME}}/descricao-da-mudanca
```

**Convenção de branches:**
- `feature/{{FEATURE_NAME}}/nova-funcionalidade` - Nova funcionalidade
- `fix/{{FEATURE_NAME}}/correcao-bug` - Correção de bug
- `refactor/{{FEATURE_NAME}}/melhoria` - Refatoração

### 2. Fazer Alterações

Siga a estrutura de pacotes:

```
{{FEATURE_NAME}}_core/      # Domain, Use Cases, Validators
{{FEATURE_NAME}}_client/    # HTTP Client
{{FEATURE_NAME}}_server/    # Database, Handlers
{{FEATURE_NAME}}_ui/         # Pages, ViewModels, Widgets
```

### 3. Executar Testes

```bash
# Por pacote
cd {{FEATURE_NAME}}_core && flutter test
cd {{FEATURE_NAME}}_ui && flutter test
```

### 4. Verificar Qualidade

```bash
# Instalar dependências
cd {{REL_PATH}}.. && ./pub_get_all.sh

# Aplicar fixes automáticos
./dart_fix_all.sh

# Análise estática
cd packages/{{FEATURE_NAME}}/{{FEATURE_NAME}_core && dart analyze

# Formatar código
dart format .
```

### 5. Commit

Use **Conventional Commits**:

```bash
git commit -m "feat({{FEATURE_NAME}}_core): adiciona validação de email"
git commit -m "fix({{FEATURE_NAME}}_ui): corrige overflow na tela de listagem"
```

**Tipos**:  `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `style`

### 6. Pull Request

- Título claro e descritivo
- Descrição completa das mudanças
- Referenciar issues relacionadas
- Screenshots (para mudanças de UI)

## 🎯 Padrões de Código

### Domain Layer (`{{FEATURE_NAME}}_core`)

✅ **Use Cases** isolados:

```dart
class Create{{FEATURE_TITLE}}UseCase {
  final {{FEATURE_TITLE}}Repository repository;
  
  Future<Result<{{FEATURE_TITLE}}>> execute(CreateRequest request) {
    // Lógica de negócio
  }
}
```

✅ **Validators** com Zard:

```dart
final {{FEATURE_NAME}}Schema = z.object({
  'name': z.string().min(3),
});
```

### UI Layer (`{{FEATURE_NAME}}_ui`)

✅ **ViewModels**:

```dart
class {{FEATURE_TITLE}}ViewModel extends ChangeNotifier 
    with Loggable, FormValidationMixin {
  // ...
}
```

✅ **Design System** - SEMPRE usar tokens:

```dart
// ✅ SIM
Text('Title', style: Theme.of(context).textTheme.headlineMedium)

// ❌ NÃO
Text('Title', style: TextStyle(fontSize: 18))
```

## 📊 Métricas de Qualidade

| Pacote | Cobertura Mínima | dart analyze |
|--------|------------------|--------------|
| _core | 90% | 0 warnings |
| _client | 80% | 0 warnings |
| _server | 80% | 0 warnings |
| _ui | 50% | 0 warnings |

## 📝 Documentação

- Membros públicos devem ter DartDoc (`///`)
- READMEs devem ser atualizados se a API mudar
- CHANGELOGs devem ser mantidos

## 🎓 Referências

- [ADR-0001: Padrão Result]({{REL_PATH}}docs/adr/0001-use-result-pattern-for-error-handling.md)
- [ADR-0002: DioErrorHandler]({{REL_PATH}}docs/adr/0002-use-dio-error-handler-mixin.md)
- [ADR-0003: BaseRepository]({{REL_PATH}}docs/adr/0003-use-base-repository-pattern.md)
- [ADR-0004: FormValidation]({{REL_PATH}}docs/adr/0004-use-form-validation-mixin-and-zard.md)
