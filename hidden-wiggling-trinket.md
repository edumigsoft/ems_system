# Análise e Implementação: Esqueci Minha Senha + Trocar Senha no Perfil

## Context

O usuário solicitou análise das funcionalidades "esqueci minha senha" e "trocar a senha no perfil" nos pacotes `auth` e `user`. A análise revelou que:

- **"Esqueci minha senha"**: Totalmente implementado do servidor até a UI.
- **"Trocar a senha" no perfil**: Backend + cliente HTTP implementados, mas **ausente na UI do perfil** (ProfilePage, ProfileViewModel, AuthViewModel).

---

## Estado Atual

### ✅ Esqueci Minha Senha — COMPLETO

| Camada | Arquivo | Status |
|--------|---------|--------|
| Shared | `auth_shared/src/models/auth_request.dart` — `PasswordResetRequest`, `PasswordResetConfirm` | ✅ |
| Server | `auth_server/src/routes/auth_routes.dart` — `POST /auth/forgot-password`, `POST /auth/reset-password` | ✅ |
| Server | `auth_server/src/service/auth_service.dart` — `forgotPassword()`, `resetPassword()` | ✅ |
| Client | `auth_client/src/service/auth_api_service.dart` — `forgotPassword()`, `resetPassword()` | ✅ |
| Client | `auth_client/src/service/auth_service.dart` — `requestPasswordReset()`, `confirmPasswordReset()` | ✅ |
| UI VM  | `auth_ui/view_models/auth_view_model.dart` — `requestPasswordReset()`, `confirmPasswordReset()` | ✅ |
| UI     | `auth_ui/pages/forgot_password_page.dart` | ✅ |
| UI     | `auth_ui/pages/reset_password_page.dart` | ✅ |
| UI     | `auth_ui/pages/auth_flow_page.dart` — orquestra o fluxo | ✅ |

**Fluxo:** Login → ForgotPasswordPage → (email enviado) → ResetPasswordPage (via token no deep link) → Login

---

### ❌ Trocar Senha no Perfil — INCOMPLETO (falta UI)

| Camada | Arquivo | Status |
|--------|---------|--------|
| Shared | `auth_shared/src/models/auth_request.dart` — `ChangePasswordRequest` | ✅ |
| Server | `auth_server/src/routes/auth_routes.dart` — `POST /auth/change-password` | ✅ |
| Server | `auth_server/src/service/auth_service.dart` — `changePassword()` (valida senha atual, revoga outros tokens, mantém sessão) | ✅ |
| Client | `auth_client/src/service/auth_api_service.dart` — `changePassword()` | ✅ |
| Client | `auth_client/src/service/auth_service.dart` — `changePassword()` | ✅ |
| UI VM  | `auth_ui/view_models/auth_view_model.dart` — ❌ FALTA método `changePassword` | ❌ |
| UI VM  | `user_ui/view_models/profile_view_model.dart` — ❌ FALTA delegação | ❌ |
| UI     | `user_ui/pages/profile_page.dart` — ❌ FALTA botão/dialog "Alterar Senha" | ❌ |

---

## Plano de Implementação

### Arquivos a modificar (4 arquivos, 0 novos)

#### 1. `packages/auth/auth_ui/lib/view_models/auth_view_model.dart`

Adicionar método `changePassword` que delega para `_authService.changePassword()`:

```dart
Future<bool> changePassword({
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  _state = AuthState.loading;
  _errorMessage = null;
  notifyListeners();

  final result = await _authService.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
    confirmPassword: confirmPassword,
  );

  if (result case Success()) {
    _state = AuthState.authenticated;
    notifyListeners();
    return true;
  } else if (result case Failure(error: final error)) {
    _errorMessage = error.toString();
    _state = AuthState.error;
    notifyListeners();
    return false;
  }

  return false;
}
```

#### 2. `packages/user/user_ui/lib/view_models/profile_view_model.dart`

Adicionar delegação `changePassword` para `_authViewModel` (mesmo padrão do `logout`):

```dart
Future<bool> changePassword({
  required String currentPassword,
  required String newPassword,
  required String confirmPassword,
}) async {
  return _authViewModel.changePassword(
    currentPassword: currentPassword,
    newPassword: newPassword,
    confirmPassword: confirmPassword,
  );
}

// Getter para acessar errorMessage do authViewModel na UI
String? get authErrorMessage => _authViewModel.errorMessage;
bool get isAuthLoading => _authViewModel.isLoading;
```

#### 3. `packages/user/user_ui/lib/pages/profile_page.dart`

Adicionar botão "Alterar Senha" próximo ao botão de logout, e método `_showChangePasswordDialog` seguindo o padrão do `_showEditDialog` existente:

- Botão `OutlinedButton.icon` com `Icons.lock_outline` e label `'Alterar Senha'`
- Dialog com 3 campos: Senha Atual, Nova Senha, Confirmar Nova Senha (todos `obscureText: true`)
- Usa `ListenableBuilder` com `widget.viewModel` para loading/erro
- `FilledButton('Salvar')` chama `widget.viewModel.changePassword(...)` e fecha o dialog em caso de sucesso
- `SnackBar` de confirmação com mensagem `'Senha alterada com sucesso!'`

#### 4. (Opcional) `packages/auth/auth_shared/lib/src/validators/auth_validators.dart`

Se o `ChangePasswordRequestValidator` não já valida no cliente, verificar se a validação inline do dialog cobre: comprimento mínimo 8 char e confirmação de senha correspondente.

---

## Padrão de Referência

- **`_showEditDialog`** em `profile_page.dart:55` — padrão de dialog a seguir
- **`logout()`** em `profile_view_model.dart:89` — padrão de delegação para `_authViewModel`
- **`AuthService.changePassword()`** em `auth_client/src/service/auth_service.dart:187` — já implementado

---

## Verificação

1. `dart analyze packages/auth/auth_ui` — sem erros
2. `dart analyze packages/user/user_ui` — sem erros
3. Testar fluxo: ProfilePage → clica "Alterar Senha" → dialog → preenche campos → Salvar → SnackBar de sucesso
4. Testar erro: senha atual incorreta → mensagem de erro no dialog
