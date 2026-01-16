import 'package:core_shared/core_shared.dart';
import 'package:open_api_shared/open_api_shared.dart';

/// Detalhes completos do usuário com campos de persistência.
///
/// Implementa [BaseDetails] conforme entity_patterns.md.
/// Compõe a entity [User] de core_shared com metadados de persistência.
@apiModel
@Model(name: 'UserDetails', description: 'Detalhes completos do usuário')
class UserDetails implements BaseDetails {
  @override
  @Property(description: 'ID do usuário', required: true)
  final String id;

  @override
  @Property(description: 'Data de criação', required: true)
  final DateTime createdAt;

  @override
  @Property(description: 'Data de atualização', required: true)
  final DateTime updatedAt;

  @override
  @Property(description: 'Se o usuário está deletado')
  final bool isDeleted;

  @override
  @Property(description: 'Se o usuário está ativo')
  final bool isActive;

  /// Indica se o usuário deve mudar a senha no próximo login.
  @Property(description: 'Se deve mudar senha no próximo login')
  final bool mustChangePassword;

  /// Dados de domínio do usuário.
  @Property(description: 'Dados do usuário', required: true)
  final User data;

  const UserDetails({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isActive = true,
    this.mustChangePassword = false,
    required this.data,
  });

  /// Construtor de conveniência com campos inline.
  UserDetails.create({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.isDeleted = false,
    this.isActive = true,
    this.mustChangePassword = false,
    required String name,
    required String email,
    required String username,
    UserRole role = UserRole.user,
    bool emailVerified = false,
    String? avatarUrl,
    String? phone,
  }) : data = User(
         name: name,
         email: email,
         username: username,
         role: role,
         emailVerified: emailVerified,
         avatarUrl: avatarUrl,
         phone: phone,
       );

  // Getters de conveniência
  String get name => data.name;
  String get email => data.email;
  String get username => data.username;
  UserRole get role => data.role;
  bool get emailVerified => data.emailVerified;
  String? get avatarUrl => data.avatarUrl;
  String? get phone => data.phone;

  /// Verifica se o usuário é administrador.
  bool get isAdmin => data.isAdmin;

  /// Cria uma cópia com os campos especificados alterados.
  UserDetails copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isDeleted,
    bool? isActive,
    bool? mustChangePassword,
    String? name,
    String? email,
    String? username,
    UserRole? role,
    bool? emailVerified,
    String? avatarUrl,
    String? phone,
  }) {
    return UserDetails(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      isActive: isActive ?? this.isActive,
      mustChangePassword: mustChangePassword ?? this.mustChangePassword,
      data: data.copyWith(
        name: name,
        email: email,
        username: username,
        role: role,
        emailVerified: emailVerified,
        avatarUrl: avatarUrl,
        phone: phone,
      ),
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserDetails &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          data == other.data;

  @override
  int get hashCode => id.hashCode ^ data.hashCode;

  @override
  String toString() =>
      'UserDetails(id: $id, email: $email, username: $username)';
}
