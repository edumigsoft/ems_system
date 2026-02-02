class SchoolUpdate {
  final String id; // Obrigatório - identifica o registro
  final String? name; // Opcional - atualização parcial
  final String? address; // Opcional - atualização parcial
  final String? phone; // Opcional - atualização parcial
  final String? email; // Opcional - atualização parcial
  final String? cie; // Opcional - atualização parcial
  final bool? isActive; // Opcional - ativar/desativar
  final bool? deleted; // Opcional - soft delete

  const SchoolUpdate({
    required this.id,
    this.name,
    this.address,
    this.phone,
    this.email,
    this.cie,
    this.isActive,
    this.deleted,
  });

  // Verifica se há mudanças
  bool get hasChanges =>
      name != null ||
      address != null ||
      phone != null ||
      email != null ||
      cie != null ||
      isActive != null ||
      deleted != null;

  // Validação
  bool get isValid => id.isNotEmpty;

  // Validação detalhada
  String? validate() {
    if (id.isEmpty) return 'ID é obrigatório';
    if (!hasChanges) return 'Nenhuma alteração fornecida';
    if (name != null && name!.isEmpty) return 'Nome não pode ser vazio';
    if (email != null && !email!.contains('@')) return 'Email inválido';
    return null;
  }
}
