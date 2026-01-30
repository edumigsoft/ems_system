import 'package:core_shared/core_shared.dart'
    show Result, Unit, PaginatedResult;
import '../dtos/school_create.dart';
import '../entities/school_details.dart';
import '../enums/school_enum.dart';

/// Repositório responsável pelo gerenciamento de escolas.
///
/// Este repositório fornece operações CRUD para escolas e métodos de busca específicos
/// por nome e código CIE.
///
/// ## Exemplo de Uso
///
/// ```dart
/// final repository = GetIt.I<SchoolRepository>();
///
/// // Criar uma nova escola
/// final result = await repository.create(
///   SchoolCreate(
///     name: 'Escola Modelo',
///     cie: '123456',
///     // ... outros campos
///   ),
/// );
/// ```
abstract class SchoolRepository {
  /// Retorna uma lista paginada de todas as escolas.
  ///
  /// [limit] - O número máximo de escolas a serem retornadas.
  /// [offset] - O número de escolas a serem ignoradas.
  /// [search] - Termo de busca para filtrar por nome, código, diretor ou cidade.
  /// [status] - Filtro por status da escola (active, inactive, maintenance).
  /// [city] - Filtro por cidade.
  /// [district] - Filtro por distrito.
  ///
  /// Retorna um [Result] contendo [PaginatedResult] com lista de [SchoolDetails] e metadados.
  Future<Result<PaginatedResult<SchoolDetails>>> getAll({
    int? limit,
    int? offset,
    String? search,
    SchoolStatus? status,
    String? city,
    String? district,
  });

  /// Cria uma nova escola.
  ///
  /// [school] - Os dados da nova escola a ser criada.
  ///
  /// Retorna um [Result] contendo os detalhes da escola criada.
  Future<Result<SchoolDetails>> create(SchoolCreate school);

  /// Atualiza uma escola existente.
  ///
  /// [school] - Os dados atualizados da escola.
  ///
  /// Retorna um [Result] contendo os detalhes da escola atualizada.
  Future<Result<SchoolDetails>> update(SchoolDetails school);

  /// Exclui uma escola pelo seu ID.
  ///
  /// [id] - O identificador único da escola.
  ///
  /// Retorna um [Result] com [Unit] indicando sucesso ou falha.
  Future<Result<Unit>> delete(String id);

  /// Busca os detalhes de uma escola específica pelo seu ID.
  ///
  /// [id] - O identificador único da escola.
  ///
  /// Retorna um [Result] contendo [SchoolDetails].
  Future<Result<SchoolDetails>> getById(String id);

  /// Busca uma escola pelo seu nome.
  ///
  /// [name] - O nome da escola.
  ///
  /// Retorna um [Result] contendo [SchoolDetails].
  Future<Result<SchoolDetails>> getByName(String name);

  /// Busca uma escola pelo seu código CIE.
  ///
  /// [cie] - O Código de Identificação da Escola.
  ///
  /// Retorna um [Result] contendo [SchoolDetails].
  Future<Result<SchoolDetails>> getByCie(String cie);

  /// Retorna uma lista paginada de escolas deletadas (soft delete).
  ///
  /// Este método permite que administradores visualizem escolas que foram
  /// marcadas como deletadas (isDeleted = true) para possível restauração.
  ///
  /// [limit] - O número máximo de escolas a serem retornadas.
  /// [offset] - O número de escolas a serem ignoradas.
  /// [search] - Termo de busca para filtrar por nome, código, diretor ou cidade.
  /// [status] - Filtro por status da escola (active, inactive, maintenance).
  /// [city] - Filtro por cidade.
  /// [district] - Filtro por distrito.
  ///
  /// Retorna um [Result] contendo [PaginatedResult] com lista de [SchoolDetails] deletadas.
  Future<Result<PaginatedResult<SchoolDetails>>> getDeleted({
    int? limit,
    int? offset,
    String? search,
    SchoolStatus? status,
    String? city,
    String? district,
  });
}
