import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart' show Loggable, Success, Failure;
import 'package:user_shared/user_shared.dart'
    show UserDetails, UserUpdate, GetProfileUseCase, UpdateProfileUseCase;
import 'package:auth_ui/auth_ui.dart' show AuthViewModel;

/// ViewModel para gerenciar perfil do usuário.
///
/// Segue padrão MVVM + Clean Architecture com Use Cases.
class ProfileViewModel extends ChangeNotifier with Loggable {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final AuthViewModel _authViewModel;

  ProfileViewModel({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required AuthViewModel authViewModel,
  }) : _getProfileUseCase = getProfileUseCase,
       _updateProfileUseCase = updateProfileUseCase,
       _authViewModel = authViewModel;

  UserDetails? _profile;
  UserDetails? get profile => _profile;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  /// Carrega perfil do usuário atual.
  Future<void> loadProfile() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _getProfileUseCase.execute();

    if (result case Success(value: final profile)) {
      _profile = profile;
      _isLoading = false;
      notifyListeners();
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      logger.severe('Error loading profile: $error');
    }
  }

  /// Atualiza perfil do usuário.
  Future<bool> updateProfile(UserUpdate update) async {
    if (_profile == null) {
      _error = 'Perfil não carregado';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _updateProfileUseCase.execute(_profile!.id, update);

    if (result case Success(value: final profile)) {
      _profile = profile;
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      logger.severe('Error updating profile: $error');
      return false;
    }

    return false;
  }

  /// Limpa erro atual.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Altera a senha do usuário autenticado.
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

  /// Mensagem de erro do AuthViewModel (usada durante troca de senha).
  String? get authErrorMessage => _authViewModel.errorMessage;

  /// Indica se o AuthViewModel está carregando.
  bool get isAuthLoading => _authViewModel.isLoading;

  /// Realiza logout do usuário.
  Future<void> logout() async {
    logger.info('Logging out user');
    await _authViewModel.logout();
    _profile = null;
    _error = null;
    notifyListeners();
  }
}
