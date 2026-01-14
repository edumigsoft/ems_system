import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:core_shared/core_shared.dart';
import 'package:core_client/core_client.dart';
import 'package:user_shared/user_shared.dart';
import 'package:user_client/user_client.dart';

/// ViewModel para gerenciar perfil do usuário.
///
/// Segue padrão MVVM + ADR-0001 (Result) + ADR-0002 (DioErrorHandler).
class ProfileViewModel extends ChangeNotifier with Loggable, DioErrorHandler {
  final UserService _userService;

  ProfileViewModel({required UserService userService})
    : _userService = userService;

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

    final result = await _executeGetProfile();

    if (result case Success(value: final data)) {
      _profile = data.toDomain();
      _isLoading = false;
      notifyListeners();
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Result<UserDetailsModel>> _executeGetProfile() async {
    try {
      final model = await _userService.getProfile();
      return Success(model);
    } on DioException catch (e) {
      return handleDioError<UserDetailsModel>(e, context: 'loadProfile');
    }
  }

  /// Atualiza perfil do usuário.
  Future<bool> updateProfile(UserUpdate update) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _executeUpdateProfile(update);

    if (result case Success(value: final data)) {
      _profile = data.toDomain();
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }

    return false;
  }

  Future<Result<UserDetailsModel>> _executeUpdateProfile(
    UserUpdate update,
  ) async {
    try {
      final updateModel = UserUpdateModel.fromDomain(update);
      final model = await _userService.updateProfile(updateModel);
      return Success(model);
    } on DioException catch (e) {
      return handleDioError<UserDetailsModel>(e, context: 'updateProfile');
    }
  }

  /// Limpa erro atual.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
