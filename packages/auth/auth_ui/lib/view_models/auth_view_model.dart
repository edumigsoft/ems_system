import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart';
import 'package:auth_shared/auth_shared.dart';
import 'package:auth_client/auth_client.dart';
import 'package:user_shared/user_shared.dart';

/// Estado de autenticação.
enum AuthState { initial, loading, authenticated, unauthenticated, error }

/// ViewModel para gerenciar autenticação.
///
/// Segue padrão MVVM com injeção via construtor.
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
  Future<bool> login(String email, String password) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    final result = await _authService.login(
      LoginRequest(email: email, password: password),
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
