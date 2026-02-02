import 'package:open_api_shared/open_api_shared.dart';
import 'user_details_model.dart';

/// Resposta da API para listagem de usuários com paginação.
///
/// Estrutura retornada pelo endpoint GET /users.
@apiModel
@Model(
  name: 'UsersListResponse',
  description: 'Resposta paginada para listagem de usuários',
)
class UsersListResponse {
  @Property(description: 'Lista de usuários da página atual')
  final List<UserDetailsModel> data;

  @Property(description: 'Número da página atual')
  final int page;

  @Property(description: 'Limite de itens por página')
  final int limit;

  @Property(description: 'Total de registros (antes da paginação)')
  final int total;

  @Property(description: 'Total de páginas')
  final int? totalPages;

  @Property(description: 'Se existe uma próxima página')
  final bool? hasNextPage;

  @Property(description: 'Se existe uma página anterior')
  final bool? hasPreviousPage;

  const UsersListResponse({
    required this.data,
    required this.page,
    required this.limit,
    required this.total,
    this.totalPages,
    this.hasNextPage,
    this.hasPreviousPage,
  });

  /// Deserializa de JSON para UsersListResponse.
  factory UsersListResponse.fromJson(Map<String, dynamic> json) {
    final dataList = json['data'] as List<dynamic>;
    return UsersListResponse(
      data: dataList
          .map(
            (item) => UserDetailsModel.fromJson(item as Map<String, dynamic>),
          )
          .toList(),
      page: json['page'] as int,
      limit: json['limit'] as int,
      total: json['total'] as int,
      totalPages: json['totalPages'] as int?,
      hasNextPage: json['hasNextPage'] as bool?,
      hasPreviousPage: json['hasPreviousPage'] as bool?,
    );
  }

  /// Serializa para JSON.
  Map<String, dynamic> toJson() => {
    'data': data.map((item) => item.toJson()).toList(),
    'page': page,
    'limit': limit,
    'total': total,
    if (totalPages != null) 'totalPages': totalPages,
    if (hasNextPage != null) 'hasNextPage': hasNextPage,
    if (hasPreviousPage != null) 'hasPreviousPage': hasPreviousPage,
  };
}
