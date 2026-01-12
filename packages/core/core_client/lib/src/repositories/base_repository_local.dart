import 'package:dio/dio.dart';
import 'package:core_shared/core_shared.dart';
import '../mixins/dio_error_handler.dart';

/// Classe base para repositórios que acessam APIs HTTP via Dio.
///
/// Fornece métodos helpers que encapsulam:
/// - Execução segura de requisições HTTP
/// - Tratamento automático de exceções do Dio via [DioErrorHandler]
/// - Conversão para o padrão [Result<T>]
/// - Logging estruturado (implícito)
///
/// ## Exemplo de Uso
///
/// ```dart
/// class UserRepositoryLocal extends BaseRepositoryLocal<UserDetails, UserCreate>
///     implements UserRepository {
///   final UserService _userService;
///
///   UserRepositoryLocal({
///     required UserService userService,
///   }) : _userService = userService;
///
///   @override
///   Future<Result<UserDetails>> create(UserCreate user) async {
///     return await executeRequest(
///       request: () => _userService.create(user),
///       context: 'creating user',
///       mapper: (model) => model.toDetails(),
///     );
///   }
/// }
/// ```
abstract class BaseRepositoryLocal with Loggable, DioErrorHandler {
  /// Executa uma requisição HTTP e trata erros automaticamente.
  ///
  /// [request] - Função que executa a requisição HTTP
  /// [context] - Contexto da operação (para logs e mensagens de erro)
  /// [mapper] - Função opcional para mapear resposta para entidade
  ///
  /// Retorna [Success] com resultado ou [Failure] com erro tratado.
  Future<Result<TEntity>> executeRequest<TResponse, TEntity>({
    required Future<TResponse> Function() request,
    required String context,
    TEntity Function(TResponse)? mapper,
  }) async {
    try {
      final response = await request();

      if (mapper != null) {
        return Success(mapper(response));
      }

      return Success(response as TEntity);
    } on DioException catch (e) {
      return handleDioError(e, context: context);
    } catch (e, s) {
      return handleError(e, context, s);
    }
  }

  /// Executa uma requisição que retorna uma lista de entidades.
  Future<Result<List<TEntity>>> executeListRequest<TResponse, TEntity>({
    required Future<List<TResponse>> Function() request,
    required String context,
    required TEntity Function(TResponse) mapper,
  }) async {
    try {
      final response = await request();
      final entities = response.map(mapper).toList();
      return Success(entities);
    } on DioException catch (e) {
      return handleDioError(e, context: context);
    } catch (e, s) {
      return handleError(e, context, s);
    }
  }

  /// Executa uma requisição que não retorna dados (ex: delete).
  Future<Result<Unit>> executeVoidRequest({
    required Future<void> Function() request,
    required String context,
  }) async {
    try {
      await request();
      return successOfUnit();
    } on DioException catch (e) {
      return handleDioError(e, context: context);
    } catch (e, s) {
      return handleError(e, context, s);
    }
  }

  /// Executa uma requisição customizada com lógica específica.
  Future<Result<TEntity>> executeCustomRequest<TEntity>({
    required Future<TEntity> Function() request,
    required String context,
  }) async {
    try {
      final result = await request();
      return Success(result);
    } on DioException catch (e) {
      return handleDioError<TEntity>(e, context: context);
    } catch (e, s) {
      return handleError(e, context, s);
    }
  }
}
