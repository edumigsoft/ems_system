import 'package:core_shared/core_shared.dart';
import 'package:auth_shared/auth_shared.dart';
import '../repository/project_user_role_repository.dart';

/// Serviço de gerenciamento de papéis de usuário em projetos.
///
/// Wraps repository com lógica de negócio e validações.
class ProjectUserRoleService {
  final ProjectUserRoleRepository _repository;

  ProjectUserRoleService(this._repository);

  /// Concede papel a um usuário em um projeto com validação.
  Future<Result<FeatureUserRoleDetails>> grantRole({
    required String userId,
    required String projectId,
    required FeatureUserRole role,
  }) async {
    final create = FeatureUserRoleCreate(
      userId: userId,
      featureId: projectId,
      role: role,
    );

    if (!create.isValid) {
      return Failure(DataException('Invalid role data'));
    }

    return _repository.grant(create);
  }

  /// Revoga papel de um usuário em um projeto.
  Future<Result<Unit>> revokeRole({
    required String userId,
    required String projectId,
  }) async {
    return _repository.revoke(userId: userId, featureId: projectId);
  }

  /// Verifica se usuário pode gerenciar membros do projeto.
  Future<Result<bool>> canManageMembers({
    required String userId,
    required String projectId,
  }) async {
    return _repository.hasRole(
      userId: userId,
      featureId: projectId,
      minRole: FeatureUserRole.manager,
    );
  }

  /// Lista todos os membros de um projeto.
  Future<Result<List<FeatureUserRoleDetails>>> listMembers(String projectId) {
    return _repository.listFeatureMembers(featureId: projectId);
  }

  /// Lista todos os projetos onde o usuário possui papel.
  Future<Result<List<FeatureUserRoleDetails>>> listUserProjects(String userId) {
    return _repository.listUserFeatures(userId: userId);
  }

  /// Obtém papel de um usuário em um projeto.
  Future<Result<FeatureUserRoleDetails?>> getUserRole({
    required String userId,
    required String projectId,
  }) {
    return _repository.getUserRole(userId: userId, featureId: projectId);
  }

  /// Atualiza papel de um usuário em um projeto.
  Future<Result<FeatureUserRoleDetails>> updateRole(
    FeatureUserRoleUpdate update,
  ) {
    if (!update.hasChanges) {
      return Future.value(Failure(DataException('No changes to apply')));
    }

    return _repository.updateRole(update);
  }
}
