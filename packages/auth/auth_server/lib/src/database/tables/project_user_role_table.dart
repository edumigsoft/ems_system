import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart';
import '../converters/feature_user_role_converter.dart';

/// Tabela de papéis de usuários em projetos.
///
/// Exemplo de implementação de feature-specific user roles.
/// Estrutura replicável para qualquer feature (finance_user_role, task_user_role, etc.).
///
/// Cada usuário pode ter apenas um papel por projeto (unique constraint).
@DataClassName('ProjectUserRoleData')
class ProjectUserRoles extends Table with DriftTableMixinPostgres {
  /// ID do usuário
  @JsonKey('user_id')
  TextColumn get userId => text()();

  /// ID do projeto (featureId)
  @JsonKey('project_id')
  TextColumn get projectId => text()();

  /// Papel do usuário no projeto
  TextColumn get role => text()
      .map(const FeatureUserRoleConverter())
      .withDefault(const Constant('viewer'))();

  /// Unique constraint: um papel por usuário por projeto
  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, projectId},
  ];
}
