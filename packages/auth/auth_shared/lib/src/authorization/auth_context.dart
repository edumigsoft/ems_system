import 'package:core_shared/core_shared.dart' show UserRole;

/// Contexto de autenticação extraído do token JWT.
///
/// Populado pelo middleware de autenticação e disponível
/// em todos os handlers via `request.context['authContext']`.
class AuthContext {
  /// ID do usuário autenticado.
  final String userId;

  /// Email do usuário.
  final String email;

  /// Role global do usuário.
  final UserRole role;

  const AuthContext({
    required this.userId,
    required this.email,
    required this.role,
  });

  /// Verifica se o usuário é administrador.
  bool get isAdmin => role.isAdmin;

  /// Verifica se o usuário tem a role especificada ou superior (hierarquia).
  ///
  /// Exemplos:
  /// - owner.hasRole(admin) → true (4 >= 3)
  /// - admin.hasRole(admin) → true (3 >= 3)
  /// - manager.hasRole(admin) → false (2 < 3)
  bool hasRole(UserRole required) => role >= required;

  /// Verifica se o usuário tem uma das roles especificadas.
  bool hasAnyRole(List<UserRole> roles) => roles.contains(role);

  @override
  String toString() =>
      'AuthContext(userId: $userId, email: $email, role: $role)';
}
