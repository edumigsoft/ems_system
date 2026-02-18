import 'package:auth_client/auth_client.dart' show AuthService;
import 'package:auth_shared/auth_shared.dart'
    show LoginRequest, RegisterRequest;
import 'package:core_shared/core_shared.dart' show Success, Failure;
import 'package:flutter/material.dart';
import 'package:user_shared/user_shared.dart' show UserDetails;

/// Estado de autenticação.
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// ViewModel para gerenciar autenticação.
///
/// Segue padrão MVVM com injeção via construtor.
/// O refresh de tokens é gerenciado automaticamente pelo [TokenRefreshService].
class AuthViewModel extends ChangeNotifier {
  final AuthService _authService;

  AuthViewModel({required AuthService authService})
    : _authService = authService;

  AuthState _state = AuthState.initial;
  String? _errorMessage;
  UserDetails? _currentUser;

  /// Estado atual da autenticação.
  AuthState get state => _state;

  /// Mensagem de erro (se houver).
  String? get errorMessage => _errorMessage;

  /// Usuário atualmente autenticado.
  UserDetails? get currentUser => _currentUser;

  /// Verifica se está autenticado.
  bool get isAuthenticated => _state == AuthState.authenticated;

  /// Verifica se está carregando.
  bool get isLoading => _state == AuthState.loading;

  /// Inicializa verificando estado de autenticação.
  Future<void> initialize() async {
    _state = AuthState.loading;
    notifyListeners();

    final isAuth = await _authService.isAuthenticated();
    if (isAuth) {
      _currentUser = _authService.currentUser;
      _state = AuthState.authenticated;
    } else {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }

  /// Realiza login com email e senha.
  ///
  /// Se [rememberMe] for true (padrão), a sessão persiste por 7 dias.
  /// Se false, a sessão expira em 15 minutos.
  Future<bool> login(
    String email,
    String password, {
    bool rememberMe = true,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(
      LoginRequest(email: email, password: password),
      rememberMe: rememberMe,
    );

    if (result case Success(value: final user)) {
      _currentUser = user;
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

  /// Registra novo usuário.
  Future<bool> register({
    required String name,
    required String email,
    required String username,
    required String password,
    String? phone,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.register(
      RegisterRequest(
        name: name,
        email: email,
        username: username,
        password: password,
        phone: phone,
      ),
    );

    if (result case Success()) {
      _state = AuthState.unauthenticated;
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

  /// Solicita reset de senha.
  Future<bool> requestPasswordReset(String email) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.requestPasswordReset(email);

    if (result case Success()) {
      _state = AuthState.unauthenticated;
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

  /// Confirma reset de senha com token.
  Future<bool> confirmPasswordReset({
    required String token,
    required String newPassword,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.confirmPasswordReset(
      token: token,
      newPassword: newPassword,
    );

    if (result case Success()) {
      _state = AuthState.unauthenticated;
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

  /// Altera a senha do usuário autenticado.
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

  /// Realiza logout.
  Future<void> logout() async {
    _state = AuthState.loading;
    notifyListeners();

    await _authService.logout();

    _currentUser = null;
    _state = AuthState.unauthenticated;
    notifyListeners();
  }

  /// Limpa erro atual.
  void clearError() {
    _errorMessage = null;
    if (_state == AuthState.error) {
      _state = AuthState.unauthenticated;
    }
    notifyListeners();
  }
}
