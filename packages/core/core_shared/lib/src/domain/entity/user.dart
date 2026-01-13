import '../enums/user_role.dart';

/// Entity pura de usuário - SEM campos de persistência.
///
/// Seguindo as regras de entity_patterns.md:
/// - SEM id (detalhe de persistência)
/// - SEM createdAt/updatedAt (metadados)
/// - SEM toJson/fromJson (responsabilidade de Models)
///
/// Esta entity é o conceito fundamental de identidade referenciado
/// por todos os módulos (auth, projects, finance, tasks).
class User {
  /// Nome completo do usuário.
  final String name;

  /// Email do usuário (único no sistema).
  final String email;

  /// Username para identificação pública (único no sistema).
  final String username;

  /// Role global do usuário no sistema.
  final UserRole role;

  /// Indica se o email foi verificado.
  final bool emailVerified;

  /// URL do avatar do usuário.
  final String? avatarUrl;

  /// Número de telefone do usuário.
  final String? phone;

  const User({
    required this.name,
    required this.email,
    required this.username,
    this.role = UserRole.user,
    this.emailVerified = false,
    this.avatarUrl,
    this.phone,
  });

  /// Verifica se o usuário é administrador.
  bool get isAdmin => role.isAdmin;

  /// Verifica se o usuário está autenticado (não é guest).
  bool get isAuthenticated => role.isAuthenticated;

  /// Verifica se o email do usuário está verificado.
  bool get canLogin => emailVerified;

  /// Cria uma cópia do usuário com os campos especificados alterados.
  User copyWith({
    String? name,
    String? email,
    String? username,
    UserRole? role,
    bool? emailVerified,
    String? avatarUrl,
    String? phone,
  }) {
    return User(
      name: name ?? this.name,
      email: email ?? this.email,
      username: username ?? this.username,
      role: role ?? this.role,
      emailVerified: emailVerified ?? this.emailVerified,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phone: phone ?? this.phone,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is User &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          email == other.email &&
          username == other.username &&
          role == other.role &&
          emailVerified == other.emailVerified &&
          avatarUrl == other.avatarUrl &&
          phone == other.phone;

  @override
  int get hashCode =>
      name.hashCode ^
      email.hashCode ^
      username.hashCode ^
      role.hashCode ^
      emailVerified.hashCode ^
      avatarUrl.hashCode ^
      phone.hashCode;

  @override
  String toString() =>
      'User(name: $name, email: $email, username: $username, role: $role)';
}
