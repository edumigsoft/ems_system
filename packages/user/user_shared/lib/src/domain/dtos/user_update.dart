import 'package:open_api_shared/open_api_shared.dart';

/// DTO para atualização de usuário.
///
/// Seguindo entity_patterns.md:
/// - Campo `id` obrigatório (identifica o registro)
/// - Campos opcionais para atualização parcial
/// - Inclui `isActive` e `isDeleted` para controle
/// - SEM `createdAt` (imutável) ou `updatedAt` (auto-gerenciado)
/// - SEM serialização (responsabilidade de UserUpdateModel)
@apiModel
@Model(
  name: 'UserUpdate',
  description: 'DTO para atualização de usuário',
)
class UserUpdate {
  @Property(description: 'ID do usuário', required: true)
  final String id;

  @Property(description: 'Nome completo')
  final String? name;

  @Property(description: 'URL do avatar')
  final String? avatarUrl;

  @Property(description: 'Telefone')
  final String? phone;

  @Property(description: 'Se o usuário está ativo')
  final bool? isActive;

  @Property(description: 'Se o usuário está deletado (soft delete)')
  final bool? isDeleted;

  const UserUpdate({
    required this.id,
    this.name,
    this.avatarUrl,
    this.phone,
    this.isActive,
    this.isDeleted,
  });

  /// Verifica se há algum campo para atualizar.
  bool get hasChanges =>
      name != null ||
      avatarUrl != null ||
      phone != null ||
      isActive != null ||
      isDeleted != null;

  /// Validação básica (id não vazio).
  bool get isValid => id.isNotEmpty;
}
