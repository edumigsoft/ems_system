import 'package:drift/drift.dart';
import 'package:core_server/core_server.dart';
import 'package:user_server/user_server.dart';

/// Tabela genérica de membros/permissões por recurso.
///
/// Relacionamento genérico entre usuário e qualquer recurso.
/// Usado por: projects, documents, teams, organizations, etc.
/// Cada módulo define seu próprio `resourceType`.
class ResourceMembers extends Table with DriftTableMixinPostgres {
  /// FK para tabela users.
  TextColumn get userId => text().references(Users, #id)();

  /// Tipo do recurso (ex: "project", "team", "document").
  @JsonKey('resource_type')
  TextColumn get resourceType => text()();

  /// ID do recurso específico.
  @JsonKey('resource_id')
  TextColumn get resourceId => text()();

  /// Permissão do usuário neste recurso.
  /// Valores: "read", "write", "delete", "manage"
  TextColumn get permission => text()();

  /// Índice único para evitar duplicatas.
  @override
  List<Set<Column>> get uniqueKeys => [
    {userId, resourceType, resourceId},
  ];
}
