# 4. Uso de FormValidationMixin e Zard
# ... (cabeçalho mantido)

## Decisão

Adotar um padrão de **Wrapper/Adapter** para validação. 

O pacote `core_shared` definirá interfaces agnósticas de validação (`CoreValidator`) e os validadores concretos usarão o pacote **`zard`** internamente como detalhe de implementação.

Isso desacopla o sistema da biblioteca de validação, permitindo que ela seja trocada no futuro sem afetar os consumidores (ViewModels, UseCases).

### Componentes da Solução

#### 1. Core Validator (Interface)

Definido em `packages/core/core_shared/lib/src/validators/validators.dart`:

- `CoreValidator<T>`: Interface base
- `CoreValidationResult`: Resultado padronizado (independente de lib)
- `CoreValidationError`: Erro padronizado

#### 2. Implementação Concreta (Adapter)

Validadores específicos (ex: `FinanceCreateValidator`) estendem `CoreValidator` e usam o Zard internamente, convertendo os resultados.

#### 3. FormValidationMixin

Mixin na UI que consome `CoreValidator`, sem saber que o Zard existe.

---

## Estrutura de Diretórios

Mantém-se a mesma:

```
packages/<feature>/<feature>_core/
  lib/src/
    validators/
      <entity>_validator.dart    # Estende CoreValidator
```

## Implementação

### 1. Definição do Contrato (Core Shared)

```dart
// packages/core/core_shared/lib/src/validators/validators.dart

/// Interface base para validadores do sistema.
abstract class CoreValidator<T> {
  const CoreValidator();

  /// Valida um valor e retorna um resultado padronizado.
  CoreValidationResult validate(T value);
}

/// Resultado de validação agnóstico.
class CoreValidationResult {
  final bool isValid;
  final List<CoreValidationError> errors;

  const CoreValidationResult({
    required this.isValid, 
    this.errors = const [],
  });
  
  factory CoreValidationResult.success() => 
      const CoreValidationResult(isValid: true);
      
  factory CoreValidationResult.failure(List<CoreValidationError> errors) => 
      CoreValidationResult(isValid: false, errors: errors);
}

class CoreValidationError {
  final String field;
  final String message;

  const CoreValidationError({required this.field, required this.message});
}
```

### 2. Validador Concreto (Usando Zard)

```dart
// packages/finance/finance_core/lib/src/validators/finance_validator.dart
import 'package:core_shared/core_shared.dart';
import 'package:zard/zard.dart' as zard;

class FinanceCreateValidator extends CoreValidator<FinanceCreate> {
  @override
  CoreValidationResult validate(FinanceCreate value) {
    // Implementação interna usando Zard
    final result = zard.Validator<FinanceCreate>(
      // regras...
    ).validate(value);

    // Adaptação para o contrato do sistema
    if (result.isValid) {
      return CoreValidationResult.success();
    } else {
      return CoreValidationResult.failure(
        result.errors.map((e) => CoreValidationError(
          field: e.field, 
          message: e.message
        )).toList(),
      );
    }
  }
}
```

### 3. Consumo (ViewModel)

```dart
class MyViewModel extends ChangeNotifier {
  final CoreValidator<MyData> _validator;

  void submit() {
    final result = _validator.validate(data);
    if (!result.isValid) {
      print(result.errors.first.message);
    }
  }
}
```

## Consequências

### Positivas
- ✅ **Desacoplamento Total**: O sistema não depende da API pública do Zard.
- ✅ **Flexibilidade**: É possível trocar o Zard por outra lib (ou validação manual) validador por validador, sem quebrar a UI.
- ✅ **Controle**: Temos controle total sobre o objeto de erro (`CoreValidationError`).

### Negativas
- ⚠️ **Boilerplate**: É necessário escrever código adaptador para cada validador.
- ⚠️ **Perda de Features**: Features avançadas do Zard que não mapeiam para `CoreValidator` ficam inacessíveis diretamente.
