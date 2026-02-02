# ADR-0004: Validação de Formulários - FormValidationMixin e Zard

**Status:** Aceito e Implementado
**Data:** 2026-01-18 (Original) | 2026-01-31 (Atualizado)
**Versão:** 2.0.0

## Contexto

O projeto necessita de uma solução robusta para validação de formulários que:
1. Isole a biblioteca de validação (permitindo substituição futura)
2. Gerencie estado completo de formulários (controllers, erros, dirty state)
3. Seja consistente em toda a aplicação
4. Funcione tanto em UI quanto em backend/UseCases

## Decisão

Adotar um padrão **Dual Interface** com duas camadas:

### Camada 1: CoreValidator (Backend/UseCases)
Interface agnóstica em `core_shared` para validação de entidades e DTOs.

### Camada 2: FormValidationMixin (UI/Formulários)
Mixin em `core_ui` que gerencia **estado completo de formulários** e isola completamente o Zard.

---

## Arquitetura

```
┌─────────────────────────────────────────────────────────────┐
│  *_shared (Dart Puro)                                        │
│                                                              │
│  FeatureValidator extends CoreValidator<T>                  │
│    ├─ schema (static ZMap) ← Para FormValidationMixin       │
│    └─ validate(T) → CoreValidationResult ← Para UseCases    │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │ usa
┌─────────────────────────────────────────────────────────────┐
│  core_ui (Camada de Abstração)                              │
│                                                              │
│  FormValidationMixin (on ChangeNotifier)                    │
│    ├─ registerField() → TextEditingController               │
│    ├─ getFieldError() → String?                             │
│    ├─ validateForm(schema) → Result<Map>                    │
│    ├─ submitForm(schema, onValid) → Result<T>              │
│    └─ Gerencia: controllers, errors, dirty, touched, submit │
└─────────────────────────────────────────────────────────────┘
                            ▲
                            │ usa
┌─────────────────────────────────────────────────────────────┐
│  *_ui (ViewModels + Widgets)                                 │
│                                                              │
│  FeatureFormViewModel extends ChangeNotifier                │
│                       with FormValidationMixin              │
│    ├─ Registra campos no construtor                         │
│    ├─ submit() → Usa submitForm() do mixin                  │
│    └─ NUNCA importa zard diretamente                        │
└─────────────────────────────────────────────────────────────┘
```

---

## Componentes

### 1. CoreValidator (core_shared)

**Propósito:** Validação de domínio (UseCases, backend, testes)

```dart
// packages/core/core_shared/lib/src/validators/validators.dart
abstract class CoreValidator<T> {
  const CoreValidator();
  CoreValidationResult validate(T value);
}

class CoreValidationResult {
  final bool isValid;
  final List<CoreValidationError> errors;
  // ...
}
```

### 2. Validadores de Feature (*_shared)

**Padrão obrigatório:** Expor `schema` estático E implementar `validate()`

```dart
// packages/school/school_shared/lib/src/validators/school_validators.dart
import 'package:core_shared/core_shared.dart';
import 'package:zard/zard.dart';

const String schoolNameField = 'name';
const String schoolEmailField = 'email';
// ...

class SchoolDetailsValidator extends CoreValidator<SchoolDetails> {
  const SchoolDetailsValidator();

  // 1. Schema para formulários (usado por FormValidationMixin)
  static final schema = z.map({
    schoolNameField: z.string().min(1, message: 'Nome obrigatório'),
    schoolEmailField: z.string().email(message: 'Email inválido'),
    // ...
  });

  // 2. Método validate para UseCases/backend
  @override
  CoreValidationResult validate(SchoolDetails value) {
    final data = {
      schoolNameField: value.name,
      schoolEmailField: value.email,
      // ...
    };

    final result = schema.safeParse(data);

    if (result.success) {
      return CoreValidationResult.success();
    } else {
      final errors = <CoreValidationError>[];
      for (final issue in (result as dynamic).error.issues) {
        final path = (issue.path as List?)?.join('.') ?? 'unknown';
        errors.add(CoreValidationError(
          field: path,
          message: issue.message,
        ));
      }
      return CoreValidationResult.failure(errors);
    }
  }
}
```

### 3. FormValidationMixin (core_ui)

**Versão:** 1.1.0 (expandido em 2026-01-31)

**Funcionalidades completas:**

```dart
// packages/core/core_ui/lib/core/mixins/form_validation_mixin.dart
mixin FormValidationMixin on ChangeNotifier {
  // Gerenciamento de Controllers
  TextEditingController registerField(String name, {String? initialValue});
  String getFieldValue(String name);
  void setFieldValue(String name, String value);

  // Gerenciamento de Erros
  String? getFieldError(String name);
  void setFieldError(String name, String error);
  void clearErrors([String? name]);

  // Estado
  bool get isFormValid;
  bool get hasErrors;
  bool get isFormDirty;
  bool get isSubmitting;

  // Validação
  Result<Map<String, dynamic>> validateForm({
    required Map<String, dynamic> data,
    required ZMap schema,
  });

  // Submit integrado
  Future<Result<T>> submitForm<T>({
    required Map<String, dynamic> data,
    required ZMap schema,
    required Future<Result<T>> Function(Map<String, dynamic>) onValid,
  });

  // Lifecycle
  void resetForm([Map<String, String>? initialValues]);
  void disposeFormResources();
}
```

### 4. ViewModel com FormValidationMixin

**Exemplo completo (School):**

```dart
// packages/school/school_ui/lib/ui/view_models/school_form_view_model.dart
class SchoolFormViewModel extends ChangeNotifier with FormValidationMixin {
  final CreateUseCase _createUseCase;
  final UpdateUseCase _updateUseCase;
  final SchoolDetails? _initialData;

  bool get isEditMode => _initialData != null;

  SchoolFormViewModel({
    required CreateUseCase createUseCase,
    required UpdateUseCase updateUseCase,
    SchoolDetails? initialData,
  }) : _createUseCase = createUseCase,
       _updateUseCase = updateUseCase,
       _initialData = initialData {
    _initializeFields();
  }

  void _initializeFields() {
    final data = _initialData;
    if (data != null) {
      registerField(schoolNameField, initialValue: data.name);
      registerField(schoolEmailField, initialValue: data.email);
      // ...
    } else {
      registerField(schoolNameField);
      registerField(schoolEmailField);
      // ...
    }
  }

  Future<Result<SchoolDetails>> submit() async {
    final formData = {
      schoolNameField: getFieldValue(schoolNameField),
      schoolEmailField: getFieldValue(schoolEmailField),
      // ...
    };

    return submitForm<SchoolDetails>(
      data: formData,
      schema: SchoolDetailsValidator.schema,
      onValid: (validatedData) async {
        final schoolDetails = _createFromData(validatedData);
        return isEditMode
            ? _updateUseCase.execute(schoolDetails)
            : _createUseCase.execute(schoolDetails);
      },
    );
  }

  @override
  void dispose() {
    disposeFormResources();
    super.dispose();
  }
}
```

### 5. Widget usando ViewModel

```dart
// packages/school/school_ui/lib/ui/widgets/forms/school_form_widget.dart
class SchoolFormWidget extends StatefulWidget {
  final CreateUseCase createUseCase;
  final UpdateUseCase updateUseCase;
  final SchoolDetails? initialData;
  final void Function(SchoolDetails)? onSuccess;
  final void Function(Exception)? onError;
  // ...
}

class _SchoolFormWidgetState extends State<SchoolFormWidget> {
  late SchoolFormViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = SchoolFormViewModel(
      createUseCase: widget.createUseCase,
      updateUseCase: widget.updateUseCase,
      initialData: widget.initialData,
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(  // ← Reativo ao ViewModel
      listenable: _viewModel,
      builder: (context, _) {
        return Column(
          children: [
            TextField(
              controller: _viewModel.registerField(schoolNameField),
              decoration: InputDecoration(
                errorText: _viewModel.getFieldError(schoolNameField),
              ),
            ),
            // ...
            ElevatedButton(
              onPressed: _viewModel.isSubmitting
                  ? null
                  : (_viewModel.isFormValid && _viewModel.isFormDirty
                      ? _handleSubmit
                      : null),
              child: _viewModel.isSubmitting
                  ? CircularProgressIndicator()
                  : Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSubmit() async {
    final result = await _viewModel.submit();
    if (result case Success(:final value)) {
      widget.onSuccess?.call(value);
    } else if (result case Failure(:final error)) {
      widget.onError?.call(error);
    }
  }
}
```

---

## Quando Usar Cada Abordagem

### Use CoreValidator.validate() quando:
- ✅ Validar em **UseCases** (antes de persistir)
- ✅ Validar em **backend** (server-side)
- ✅ Validar em **testes unitários**
- ✅ Validação **sem UI**

### Use FormValidationMixin quando:
- ✅ Criar/editar **formulários Flutter**
- ✅ Precisar de **estado reativo** (dirty, errors, loading)
- ✅ Gerenciar **TextEditingControllers**
- ✅ Submit com **validação integrada**

---

## Migração de zard_form

**Antes (zard_form - DEPRECATED):**
```dart
import 'package:zard_form/zard_form.dart';  // ❌ Expõe Zard

late ZForm<Map<String, dynamic>> _form;

_form = useForm(
  resolver: zardResolver(schema),
  mode: ValidationMode.onChange,
);

ZFormBuilder(
  form: _form,
  builder: (context, state) {
    return TextField(
      controller: _form.register('field'),
      decoration: InputDecoration(
        errorText: state.errors['field'],
      ),
    );
  },
)
```

**Depois (FormValidationMixin - RECOMENDADO):**
```dart
import 'package:core_ui/core_ui.dart';  // ✅ Zard isolado

late MyFormViewModel _viewModel;

_viewModel = MyFormViewModel();

ListenableBuilder(
  listenable: _viewModel,
  builder: (context, _) {
    return TextField(
      controller: _viewModel.registerField('field'),
      decoration: InputDecoration(
        errorText: _viewModel.getFieldError('field'),
      ),
    );
  },
)
```

---

## Consequências

### Positivas ✅
- **Isolamento completo do Zard:** Pode ser substituído sem impacto
- **Estado completo de formulários:** Controllers, errors, dirty, touched, submitting
- **Type-safe:** ViewModels retornam tipos específicos (não `Map`)
- **Validação server + client:** Schema compartilhado em `*_shared`
- **Consistência:** Padrão único em todo o projeto
- **Melhor UX:** Loading indicators, disable on submit, dirty state

### Negativas ⚠️
- **Boilerplate:** Cada feature precisa de ViewModel + Validator
- **Breaking change:** Formulários antigos precisam migração
- **Curva de aprendizado:** Padrão mais complexo que `GlobalKey<FormState>`

### Riscos Mitigados ✅
- **Dependência do Zard:** Isolado em validators e FormValidationMixin
- **Duplicação de validação:** Schema único em `*_shared` serve UI e backend
- **Inconsistência:** Padrão obrigatório via ADR e templates

---

## Implementações de Referência

1. **School (completo com UseCases):**
   - `packages/school/school_shared/lib/src/validators/school_validators.dart`
   - `packages/school/school_ui/lib/ui/view_models/school_form_view_model.dart`
   - `packages/school/school_ui/lib/ui/widgets/forms/school_form_widget.dart`

2. **Notebook (sem UseCases, validação pura):**
   - `packages/notebook/notebook_shared/lib/src/validators/notebook_validator.dart`
   - `packages/notebook/notebook_ui/lib/ui/view_models/notebook_form_view_model.dart`
   - `packages/notebook/notebook_ui/lib/pages/notebook_form_page.dart`

---

## Referências

- **Código:** `packages/core/core_ui/lib/core/mixins/form_validation_mixin.dart`
- **Documentação:** `packages/core/core_ui/README.md`
- **Template:** `docs/rules/new_feature.md` (seção de validação)
- **Changelog:** `packages/core/core_ui/CHANGELOG.md` v1.1.0
