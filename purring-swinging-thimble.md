# Plano: Remover dependência Flutter de `auth_client` e `user_client`

## Context

`auth_client` e `user_client` violam ADR-0005 (pacotes `*_client` devem ser Dart puro) por usarem `flutter_secure_storage` (plugin Flutter) diretamente em `TokenStorage` e `SettingsStorage`.

- `auth_client` declara `flutter: sdk: flutter` explicitamente
- `user_client` tem `flutter_secure_storage: ^9.2.4` como dependência direta (sem declarar o SDK, mas ainda traz Flutter transitivamente)

**Não existe** nenhuma abstração de storage no codebase. O plano cria `ISecureStorage` em `core_client` (Dart puro) e `FlutterSecureStorageAdapter` em `core_ui` (Flutter), reutilizável por todos os pacotes feature.

**Resultado:** `auth_client` e `user_client` tornam-se Dart puro. A dependência `flutter_secure_storage` sobe para `core_ui`.

---

## Abordagem: Interface em `core_client` + Adapter em `core_ui`

```
core_client (Dart puro)
  └── ISecureStorage   ← interface abstrata

core_ui (Flutter)
  └── FlutterSecureStorageAdapter implements ISecureStorage

auth_client (Dart puro após mudança)
  └── TokenStorage(ISecureStorage storage)  ← injeta adapter

user_client (Dart puro após mudança)
  └── SettingsStorage(ISecureStorage storage)  ← injeta adapter

auth_ui / user_ui
  └── AuthModule / UserModule: passa FlutterSecureStorageAdapter() na construção
```

---

## Arquivos a CRIAR

### 1. `packages/core/core_client/lib/src/storage/i_secure_storage.dart`
Interface abstrata com 3 métodos:
```dart
abstract interface class ISecureStorage {
  Future<String?> read({required String key});
  Future<void> write({required String key, required String? value});
  Future<void> delete({required String key});
}
```

### 2. `packages/core/core_ui/lib/src/storage/flutter_secure_storage_adapter.dart`
Implementação concreta:
```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:core_client/core_client.dart' show ISecureStorage;

class FlutterSecureStorageAdapter implements ISecureStorage {
  final FlutterSecureStorage _storage;
  FlutterSecureStorageAdapter([FlutterSecureStorage? storage])
      : _storage = storage ?? const FlutterSecureStorage();

  @override Future<String?> read({required String key}) =>
      _storage.read(key: key);
  @override Future<void> write({required String key, required String? value}) =>
      _storage.write(key: key, value: value);
  @override Future<void> delete({required String key}) =>
      _storage.delete(key: key);
}
```

---

## Arquivos a MODIFICAR

### 3. `packages/core/core_client/lib/core_client.dart`
Adicionar export:
```dart
export 'src/storage/i_secure_storage.dart';
```

### 4. `packages/core/core_ui/lib/core_ui.dart`
Adicionar export:
```dart
export 'src/storage/flutter_secure_storage_adapter.dart';
```

### 5. `packages/core/core_ui/pubspec.yaml`
Adicionar dependência:
```yaml
flutter_secure_storage: ^9.2.4
```

### 6. `packages/auth/auth_client/lib/src/storage/token_storage.dart`
- Remover import `flutter_secure_storage`
- Campo: `final ISecureStorage _storage`
- Construtor: `TokenStorage(ISecureStorage storage) : _storage = storage;`
- Adicionar import: `import 'i_secure_storage.dart';`

### 7. `packages/auth/auth_client/pubspec.yaml`
Remover:
- `flutter: sdk: flutter`
- `flutter_secure_storage: ^9.2.4`

dev_dependencies - remover:
- `flutter_test: sdk: flutter`

### 8. `packages/auth/auth_ui/lib/auth_module.dart`
Mudar registro de `TokenStorage`:
```dart
// Antes:
di.registerLazySingleton<TokenStorage>(() => TokenStorage());

// Depois:
di.registerLazySingleton<TokenStorage>(
  () => TokenStorage(FlutterSecureStorageAdapter()),
);
```
Adicionar import de `FlutterSecureStorageAdapter` via `core_ui`.

### 9. `packages/user/user_client/lib/src/storage/settings_storage.dart`
- Remover import `flutter_secure_storage`
- Campo: `final ISecureStorage _storage`
- Construtor: `SettingsStorage(ISecureStorage storage) : _storage = storage;`
- Adicionar import via `core_client`

### 10. `packages/user/user_client/pubspec.yaml`
Remover:
- `flutter_secure_storage: ^9.2.4`

### 11. `packages/user/user_ui/lib/user_module.dart`
Mudar registro de `SettingsStorage`:
```dart
// Antes:
di.registerLazySingleton<SettingsStorage>(() => SettingsStorage());

// Depois:
di.registerLazySingleton<SettingsStorage>(
  () => SettingsStorage(FlutterSecureStorageAdapter()),
);
```
Adicionar import de `FlutterSecureStorageAdapter` via `core_ui`.

### 12. `apps/ems/app_v1/lib/config/di/injector.dart`
O injector EMS cria `SettingsStorage` localmente (sem DI) para leitura de config de servidor:
```dart
// Antes:
final settingsStorage = SettingsStorage();

// Depois:
final settingsStorage = SettingsStorage(FlutterSecureStorageAdapter());
```
Adicionar import de `FlutterSecureStorageAdapter`.

### 13. `packages/auth/auth_client/test/src/interceptor/auth_interceptor_basic_auth_test.dart`
Mudar:
```dart
// Antes:
import 'package:flutter_test/flutter_test.dart';

// Depois:
import 'package:test/test.dart';
```
(O mock `MockTokenStorage extends Mock implements TokenStorage` não muda — a API pública de TokenStorage permanece igual.)

### 14. `packages/auth/auth_client/ARCHITECTURE_NOTES.md`
Atualizar: `auth_client` agora é Dart puro. `ISecureStorage` definida em `core_client`. Remover seção "exceção aceitável".

---

## Sem mudança necessária

- `apps/sms/app_v1/lib/config/di/injector.dart` — não usa `SettingsStorage` localmente
- `apps/ems/app_v1`, `apps/sms/app_v1` pubspec — `flutter_secure_storage` já vem via `core_ui`
- `auth_client/lib/auth_client.dart` — `ISecureStorage` é exportada via `core_client`, não precisa reexportar

---

## Verificação

```bash
# 1. Verificar auth_client como Dart puro (sem deps Flutter)
dart analyze packages/auth/auth_client

# 2. Verificar user_client como Dart puro
dart analyze packages/user/user_client

# 3. Rodar testes de auth_client (agora usa test, não flutter_test)
dart test packages/auth/auth_client

# 4. Verificar core packages
dart analyze packages/core/core_client
flutter analyze packages/core/core_ui

# 5. Verificar pacotes UI
flutter analyze packages/auth/auth_ui
flutter analyze packages/user/user_ui

# 6. Verificar apps completos
flutter analyze apps/ems/app_v1
flutter analyze apps/sms/app_v1
```
