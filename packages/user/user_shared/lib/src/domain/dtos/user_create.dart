import 'package:open_api_shared/open_api_shared.dart';

/// DTO para criação de usuário.
///
/// Seguindo entity_patterns.md:
/// - Apenas campos necessários para criação
/// - SEM `id` (gerado pelo banco)
/// - SEM metadados (createdAt, updatedAt, etc.)
/// - SEM serialização (responsabilidade de UserCreateModel)
@apiModel
@Model(name: 'UserCreate', description: 'DTO para criação de usuário')
class UserCreate {
  @Property(description: 'Nome completo', required: true)
  final String name;

  @Property(description: 'Email do usuário', required: true)
  final String email;

  @Property(description: 'Nome de usuário (único)', required: true)
  final String username;

  @Property(description: 'Senha (min 8 car)', required: true)
  final String password;

  @Property(description: 'Telefone (opcional)')
  final String? phone;

  const UserCreate({
    required this.name,
    required this.email,
    required this.username,
    required this.password,
    this.phone,
  });

  /// Validação básica de presença.
  bool get isValid =>
      name.isNotEmpty &&
      email.isNotEmpty &&
      username.isNotEmpty &&
      password.length >= 8;
}
