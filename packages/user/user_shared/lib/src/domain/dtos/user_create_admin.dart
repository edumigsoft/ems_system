import 'package:ems_system_core_shared/core_shared.dart' show UserRole;
import 'package:open_api_shared/open_api_shared.dart'
    show apiModel, Model, Property;

/// DTO para criação administrativa de usuário.
///
/// Usado quando um owner cria usuários administrativamente,
/// sem necessidade de senha inicial. O usuário receberá um email
/// para definir sua senha no primeiro acesso.
///
/// Seguindo entity_patterns.md:
/// - Apenas campos necessários para criação administrativa
/// - SEM `id` (gerado pelo banco)
/// - SEM `password` (será gerado hash aleatório + email de ativação)
/// - SEM metadados (createdAt, updatedAt, etc.)
/// - SEM serialização (responsabilidade de UserCreateAdminModel)
@apiModel
@Model(
  name: 'UserCreateAdmin',
  description: 'DTO para criação administrativa de usuário',
)
class UserCreateAdmin {
  @Property(description: 'Nome completo', required: true)
  final String name;

  @Property(description: 'Email do usuário', required: true)
  final String email;

  @Property(description: 'Nome de usuário (único)', required: true)
  final String username;

  @Property(description: 'Role do usuário (padrão: user)')
  final UserRole role;

  @Property(description: 'Telefone (opcional)')
  final String? phone;

  const UserCreateAdmin({
    required this.name,
    required this.email,
    required this.username,
    this.role = UserRole.user,
    this.phone,
  });

  /// Validação básica de presença.
  bool get isValid =>
      name.isNotEmpty && email.isNotEmpty && username.isNotEmpty;
}
