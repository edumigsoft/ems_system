# Changelog

## [1.1.0] - 2026-01-31

### Changed
- **BREAKING:** `FormValidationMixin` agora requer `on ChangeNotifier`
- Expandido `FormValidationMixin` com gerenciamento completo de estado de formulários:
  - Gerenciamento de `TextEditingController` via `registerField()`
  - Controle de erros por campo (`getFieldError()`, `setFieldError()`, `clearErrors()`)
  - Gerenciamento de estado dirty/touched (`isFormDirty`, `isFieldDirty()`)
  - Controle de estado de submissão (`isSubmitting`, `submitForm()`)
  - Métodos de lifecycle (`resetForm()`, `disposeFormResources()`)
  - Getters de estado (`isFormValid`, `hasErrors`, `formErrors`)
- Mapeamento automático de erros do Zard para estado interno do formulário
- Documentação inline completa (DartDoc) com exemplos de uso

### Fixed
- Tratamento defensivo de `issue.path` do Zard (pode ser null)
- Remoção de import desnecessário (`flutter/foundation.dart`)

## [1.0.0] - 2026-01-18

### Added
- `ResponsiveLayout` e `ResponsiveLayoutMode` para layouts responsivos.
- `BaseViewModel` e infraestrutura completa MVVM.
- `FormValidationMixin` para validação de formulários.
- Utilitários de navegação e sistema de módulos.
- Integração com Flutter e suporte a persistência local via path_provider.
- Integração com `ems_system_core_shared` para funcionalidades compartilhadas.
