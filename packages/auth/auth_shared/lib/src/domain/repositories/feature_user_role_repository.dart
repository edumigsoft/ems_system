import 'package:core_shared/core_shared.dart';
import '../entities/feature_user_role_details.dart';
import '../dtos/feature_user_role_create.dart';
import '../dtos/feature_user_role_update.dart';
import '../../authorization/feature_user_role_enum.dart' as feature_role;

/// Interface genérica de repositório para papéis de usuário em features.
///
/// Implementações devem ser criadas por feature (ex: ProjectUserRoleRepository).
/// Cada feature manterá sua própria tabela e isolamento de dados.
abstract class FeatureUserRoleRepository {
  /// Concede ou atualiza papel de usuário em uma feature.
  Future<Result<FeatureUserRoleDetails>> grant(FeatureUserRoleCreate data);

  /// Revoga papel de usuário (soft delete).
  Future<Result<Unit>> revoke({
    required String userId,
    required String featureId,
  });

  /// Obtém o papel de um usuário em uma feature específica.
  ///
  /// Retorna null se o usuário não tiver papel nesta feature.
  Future<Result<FeatureUserRoleDetails?>> getUserRole({
    required String userId,
    required String featureId,
  });

  /// Lista todos os membros de uma feature.
  Future<Result<List<FeatureUserRoleDetails>>> listFeatureMembers({
    required String featureId,
    bool includeDeleted = false,
  });

  /// Lista todas as features onde o usuário possui papel.
  Future<Result<List<FeatureUserRoleDetails>>> listUserFeatures({
    required String userId,
    bool includeDeleted = false,
  });

  /// Atualiza papel de usuário.
  Future<Result<FeatureUserRoleDetails>> updateRole(FeatureUserRoleUpdate data);

  /// Verifica se usuário possui papel mínimo em uma feature.
  ///
  /// Útil para verificações de autorização rápidas.
  Future<Result<bool>> hasRole({
    required String userId,
    required String featureId,
    required feature_role.FeatureUserRole minRole,
  });
}
