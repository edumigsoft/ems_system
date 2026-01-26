/// Tipos de filtro disponíveis.
enum FilterType {
  /// Filtro por texto livre
  text,

  /// Filtro por seleção dropdown
  dropdown,

  /// Filtro por data
  date,

  /// Filtro por range (numérico ou de datas)
  range,

  /// Filtro customizado
  custom,
}

/// Modelo de filtro para tabelas.
///
/// Define um filtro que pode ser aplicado aos dados da tabela.
/// Cada filtro tem um predicado que determina se um item passa no filtro.
///
/// **Exemplo de uso:**
/// ```dart
/// final activeFilter = DSTableFilter<School>(
///   id: 'status_active',
///   label: 'Ativas',
///   predicate: (school) => school.status == SchoolStatus.active,
/// );
///
/// final inactiveFilter = DSTableFilter<School>(
///   id: 'status_inactive',
///   label: 'Em Manutenção',
///   predicate: (school) => school.status == SchoolStatus.maintenance,
/// );
/// ```
class DSTableFilter<T> {
  /// ID único do filtro
  final String id;

  /// Label exibido para o usuário
  final String label;

  /// Função que determina se um item passa no filtro
  final bool Function(T item) predicate;

  /// Tipo do filtro (para UI diferenciada)
  final FilterType type;

  /// Valor atual do filtro (opcional, para filtros com valor)
  final dynamic value;

  /// Se o filtro está ativo
  final bool isActive;

  const DSTableFilter({
    required this.id,
    required this.label,
    required this.predicate,
    this.type = FilterType.text,
    this.value,
    this.isActive = true,
  });

  /// Cria uma cópia do filtro com novos valores
  DSTableFilter<T> copyWith({
    String? id,
    String? label,
    bool Function(T item)? predicate,
    FilterType? type,
    dynamic value,
    bool? isActive,
  }) {
    return DSTableFilter<T>(
      id: id ?? this.id,
      label: label ?? this.label,
      predicate: predicate ?? this.predicate,
      type: type ?? this.type,
      value: value ?? this.value,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is DSTableFilter<T> && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
