# Architecture Notes - auth_client

## Dart Puro: Sem Dependência do Flutter

`auth_client` é um pacote **Dart puro**, em conformidade com ADR-0005.

### Separação de Responsabilidades

```
core_client (Dart puro)
  └── ISecureStorage   ← interface abstrata

core_ui (Flutter)
  └── FlutterSecureStorageAdapter implements ISecureStorage

auth_client (Dart puro)
  └── TokenStorage(ISecureStorage storage)  ← injeta adapter via DI

auth_ui (Flutter)
  └── AuthModule: passa FlutterSecureStorageAdapter() na construção de TokenStorage
```

### Estrutura do Pacote

- `auth_shared`: Domínio puro, entidades, regras de negócio
- `auth_client`: **Repositories, HTTP clients, storage** (este pacote) — Dart puro
- `auth_ui`: Widgets, ViewModels, UI state — passa o adapter concreto via DI
- `auth_server`: Backend, rotas, controllers

### Referências

- ADR-0005: Package Structure
- ADR-0002: Dio Error Handler Mixin
- `packages/core/core_client/lib/src/storage/i_secure_storage.dart`
- `packages/core/core_ui/lib/src/storage/flutter_secure_storage_adapter.dart`
