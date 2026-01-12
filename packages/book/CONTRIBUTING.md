# Guia de Contribuição - Book Management

Obrigado por contribuir com a feature **book** do School Manager System!

## 📋 Antes de Começar

1. Leia a [documentação de arquitetura](../docs/v_0_2_0.md)
2. Familiarize-se com [ADR-0005: Estrutura de Pacotes](../docs/adr/0005-standard-package-structure.md)
3. Revise [Regras Flutter/Dart](../docs/rules/flutter_dart_rules.md)

## 🌳 Workflow de Desenvolvimento

### 1. Criar Branch

```bash
git checkout -b feature/book/descricao-da-mudanca
```

**Convenção de branches:**
- `feature/book/nova-funcionalidade` - Nova funcionalidade
- `fix/book/correcao-bug` - Correção de bug
- `refactor/book/melhoria` - Refatoração

### 2. Fazer Alterações

Siga a estrutura de pacotes:

```
book_shared/      # Domain, Use Cases, Validators
book_client/    # HTTP Client
book_server/    # Database, Handlers
book_ui/         # Pages, ViewModels, Widgets
```

### 3. Executar Testes

```bash
# Por pacote
cd book_shared && flutter test
cd book_ui && flutter test
```

### 4. Verificar Qualidade

```bash
# Instalar dependências
cd ../.. && ./pub_get_all.sh

# Aplicar fixes automáticos
./dart_fix_all.sh

# Análise estática
cd packages/book/book_shared && dart analyze

# Formatar código
dart format .
```

### 5. Commit

Use **Conventional Commits**:

```bash
git commit -m "feat(book_shared): adiciona validação de email"
git commit -m "fix(book_ui): corrige overflow na tela de listagem"
```

**Tipos**:  `feat`, `fix`, `refactor`, `docs`, `test`, `chore`, `perf`, `style`

### 6. Pull Request

- Título claro e descritivo
- Descrição completa das mudanças
- Referenciar issues relacionadas
- Screenshots (para mudanças de UI)

## 🎯 Padrões de Código

### Domain Layer (`book_shared`)

✅ **Use Cases** isolados:

```dart
class CreateBook ManagementUseCase {
  final Book ManagementRepository repository;
  
  Future<Result<Book Management>> execute(CreateRequest request) {
    // Lógica de negócio
  }
}
```

✅ **Validators** com Zard:

```dart
final bookSchema = z.object({
  'name': z.string().min(3),
});
```

### UI Layer (`book_ui`)

✅ **ViewModels**:

```dart
class Book ManagementViewModel extends ChangeNotifier 
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
| _shared | 90% | 0 warnings |
| _client | 80% | 0 warnings |
| _server | 80% | 0 warnings |
| _ui | 50% | 0 warnings |

## 📝 Documentação

- Membros públicos devem ter DartDoc (`///`)
- READMEs devem ser atualizados se a API mudar
- CHANGELOGs devem ser mantidos

## 🎓 Referências

- [ADR-0001: Padrão Result](../docs/adr/0001-use-result-pattern-for-error-handling.md)
- [ADR-0002: DioErrorHandler](../docs/adr/0002-use-dio-error-handler-mixin.md)
- [ADR-0003: BaseRepository](../docs/adr/0003-use-base-repository-pattern.md)
- [ADR-0004: FormValidation](../docs/adr/0004-use-form-validation-mixin-and-zard.md)
