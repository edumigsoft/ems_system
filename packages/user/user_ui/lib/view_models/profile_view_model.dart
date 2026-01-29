import 'package:flutter/material.dart';
import 'package:core_shared/core_shared.dart' show Loggable, Success, Failure;
import 'package:user_shared/user_shared.dart'
    show
        UserDetails,
        UserUpdate,
        GetProfileUseCase,
        UpdateProfileUseCase;

/// ViewModel para gerenciar perfil do usuário.
///
/// Segue padrão MVVM + Clean Architecture com Use Cases.
class ProfileViewModel extends ChangeNotifier with Loggable {
  final GetProfileUseCase _getProfileUseCase;
  final UpdateProfileUseCase _updateProfileUseCase;
  final String _currentUserId;

  ProfileViewModel({
    required GetProfileUseCase getProfileUseCase,
    required UpdateProfileUseCase updateProfileUseCase,
    required String currentUserId,
  })  : _getProfileUseCase = getProfileUseCase,
        _updateProfileUseCase = updateProfileUseCase,
        _currentUserId = currentUserId;

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

    final result = await _getProfileUseCase.execute(_currentUserId);

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
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _updateProfileUseCase.execute(_currentUserId, update);

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
}
