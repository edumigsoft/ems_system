import 'package:open_api_shared/open_api_shared.dart';

/// Resposta paginada genérica para endpoints que retornam listas.
///
/// Usado para encapsular resposta da API com metadados de paginação.
@apiModel
@Model(
  name: 'PaginatedResponse',
  description: 'Resposta paginada genérica com metadados',
)
class PaginatedResponse<T> {
  @Property(description: 'Lista de itens da página atual')
  final List<T> data;

  @Property(description: 'Número da página atual')
  final int page;

  @Property(description: 'Limite de itens por página')
  final int limit;

  @Property(description: 'Total de itens na página atual')
  final int total;

  const PaginatedResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
  });

  /// Deserializa de JSON para PaginatedResponse.
  ///
  /// [itemFromJson] é uma função que converte cada item JSON para o tipo T.
  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson,
  ) {
    final dataList = json['data'] as List<dynamic>;
    return PaginatedResponse(
      data: dataList
          .map((item) => itemFromJson(item as Map<String, dynamic>))
          .toList(),
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
    );
  }

  /// Serializa para JSON.
  Map<String, dynamic> toJson(Map<String, dynamic> Function(T) itemToJson) => {
    'data': data.map(itemToJson).toList(),
    'page': page,
    'limit': limit,
    'total': total,
  };

  /// Cria uma nova PaginatedResponse transformando os dados.
  PaginatedResponse<R> map<R>(R Function(T) transform) {
    return PaginatedResponse(
      data: data.map(transform).toList(),
      page: page,
      limit: limit,
      total: total,
    );
  }
}
