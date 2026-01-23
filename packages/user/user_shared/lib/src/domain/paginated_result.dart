import 'package:meta/meta.dart';

/// Resultado paginado genérico.
///
/// Encapsula uma lista de itens junto com metadados de paginação
/// como total de registros, página atual, limite por página, etc.
@immutable
class PaginatedResult<T> {
  /// Lista de itens da página atual
  final List<T> items;

  /// Número total de registros (antes da paginação)
  final int total;

  /// Página atual (baseada em 1)
  final int page;

  /// Número de itens por página
  final int limit;

  const PaginatedResult({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
  });

  /// Número total de páginas
  int get totalPages => (total / limit).ceil();

  /// Se existe uma próxima página
  bool get hasNextPage => page < totalPages;

  /// Se existe uma página anterior
  bool get hasPreviousPage => page > 1;

  /// Offset calculado (usado para queries)
  int get offset => (page - 1) * limit;

  /// Cria uma cópia com campos modificados
  PaginatedResult<T> copyWith({
    List<T>? items,
    int? total,
    int? page,
    int? limit,
  }) {
    return PaginatedResult<T>(
      items: items ?? this.items,
      total: total ?? this.total,
      page: page ?? this.page,
      limit: limit ?? this.limit,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is PaginatedResult<T> &&
        other.items == items &&
        other.total == total &&
        other.page == page &&
        other.limit == limit;
  }

  @override
  int get hashCode {
    return items.hashCode ^ total.hashCode ^ page.hashCode ^ limit.hashCode;
  }

  @override
  String toString() {
    return 'PaginatedResult(items: ${items.length}, total: $total, page: $page/$totalPages, limit: $limit)';
  }
}
