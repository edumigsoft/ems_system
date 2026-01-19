import '../../core_shared.dart';

/// Helper para mapeamento de entidades.
///
/// Fornece métodos auxiliares para converter entre diferentes
/// representações de entidades (DTOs, modelos, entidades de domínio).
class EntityMapper {
  /// Mapeia uma lista de modelos para uma lista de entidades.
  static List<TEntity> mapList<TModel, TEntity>({
    required List<TModel> models,
    required TEntity Function(TModel) mapper,
  }) {
    return models.map(mapper).toList();
  }

  /// Mapeia um modelo para entidade com tratamento de erro.
  static Result<TEntity> mapSafe<TModel, TEntity>({
    required TModel? model,
    required TEntity Function(TModel) mapper,
    String? errorMessage,
  }) {
    if (model == null) {
      return Failure(DataException(errorMessage ?? 'Modelo não pode ser nulo'));
    }

    try {
      return Success(mapper(model));
    } catch (e) {
      return Failure(
        DataException(errorMessage ?? 'Erro ao mapear modelo: ${e.toString()}'),
      );
    }
  }
}

/// Extensão para facilitar conversão de modelos para entidades.
extension ModelToEntityExtension<T> on T {
  /// Converte o modelo atual para uma entidade usando a função fornecida.
  R toEntity<R>(R Function(T) toEntity) => toEntity(this);
}
