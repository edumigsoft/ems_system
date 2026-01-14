import 'package:auth_shared/auth_shared.dart';
import 'package:drift/drift.dart';

import '../database/auth_database.dart';
import '../database/tables/resource_members_table.dart';

part 'resource_permission_repository.g.dart';

/// Repository para gestão de permissões de recursos.
@DriftAccessor(tables: [ResourceMembers])
class ResourcePermissionRepository extends DatabaseAccessor<AuthDatabase>
    with _$ResourcePermissionRepositoryMixin {
  ResourcePermissionRepository(AuthDatabase db) : super(db);

  /// Busca permissão de um usuário em um recurso específico.
  Future<ResourcePermission?> getPermission({
    required String userId,
    required String resourceType,
    required String resourceId,
  }) async {
    final query = select(resourceMembers)
      ..where((tbl) => tbl.userId.equals(userId))
      ..where((tbl) => tbl.resourceType.equals(resourceType))
      ..where((tbl) => tbl.resourceId.equals(resourceId));

    final result = await query.getSingleOrNull();
    return result != null
        ? ResourcePermission.fromString(result.permission)
        : null;
  }

  /// Concede ou atualiza permissão.
  Future<void> grantPermission({
    required String userId,
    required String resourceType,
    required String resourceId,
    required ResourcePermission permission,
  }) async {
    await into(resourceMembers).insertOnConflictUpdate(
      ResourceMembersCompanion(
        userId: Value(userId),
        resourceType: Value(resourceType),
        resourceId: Value(resourceId),
        permission: Value(permission.name),
      ),
    );
  }

  /// Revoga permissão (remove registro).
  Future<void> revokePermission({
    required String userId,
    required String resourceType,
    required String resourceId,
  }) async {
    await (delete(resourceMembers)
          ..where((tbl) => tbl.userId.equals(userId))
          ..where((tbl) => tbl.resourceType.equals(resourceType))
          ..where((tbl) => tbl.resourceId.equals(resourceId)))
        .go();
  }

  /// Lista membros de um recurso.
  Future<List<ResourceMembersData>> listMembers({
    required String resourceType,
    required String resourceId,
  }) {
    return (select(resourceMembers)
          ..where((tbl) => tbl.resourceType.equals(resourceType))
          ..where((tbl) => tbl.resourceId.equals(resourceId)))
        .get();
  }
}
