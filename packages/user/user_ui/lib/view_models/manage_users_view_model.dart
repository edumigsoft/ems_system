import 'package:auth_client/auth_client.dart' show AuthService;
import 'package:ems_system_core_shared/core_shared.dart'
    show Loggable, UserRole, Success, Failure, Result;
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:ems_system_core_client/core_client.dart' show DioErrorHandler;
import 'package:user_shared/user_shared.dart'
    show
        UserDetails,
        UsersListResponse,
        UserDetailsModel,
        UserCreateAdmin,
        UserCreateAdminModel;
import 'package:user_client/user_client.dart' show UserService;

/// ViewModel para gerenciamento administrativo de usuários.
///
/// Segue padrão MVVM + ADR-0001 (Result) + ADR-0002 (DioErrorHandler).
class ManageUsersViewModel extends ChangeNotifier
    with Loggable, DioErrorHandler {
  final UserService _userService;
  final AuthService _authService;

  ManageUsersViewModel({
    required UserService userService,
    required AuthService authService,
  }) : _userService = userService,
       _authService = authService;

  /// Usuário atualmente autenticado.
  UserDetails? _currentUser;
  UserDetails? get currentUser => _currentUser;

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

    if (result case Success(value: final response)) {
      if (refresh) {
        _users = response.data.map((m) => m.toDomain()).toList();
      } else {
        _users.addAll(response.data.map((m) => m.toDomain()));
      }
      _totalUsers = response.total;
      _isLoading = false;
      notifyListeners();
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<Result<UsersListResponse>> _executeLoadUsers() async {
    try {
      final response = await _userService.listUsers(
        page: _currentPage,
        limit: _pageSize,
      );
      return Success(response);
    } on DioException catch (e) {
      return handleDioError<UsersListResponse>(e, context: 'loadUsers');
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

  /// Cria um novo usuário administrativamente (owner only).
  Future<bool> createUser(UserCreateAdmin data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _executeCreateUser(data);

    if (result case Success(value: final newUser)) {
      // Adicionar novo usuário ao topo da lista
      _users.insert(0, newUser.toDomain());
      _totalUsers++;
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

  Future<Result<UserDetailsModel>> _executeCreateUser(
    UserCreateAdmin data,
  ) async {
    try {
      final model = UserCreateAdminModel.fromDomain(data);
      final response = await _userService.createUser(model);
      return Success(response);
    } on DioException catch (e) {
      return handleDioError<UserDetailsModel>(e, context: 'createUser');
    }
  }

  /// Reseta senha de um usuário (admin+).
  ///
  /// Define mustChangePassword=true, forçando o usuário a alterar senha
  /// no próximo login. Apenas owners podem resetar senha de admins.
  Future<bool> resetUserPassword(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _executeResetUserPassword(userId);

    if (result case Success()) {
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

  Future<Result<void>> _executeResetUserPassword(String userId) async {
    try {
      await _userService.forcePasswordChange(userId);
      return const Success(null);
    } on DioException catch (e) {
      return handleDioError<void>(e, context: 'resetUserPassword');
    }
  }

  /// Limpa erro atual.
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Inicializa verificando estado de autenticação.
  Future<void> initialize() async {
    // notifyListeners();
    _currentUser = null;

    final isAuth = await _authService.isAuthenticated();
    if (isAuth) {
      _currentUser = _authService.currentUser;
    }
    // notifyListeners();
  }

  bool canResetPassword(UserDetails user) {
    if (_currentUser == null) return false;

    // Cannot reset own password through this UI
    if (_currentUser!.id == user.id && !_currentUser!.role.isOwner) {
      return false;
    }

    // Owner can reset password for anyone
    if (_currentUser!.role.isOwner) return true;

    // Admin can reset password for users below admin level
    if (_currentUser!.role.isAdmin) {
      return user.role < UserRole.admin;
    }

    // Managers and regular users cannot reset passwords
    return false;
  }

  bool get isAdmin => _currentUser?.role == UserRole.admin;
  bool get isOwner => _currentUser?.role == UserRole.owner;
}
