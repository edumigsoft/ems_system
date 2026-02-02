import 'package:meta/meta.dart';

/// Resultado paginado genérico.
///
/// Encapsula uma lista de itens junto com metadados de paginação
/// como total de registros, página atual, limite por página, etc.
///
/// ## Uso
/// ```dart
/// final result = PaginatedResult<User>(
///   items: users,
///   total: 100,
///   page: 1,
///   limit: 50,
/// );
///
/// print('Página ${result.page} de ${result.totalPages}');
/// print('Tem próxima? ${result.hasNextPage}');
/// ```
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

  /// Cria um resultado paginado a partir de offset/limit.
  ///
  /// Converte offset para número de página automaticamente.
  factory PaginatedResult.fromOffset({
    required List<T> items,
    required int total,
    required int offset,
    required int limit,
  }) {
    final page = (offset ~/ limit) + 1;
    return PaginatedResult(
      items: items,
      total: total,
      page: page,
      limit: limit,
    );
  }

  /// Cria um resultado paginado vazio.
  factory PaginatedResult.empty({int limit = 50}) {
    return PaginatedResult(
      items: [],
      total: 0,
      page: 1,
      limit: limit,
    );
  }

  /// Número total de páginas
  int get totalPages => total == 0 ? 0 : (total / limit).ceil();

  /// Se existe uma próxima página
  bool get hasNextPage => page < totalPages;

  /// Se existe uma página anterior
  bool get hasPreviousPage => page > 1;

  /// Offset calculado (usado para queries)
  int get offset => (page - 1) * limit;

  /// Verifica se está na primeira página
  bool get isFirstPage => page == 1;

  /// Verifica se está na última página
  bool get isLastPage => page >= totalPages;

  /// Número de itens na página atual
  int get itemCount => items.length;

  /// Índice do primeiro item (global, baseado em 1)
  int get firstItemIndex => total == 0 ? 0 : offset + 1;

  /// Índice do último item (global, baseado em 1)
  int get lastItemIndex => total == 0 ? 0 : offset + itemCount;

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

  /// Mapeia os itens para outro tipo, preservando metadados de paginação.
  PaginatedResult<R> map<R>(R Function(T item) mapper) {
    return PaginatedResult<R>(
      items: items.map(mapper).toList(),
      total: total,
      page: page,
      limit: limit,
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
    return 'PaginatedResult<$T>(items: $itemCount/$total, page: $page/$totalPages, limit: $limit)';
  }
}
