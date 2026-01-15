import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:core_shared/core_shared.dart';
import 'package:core_client/core_client.dart';
import 'package:user_shared/user_shared.dart';
import 'package:user_client/user_client.dart';

/// ViewModel para gerenciamento administrativo de usuários.
///
/// Segue padrão MVVM + ADR-0001 (Result) + ADR-0002 (DioErrorHandler).
class ManageUsersViewModel extends ChangeNotifier
    with Loggable, DioErrorHandler {
  final UserService _userService;

  ManageUsersViewModel({required UserService userService})
    : _userService = userService;

  List<UserDetails> _users = [];
  List<UserDetails> get users => _users;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  // Paginação
  int _currentPage = 1;
  int get currentPage => _currentPage;

  final int _pageSize = 50;
  int get pageSize => _pageSize;

  int _totalUsers = 0;
  int get totalUsers => _totalUsers;

  bool get hasMorePages => _users.length >= _pageSize;

  // Filtros
  String? _searchQuery;
  String? get searchQuery => _searchQuery;

  UserRole? _roleFilter;
  UserRole? get roleFilter => _roleFilter;

  /// Carrega lista de usuários com filtros e paginação.
  Future<void> loadUsers({bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
      _users = [];
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _executeLoadUsers();

    if (result case Success(value: final data)) {
      if (refresh) {
        _users = data.map((m) => m.toDomain()).toList();
      } else {
        _users.addAll(data.map((m) => m.toDomain()));
      }
      _totalUsers = data.length;
      _isLoading = false;
      notifyListeners();
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Result<List<UserDetailsModel>>> _executeLoadUsers() async {
    try {
      final response = await _userService.listUsers(
        page: _currentPage,
        limit: _pageSize,
      );
      return Success(response);
    } on DioException catch (e) {
      return handleDioError<List<UserDetailsModel>>(e, context: 'loadUsers');
    }
  }

  /// Carrega próxima página de usuários.
  Future<void> loadNextPage() async {
    if (!hasMorePages || _isLoading) return;

    _currentPage++;
    await loadUsers();
  }

  /// Busca usuários por query.
  Future<void> searchUsers(String? query) async {
    _searchQuery = query;
    await loadUsers(refresh: true);
  }

  /// Filtra usuários por role.
  Future<void> filterByRole(UserRole? role) async {
    _roleFilter = role;
    await loadUsers(refresh: true);
  }

  /// Limpa todos os filtros.
  Future<void> clearFilters() async {
    _searchQuery = null;
    _roleFilter = null;
    await loadUsers(refresh: true);
  }

  /// Atualiza role de um usuário (admin).
  Future<bool> updateUserRole(String userId, UserRole newRole) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _executeUpdateUserRole(userId, newRole);

    if (result case Success(value: final updatedUser)) {
      // Atualizar usuário na lista local
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser.toDomain();
      }
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

  Future<Result<UserDetailsModel>> _executeUpdateUserRole(
    String userId,
    UserRole newRole,
  ) async {
    try {
      final response = await _userService.updateUserRole(userId, {
        'role': newRole.name,
      });
      return Success(response);
    } on DioException catch (e) {
      return handleDioError<UserDetailsModel>(e, context: 'updateUserRole');
    }
  }

  /// Ativa/desativa um usuário (admin).
  Future<bool> toggleUserStatus(String userId, bool isActive) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _executeToggleUserStatus(userId, isActive);

    if (result case Success(value: final updatedUser)) {
      // Atualizar usuário na lista local
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser.toDomain();
      }
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

  Future<Result<UserDetailsModel>> _executeToggleUserStatus(
    String userId,
    bool isActive,
  ) async {
    try {
      final response = await _userService.updateUserRole(userId, {
        'is_active': isActive,
      });
      return Success(response);
    } on DioException catch (e) {
      return handleDioError<UserDetailsModel>(e, context: 'toggleUserStatus');
    }
  }

  /// Soft delete de um usuário (admin).
  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _executeDeleteUser(userId);

    if (result case Success()) {
      // Remover usuário da lista local
      _users.removeWhere((u) => u.id == userId);
      _totalUsers--;
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

  Future<Result<void>> _executeDeleteUser(String userId) async {
    try {
      await _userService.deactivateUser(userId);
      return const Success(null);
    } on DioException catch (e) {
      return handleDioError<void>(e, context: 'deleteUser');
    }
  }

  /// Limpa erro atual.
  void clearError() {
    _error = null;
    notifyListeners();
  }
}
