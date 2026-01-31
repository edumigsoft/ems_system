import 'package:auth_client/auth_client.dart' show AuthService;
import 'package:core_shared/core_shared.dart'
    show Loggable, UserRole, Success, Failure;
import 'package:flutter/material.dart';
import 'package:user_shared/user_shared.dart'
    show
        UserDetails,
        UserCreateAdmin,
        UserUpdate,
        GetAllUsersUseCase,
        CreateUserUseCase,
        UpdateUserUseCase,
        DeleteUserUseCase,
        UpdateUserRoleUseCase,
        ResetPasswordUseCase;

/// ViewModel para gerenciamento administrativo de usuários.
///
/// Segue padrão MVVM + Clean Architecture com Use Cases.
class ManageUsersViewModel extends ChangeNotifier with Loggable {
  final GetAllUsersUseCase _getAllUsersUseCase;
  final CreateUserUseCase _createUserUseCase;
  final UpdateUserUseCase _updateUserUseCase;
  final DeleteUserUseCase _deleteUserUseCase;
  final UpdateUserRoleUseCase _updateUserRoleUseCase;
  final ResetPasswordUseCase _resetPasswordUseCase;
  final AuthService _authService;

  ManageUsersViewModel({
    required GetAllUsersUseCase getAllUsersUseCase,
    required CreateUserUseCase createUserUseCase,
    required UpdateUserUseCase updateUserUseCase,
    required DeleteUserUseCase deleteUserUseCase,
    required UpdateUserRoleUseCase updateUserRoleUseCase,
    required ResetPasswordUseCase resetPasswordUseCase,
    required AuthService authService,
  }) : _getAllUsersUseCase = getAllUsersUseCase,
       _createUserUseCase = createUserUseCase,
       _updateUserUseCase = updateUserUseCase,
       _deleteUserUseCase = deleteUserUseCase,
       _updateUserRoleUseCase = updateUserRoleUseCase,
       _resetPasswordUseCase = resetPasswordUseCase,
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

  int _totalPages = 0;
  int get totalPages => _totalPages;

  bool get hasMorePages => _currentPage < _totalPages;

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

    // Calcular offset baseado na página atual
    final offset = (_currentPage - 1) * _pageSize;

    final result = await _getAllUsersUseCase.execute(
      limit: _pageSize,
      offset: offset,
      roleFilter: _roleFilter?.name,
      search: _searchQuery,
    );

    if (result case Success(value: final paginatedResult)) {
      if (refresh) {
        _users = paginatedResult.items;
      } else {
        _users.addAll(paginatedResult.items);
      }
      _totalUsers = paginatedResult.total;
      _totalPages = paginatedResult.totalPages;
      _isLoading = false;
      notifyListeners();
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      logger.severe('Error loading users: $error');
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

    final result = await _updateUserRoleUseCase.execute(userId, newRole);

    if (result case Success(value: final updatedUser)) {
      // Atualizar usuário na lista local
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      logger.severe('Error updating user role: $error');
      return false;
    }

    return false;
  }

  /// Atualiza informações básicas de um usuário (nome, telefone).
  Future<bool> updateUserBasicInfo({
    required String userId,
    String? name,
    String? phone,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Criar DTO de atualização com nome e/ou telefone
    final userUpdate = UserUpdate(
      id: userId,
      name: name,
      phone: phone,
    );

    final result = await _updateUserUseCase.execute(userId, userUpdate);

    if (result case Success(value: final savedUser)) {
      // Atualizar usuário na lista local
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = savedUser;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      logger.severe('Error updating user basic info: $error');
      return false;
    }

    return false;
  }

  /// Ativa/desativa um usuário (admin).
  Future<bool> toggleUserStatus(String userId, bool isActive) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    // Criar DTO de atualização apenas com status
    final userUpdate = UserUpdate(
      id: userId,
      isActive: isActive,
    );

    final result = await _updateUserUseCase.execute(userId, userUpdate);

    if (result case Success(value: final savedUser)) {
      // Atualizar usuário na lista local
      final index = _users.indexWhere((u) => u.id == userId);
      if (index != -1) {
        _users[index] = savedUser;
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      logger.severe('Error toggling user status: $error');
      return false;
    }

    return false;
  }

  /// Soft delete de um usuário (admin).
  Future<bool> deleteUser(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _deleteUserUseCase.execute(userId);

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
      logger.severe('Error deleting user: $error');
      return false;
    }

    return false;
  }

  /// Cria um novo usuário administrativamente (owner only).
  Future<bool> createUser(UserCreateAdmin data) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _createUserUseCase.execute(data);

    if (result case Success(value: final newUser)) {
      // Adicionar novo usuário ao topo da lista
      _users.insert(0, newUser);
      _totalUsers++;
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      logger.severe('Error creating user: $error');
      return false;
    }

    return false;
  }

  /// Reseta senha de um usuário (admin+).
  ///
  /// Define mustChangePassword=true, forçando o usuário a alterar senha
  /// no próximo login. Apenas owners podem resetar senha de admins.
  Future<bool> resetUserPassword(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    final result = await _resetPasswordUseCase.execute(userId);

    if (result case Success()) {
      _isLoading = false;
      notifyListeners();
      return true;
    } else if (result case Failure(error: final error)) {
      _error = error.toString();
      _isLoading = false;
      notifyListeners();
      logger.severe('Error resetting user password: $error');
      return false;
    }

    return false;
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
