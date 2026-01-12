import 'package:core_shared/core_shared.dart'
    show Result, Success, Failure, DataException;
import 'package:zard/zard.dart';

/// Mixin que fornece funcionalidades de validação de formulários.
///
/// Este mixin pode ser usado em ViewModels ou widgets que precisam
/// validar dados de formulários usando schemas do Zard.
mixin FormValidationMixin {
  /// Valida dados usando um schema do Zard.
  ///
  /// [data] - Dados a serem validados (`Map<String, dynamic>`)
  /// [schema] - Schema de validação do Zard
  ///
  /// Retorna [Success] com dados validados ou [Failure] com erros de validação.
  Result<Map<String, dynamic>> validateForm({
    required Map<String, dynamic> data,
    required ZMap schema,
  }) {
    try {
      final result = schema.parse(data);
      return Success(result);
    } on ZardError catch (e) {
      return Failure(DataException('Erro de validação: ${e.messages}'));
    } catch (e) {
      return Failure(
        DataException('Erro inesperado na validação: ${e.toString()}'),
      );
    }
  }

  /// Valida um campo específico.
  Result<T> validateField<T>({
    required T value,
    required dynamic fieldSchema,
    required String fieldName,
  }) {
    try {
      // ignore: avoid_dynamic_calls
      final result = fieldSchema.parse(value);
      return Success(result as T);
    } on ZardError catch (e) {
      return Failure(DataException('Erro no campo $fieldName: ${e.messages}'));
    } catch (e) {
      return Failure(
        DataException('Erro inesperado no campo $fieldName: ${e.toString()}'),
      );
    }
  }
}
