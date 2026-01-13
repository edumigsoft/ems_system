/// Permissões padrão CRUD reutilizáveis por qualquer módulo.
///
/// Hierarquia: read < write < delete < manage
/// Cada nível inclui as permissões dos níveis anteriores.
enum ResourcePermission {
  /// Apenas leitura do recurso.
  read(1),

  /// Criar e editar o recurso.
  write(2),

  /// Remover o recurso.
  delete(3),

  /// Controle total + gerenciar membros/permissões.
  manage(4);

  /// Nível hierárquico da permissão.
  final int level;

  const ResourcePermission(this.level);

  /// Verifica se esta permissão satisfaz o nível mínimo exigido.
  ///
  /// Exemplo:
  /// ```dart
  /// ResourcePermission.manage.satisfies(ResourcePermission.write) // true
  /// ResourcePermission.read.satisfies(ResourcePermission.write) // false
  /// ```
  bool satisfies(ResourcePermission required) => level >= required.level;

  /// Converte string para enum.
  static ResourcePermission? fromString(String? value) {
    if (value == null) return null;
    return ResourcePermission.values.firstWhere(
      (p) => p.name == value,
      orElse: () => ResourcePermission.read,
    );
  }
}
